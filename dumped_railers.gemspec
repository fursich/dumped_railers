require_relative 'lib/dumped_railers/version'

Gem::Specification.new do |spec|
  spec.name          = 'dumped_railers'
  spec.version       = DumpedRailers::VERSION
  spec.authors       = ['Koji Onishi']
  spec.email         = ['fursich0@gmail.com']

  spec.summary       = %q{A flexible fixture importer/exporter, that can transport related records into other databases }
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/fursich/dumped_railers'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'TODO: Set to http://mygemserver.com'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/fursich/dumped_railers'
  spec.metadata['changelog_uri'] = 'https://github.com/fursich/dumped_railers/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'database_cleaner-active_record', '~> 1.8'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-doc'
end
