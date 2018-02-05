# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added *for new features*
### Changed *for changes in existing functionality*
### Deprecated *for soon-to-be removed features*
### Removed *for now removed features*
### Fixed *for any bug fixes*
### Security *in case of vulnerabilities*

## [1.1.0] - 2017-01-29
### Added *for new features*
- `copy_production_database_to_staging` added as a rake task
- Now contains a `CHANGELOG.md`

### Changed *for changes in existing functionality*
- Most heroku commands will now ask if you want to continue running with a missing remove if run with verbose or force. This means that if you do a staging deploy with no `production` remove it would skip copying the production database.

### Deprecated *for soon-to-be removed features*
- None

### Removed *for now removed features*
- None

### Fixed *for any bug fixes*
- None

### Security *in case of vulnerabilities*
- None
