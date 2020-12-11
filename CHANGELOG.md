# Change Log

## [0.1.0]
### Added
- Implement method that dumps specified model data in fixture (YAML) format
- Implement import method that transfer fixture into database
- Add test helpers to make it easy to implement database related tests
- Add config options to be able to ignore specific columns
- Accept preprocessors to make filtering behavior pluggable and customizable
- Add Readme

## [0.1.1]
### Fixed
- Fix mis-handling of namespaced class names (separated by `::`)

## [0.1.2]
### Changed
- Accept wider types of reference labels, allowing spaces in-between (tentative)

## [0.1.3]
### Fixed
- Cope with relations that has different name with the actual class name
  (e.g. associations defined using `:class_name` and `:foreign_key` options)


