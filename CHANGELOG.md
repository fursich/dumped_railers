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

## [0.1.4]
### Changed
- Update documents not to eagerload DumpedRailers to prevent accidental data breakage / leakage.
  To activate, it is preferable to require explicitly where necessary.

## [0.1.5]
### Added
- Supported in-memopry fixtures. Now users can dump into and import from in-memory fixture object without saving files.

## [0.2.0]
### Added
- Provide options to limit models to import, so that users can prohibit modification to arbitrary models.
- Support for Ruby 3.0.0 (requires Rails >= 6.0)

### Changed
- Accept both global configuration as well as runtime (one-off) settings for all the available options.
  Now all the configured settings will be overridden at runtime when the settings are provided with arguments.

## [0.3.0]
### Added
- Support `before_save`/`after_save` callbacks with import! method. The callbacks are invoked just before (or after) each table's records are saved.

## [0.3.0]
### Added
- Accept multiple (array) callbacks for `before_save` / `after_save` arguments with DumpedRailers.import!.
