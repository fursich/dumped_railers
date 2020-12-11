# DumpedRailers    <img src='https://user-images.githubusercontent.com/23026542/101830310-aaf10000-3b77-11eb-9e0a-d14e45b27760.png' width=40>
[![Build Status](https://travis-ci.com/fursich/dumped_railers.svg?branch=main)](https://travis-ci.com/fursich/dumped_railers) [![Gem Version](https://badge.fury.io/rb/dumped_railers.svg)](https://badge.fury.io/rb/dumped_railers)

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

### Ignored Columns

* By default, DumpedRailers ignore three columns - `id`, `created_at`, `updated_at`. You can always update/change this settings as follows.

```ruby
DumpedRailers.configure do |config|
  config.ignorable_columns += [:published_on] # published_on will be ignored on top of default settings.
end
```

* of course you can totally replace the settings with your own.
```ruby
DumpedRailers.configure do |config|
  config.ignorable_columns = %i[uuid created_on updated_on] # uuid and created_on will be ignored instead of id, created_at, updated_at
end
```

### Masking, filtering

* you can pass `preprocessors` to DumpedRailers before it starts dump. All the attributes are filtered through preprocessors in order of registration.

```ruby
DumpedRailers.dump!(User, Item, base_dir: 'tmp/', preprocessors: [MaskingPreprocessor.new])
```

* "Preprocessors" can be lambda, or module, or any objects that can repond to #call(atrs, model).


```ruby
class MaskingPreprocessor
  def call(attrs, model)
    attrs.map { |col, value|
      col.match?(/password/) ? [col, '<MASKED>'] : [col, value]
    }.to_h
  end
end
```

* a lambda object can be accepted as well

```ruby
masking_preprocessor = -> (attrs, model) { attrs.transform_values(&:upcase) }
```

NOTE: The proprocessors must return attributes in the same format `{ attributes_name: value }` so that preprocessors and dump handlers can preprocessors in nested manner.

### pseudo multi-tenancy (such as ActsAsTenant)

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
