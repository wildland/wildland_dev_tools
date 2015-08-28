# WildlandDevTools
This is a gem that contains all of our dev rake tasks.

## Installation

Add the following to your `Gemfile`:

`gem 'wildland_dev_tools', '~>0.1.0', git: 'https://github.com/wildland/wildland_dev_tools.git'`

Typically for wildland projects you will want to put this inside the dev/test block:
```
group :development, :test do
  ...
  gem 'wildland_dev_tools', '~>0.1.0',  git: 'https://github.com/wildland/wildland_dev_tools.git'
  ...
end
```

## Usage
You will get a new batch of new rake tasks under the wildland namespace. For a full list run `rake -T`.

*Note that you will need to run `bundle install` before being able to use these.*

- `rake wildland:setup` This will run all of the setup tasks to get your local enviroment ready to go.
- `rake wildland:pre_deploy` This will run all of the pre-deploy tasks to get the project ready to deploy.
- `rake wildland:pre_pr` Convenience alias to `rake wildland:pre_pull_request`.
- `rake wildland:pre_pull_request` This will runn all of the pre pull request tasks to get the project ready for a pull request.

## Code Of Conduct
Wildland Open Source [Code Of Conduct](https://github.com/wildland/code-of-conduct)
