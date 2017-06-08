# Wildland DevTools
This is a gem that contains all of our dev rake tasks.
These are most useful for projects created by [trailhead](https://github.com/wildland/trailhead) and are deployed on [heroku](https://www.heroku.com/home) using the [pipeline](https://devcenter.heroku.com/articles/pipelines) feature. This allows for separate `staging` and `production` enviroments as well as review apps.

## Installation

Add the following to your `Gemfile`:

`gem 'wildland_dev_tools', '~>0.8.1', github: 'wildland/wildland_dev_tools'`

Typically for wildland projects you will want to put this inside the dev/test block:
```
group :development, :test do
  ...
  gem 'wildland_dev_tools', '~>0.8.1', github: 'wildland/wildland_dev_tools'`
  ...
end
```

### *[heroku tools](https://github.com/wildland/wildland_dev_tools#heroku-tools) require the following steps*

Install the heroku-toolbelt using brew. You can do this by running `brew install heroku`.

Have your `production` and `staging` git remotes set.
- `heroku git:remote -a <staging-app> -r staging` where `<staging-app>` is your heroku staging app name.
- `heroku git:remote -a <production-app> -r production` where `<production-app>` is your heroku production app name.


## Usage
You will get a new batch of new rake tasks under the wildland namespace. For a full list run `rake -T`.

### Local Development Tools
*Note that you will need to run `bundle install` before being able to use these.*
*Double Note: if `bundle install` borks on `pg_config` then set the `Pg_config path` with `bundle config build.pg --with-pg-config=/Applications/Postgres.app/Contents/Versions/{YOUR VERSION}/bin/pg_config`

- `rake wildland:setup` This will run all of the setup tasks to get your local enviroment ready to go.
- `rake wildland:db` This will resetup and seed the local database.
- `rake wildland:cache_clear` This will clear the local app-ember package cache.
- `rake wildland:pre_deploy` This will run all of the pre-deploy tasks to get the project ready to deploy.
- `rake wildland:pre_pr` Convenience alias to `rake wildland:pre_pull_request`.
- `rake wildland:pre_pull_request` This will run all of the pre pull request tasks to get the project ready for a pull request.

### Heroku Tools
- `rake wildland:heroku:deploy_to_staging` This will deploy `master` to `staging`. This will automatically create a release candidate git tag.
- `rake wildland:heroku:deploy_to_staging[verbose]` This perform the deploy as above, but in verbose mode.
- - `rake wildland:heroku:deploy_to_staging[verbose,force]` This perform the deploy as above, but this will `--force` deploy `master` to `staging`.
- - `rake wildland:heroku:deploy_current_branch_to_staging` This will promote your current branch to `staging` as `master`. This will **NOT** automatically create a release candidate git tag.
- - `rake wildland:heroku:deploy_current_branch_to_staging[verbose]` This perform the deploy as above, but in verbose mode.
- - `rake wildland:heroku:deploy_current_branch_to_staging[verbose,force]` This perform the deploy as above, but this will `--force` deploy your current branch to `staging`.
- `rake wildland:heroku:promote_to_production` This will promote `staging` to `production`. This will automatically create a production git tag.
- `rake wildland:heroku:promote_to_production[verbose]` This perform the deploy as above, but in verbose mode.
- `rake wildland:heroku:maintenance_mode_on` This turns on maintenance mode for `staging` and `production`.
- `rake wildland:heroku:maintenance_mode_off` This turns off maintenance mode for `staging` and `production`.
- `rake wildland:heroku:backup_production_database[verbose]` This will create a backup of the `production` database.
- `rake wildland:heroku:import_latest_production_database_backup[verbose]` This will import the latest `production` database backup to your local database.


## Code Of Conduct
Wildland Open Source [Code Of Conduct](https://github.com/wildland/code-of-conduct)
