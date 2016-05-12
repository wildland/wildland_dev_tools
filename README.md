# Wildland DevTools
This is a gem that contains all of our dev rake tasks.

## Installation

Add the following to your `Gemfile`:

`gem 'wildland_dev_tools', '~>0.3.0', git: 'https://github.com/wildland/wildland_dev_tools.git'`

Typically for wildland projects you will want to put this inside the dev/test block:
```
group :development, :test do
  ...
  gem 'wildland_dev_tools', '~>0.3.0',  git: 'https://github.com/wildland/wildland_dev_tools.git'
  ...
end
```

## Usage
You will get a new batch of new rake tasks under the wildland namespace. For a full list run `rake -T`.

### Local Development Tools
*Note that you will need to run `bundle install` before being able to use these.*

- `rake wildland:setup` This will run all of the setup tasks to get your local enviroment ready to go.
- `rake wildland:db` This will resetup and seed the local database.
- `rake wildland:cache_clear` This will clear the local app-ember package cache.

- `rake wildland:pre_deploy` This will run all of the pre-deploy tasks to get the project ready to deploy.
- `rake wildland:pre_pr` Convenience alias to `rake wildland:pre_pull_request`.
- `rake wildland:pre_pull_request` This will runn all of the pre pull request tasks to get the project ready for a pull request.

### Heroku Tools
*Note. These may fail if you did not install heroku-toolbelt through brew.*
*Note. These tasks require that the production and staging remotes include the word 'staging' and 'production' in them respectively.*

- `rake wildland:heroku:promote_to_production` This will promote `staging` to `production`.
- `rake wildland:heroku:promote_to_production[verbose]` This will promote `staging` to `production` with verbose details.
- `rake wildland:heroku:maintenance_mode_on` This turns on maintenance mode for `staging` and `production`.
- `rake wildland:heroku:maintenance_mode_off` This turns off maintenance mode for `staging` and `production`.

## Code Of Conduct
Wildland Open Source [Code Of Conduct](https://github.com/wildland/code-of-conduct)
