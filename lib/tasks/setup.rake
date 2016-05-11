require 'wildland_dev_tools/updater'

namespace :wildland do
  desc 'Updates local dependencies and database.'
  task :setup => [:update_ruby, :update_node, :update_ember_dependencies, :db] do
    puts 'Ready to go!'
  end

  task :update_ruby do
    needed_ruby_version = File.read('.ruby-version')
    unless WildlandDevTools::Updater.ruby_version_up_to_date?(needed_ruby_version)
      puts "out of date. Updating."
      WildlandDevTools::Updater.update_ruby(needed_ruby_version)
    else
      puts 'up to date.'
    end
  end

  task :update_node do
    puts 'Node updater needs written'
  end

  task :update_ember_dependencies do
    if WildlandDevTools::Updater.ember_cli_rails_installed?
      puts 'ember-cli-rails installed'
      system('npm install')
    else
      puts 'install ember dependencies'
      WildlandDevTools::Updater.old_ember_setup
    end
  end

  desc 'Clears local cache.'
  task :cache_clear do
    WildlandDevTools::Updater.clear_ember_cache
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
task :wildland do
  Rake::Task['wildland:setup'].invoke
end