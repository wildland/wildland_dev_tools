require 'wildland_dev_tools/updater'

namespace :wildland do
  desc 'Updates libs and database'
  task :setup do
    # Checkout ruby and node versions
    print 'Checking ruby version... '
    needed_ruby_version = File.read('.ruby-version')
    unless WildlandDevTools::Updater.ruby_version_up_to_date?(needed_ruby_version)
      puts "out of date. Updating."
      WildlandDevTools::Updater.update_ruby(needed_ruby_version)
    else
      puts 'up to date.'
    end

    if WildlandDevTools::Updater.ember_cli_rails_installed?
      puts 'ember-cli-rails installed'
      system('npm install')
    else
      puts 'install ember dependencies'
      WildlandDevTools::Updater.old_ember_setup
    end
  end

  namespace :db do
    desc 'Resets the database.'
    task :reset do
      WildlandDevTools::Updater.reset_database
    end

    desc 'Reseeds the database.'
    task :reseed do
      WildlandDevTools::Updater.reseed_database
    end
  end

  desc 'Resets and reseeds the database.'
  task :db do
    Rake::Task['wildland:db:reset'].execute
    Rake::Task['wildland:db:reseed'].execute
  end
end

desc 'Gets development environment setup.'
task wildland: 'wildland:setup'
