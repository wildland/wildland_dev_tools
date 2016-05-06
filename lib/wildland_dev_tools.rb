require "wildland_dev_tools/version"

module WildlandDevTools
  require 'wildland_dev_tools/railtie' if defined?(Rails)
  require 'wildland_dev_tools/updater'
  require 'wildland_dev_tools/heroku'
end
