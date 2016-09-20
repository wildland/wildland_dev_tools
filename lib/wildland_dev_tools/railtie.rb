require 'wildland_dev_tools'
require 'rails'
module MyPlugin
  # :nodoc:
  class Railtie < Rails::Railtie
    railtie_name :wildland_dev_tools

    rake_tasks do
      load 'tasks/heroku.rake'
      load 'tasks/reports.rake'
      load 'tasks/setup.rake'
      load 'tasks/releases.rake'
    end
  end
end
