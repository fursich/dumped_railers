# DumpedRailers    <img src='https://user-images.githubusercontent.com/23026542/101830310-aaf10000-3b77-11eb-9e0a-d14e45b27760.png' width=40>
[![Build Status](https://github.com/fursich/dumped_railers/actions/workflows/ci.yml/badge.svg)](https://github.com/fursich/dumped_railers/actions/workflows/ci.yml/badge.svg) [![Gem Version](https://badge.fury.io/rb/dumped_railers.svg)](https://badge.fury.io/rb/dumped_railers)

Helping you take a snapshot of ActiveRecord models in Rails-compatible fixture format, and re-importing them wherever necessary without destroying current data you have.

With Rails, you can import any fixture data using `rails db:fixtures:load` - however, this let's you remove all the existing data in your database before importing the fixtures. This is good for clean seeding, typically when running your tests, but there are other senarios where you want to merely ADD data, without damaging the current data you are woking with.

This is a bit trickey puzzle, though. To add the imported records, you cannot dump and re-import the primary key, as they are already taken by the original records. But usually your records involve reference to associated records, where the associations are guaranteed by the very primary keys.
In other words, the fixures have to be stored and re-imported, so as to maintain their original inter-dependencies, but their primary keys have to be re-assigned (headache)

DumpedRailers can add (not replace) the fixture without removing the current records, while restoring **all associations** among the original records.
Additionally, it can ignore, mask, or tweak any attributes when dumping the records into fixture files, which is convenient to export sensitive data (typically in your production environment) into, for instance, your staging environment.

This feature can particularily help you in the following senarios:
- you want to copy a group of records without breaking the other data sets you are working on
- you want to transfer some production data into dev environment, to reproduce some errors you encontered.
- you work for a multi-tenancy service, where you want to duplicate interdependent set of records from tenant A to tenant B.
- you simply want to populate interdependent record sets, which is not easy to re-build with FactoryBot

## Installation

Add this line to your application's Gemfile:

```ruby
# if you use this gem in production, `require: false` would be recommended
# to prevent accidental database leakage/breakage.

gem 'dumped_railers', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dumped_railers

## Usage

### Getting Started

* Require dumped_railers where necessary (e.g. in your rake tasks, or script files)

```ruby
require 'dumped_railers'
```

* if you want to dump records from (let's say) User, Item, and Tag, just run the following.

```ruby
DumpedRailers.dump!(User, Item, Tag, base_dir: 'tmp/fixtures/')
```
this will generate three fixture files under tmp/fixtures/ folder.

* if you want to import the records you just saved, run:

```ruby
DumpedRailers.import!('tmp/fixtures')
```

* you can also specify individual model(s) for selective import.

```ruby
DumpedRailers.import!('tmp/fixtures/users.yml', 'tmp/fixtures/items.yml')
```

NOTE: you at least have to provide all the dependent records, so that DumpedRailers can resolve dependencies among the fixtures provided.

### Using In-Memory Fixtures

DumpedRailers.dump! also returns an object, which can be imported directly as in-memory fixture.

```ruby
fixtures = DumpedRailers.dump!(User, Item, Tag)
DumpedRailers.import!(fixtures)
```

DumpedRailers does not save the fixtures when `base_dir` keyword argument is not specified.

### Ignoring Certain Columns

* By default, DumpedRailers ignore three columns - `id`, `created_at`, `updated_at`. You can always update/change this settings as follows.

```ruby
DumpedRailers.configure do |config|
  config.ignorable_columns += [:published_on] # :published_on will be ignored *on top of* default settings.
end
```

* of course you can totally replace the settings with your own.
```ruby
DumpedRailers.configure do |config|
  config.ignorable_columns = %i[uuid created_on updated_on] # :uuid and :created_on will be ignored *instead of* :id, :created_at, :updated_at
end
```

### Masking, Filtering

* you can pass `preprocessors` to DumpedRailers before it starts dump. All the attributes are filtered through preprocessors in order of registration.

```ruby
DumpedRailers.dump!(User, Item, base_dir: 'tmp/', preprocessors: [MaskingPreprocessor.new])
```

* "Preprocessors" can be lambda, or module, or any objects that can repond to #call(model, attributes).


```ruby
class MaskingPreprocessor
  def call(model, attrs)
    attrs.each { |col, _value|
      attrs[col] = '<MASKED>' if col.match?(/password/)
    }
  end
end
```

* a lambda object can be accepted as well

```ruby
masking_preprocessor = -> (model, attrs) { attrs.transform_values!(&:upcase) }
```

NOTE:
* In order to reflect changes to the output, **preprocessors must change the attributes destructively**.
* If you set multiple preprocessors, each preprocessor will be invoked sequentially from left to right, which means your second preprocessor receives attributes only after your first preprocessor update them.

### Limiting Import with Authorized Models Only

* In case you don't want to accept arbitrary fixtures to import, you can limit model access as follows:

```ruby
DumpedRailers.import!(fixtures, authorized_models: [Item, Price])
```

This would allow us to import fixtures for items and prices, but reject modification on User, Purchase, Admin data.

NOTE: Only DumpedRailers.import! is affected by this option. DumpedRailers.dump! can't be scoped (at least in the current version).


### Setting Callbacks

* You can set `before_save` / `after_save` callbacks for import! method.
The callbacks are invoked just before/after each table's records are saved.

```ruby
before_callback = -> (model, records) {
  if model == User
    # set random initial passwords before saving
    records.each do |user|
      user.password = user.password_confirmation = SecureRandom.hex(12)
    end
  end
}

after_callback1 = -> (model, records) {
  if model == User
    records.each do |user|
      user.confirm!
    end
  end
}

after_callback2 = -> (model, records) {
  if model == Admin
    records.each |admin|
      notify_to_slack(admin.email, admin.name)
    end
  end
}

DumpedRailers.import!(fixture_path, before_save: before_callback, after_save: [after_callback1, after_callback2])
```

`before_save` /  `after_save` can accept both single and multiple (array) arguments.

### Configuration

* All the settings can be configured by either configuration (global) or arguments (at runtime).
* When you have duplicated setting, arguments are respected: you can always override configured settings by arguments.

```ruby
DumpedRailers.configure do |config|
  config.ignorable_columns = [:archived_at]
  config.preprocessors = [FooPreprocessor, BarPreprocessor]
end

DumpedRailers.dump!(Item, ignorable_columns: [:id], preprocessors: [BazPreprocessor], base_dir: 'tmp/')
# this would ignore `id` column, and apply BazPreprocessor only

DumpedRailers.dump!(Price, base_dir: 'tmp/')
# this would ignore `archived_at`, applies FooPreprocessor and BazPreprocessor
# (settings provided with arguments are considered as one-off, and don't survive globally)
```

### Dump/Import under default_scope (e.g. ActsAsTenant)

* Such library builds multi-tenancy environment on one single database, using default_scope to switch over database access rights between tenants. You can incorporate data from Tenant A to Tenant B as follows. let's say we use [ActsAsTenant](https://github.com/ErwinM/acts_as_tenant)

```ruby
# make sure to delete old fixtures in the folder
File.delete(Dir.glob('tmp/fixtures/{**,*}/*.yml'))

# let DumpedRailers ignore tenant column, as it will be overwritten by ActsAsTenant
DumpedRailers.configure do |config|
  config.ignorable_columns += [:account_id]
end

# dump from tenant_a
ActsAsTenant.with_tenant(tenant_a) do
  DumpedRailers.dump!(Item, Tag, base_dir: 'tmp/fixtures/')
end

# import into tenant_b
ActsAsTenant.with_tenant(tenant_b) do
  DumpedRailers.import!('tmp/fixtures')
end
```

## Troubleshooting

When DumpedRailers fail to resolve dependencies, please check the following.

* DumpedRailers uses ActiveRecord reflection methods to sort out model dependencies. You might have to check wheather your relation is defined on the model (especially, `belongs_to` cannot be omitted).

* Dependencies cannot be resolved when cyclic dependencies are detected. For instance, the case like below cannot be resolved.

```ruby
class Chicken < ActiveRecord::Base
  belongs_to :egg, optional: true
end

class Egg < ActiveRecord::Base
  belongs_to :chicken, optional: true
end
```

* For the same reason, self-associated model cannot be imported currently. (might be updated in the future version)

* When an exception was raised, checking your log might give you a good hint (desperately staring at the backtrace won't give much information)
  consider displaying `tail -f logs/development.log` while executing your script.

* DumpedRailers is tested against various association types, as long as target models and underlying tables have 1-on-1 mapping (straightforward ActiveRecord pattern). Currently we haven't test this against STI, CTI, as such. Applying this gem to such models might lead to some unexpected results.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fursich/dumped_railers.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
