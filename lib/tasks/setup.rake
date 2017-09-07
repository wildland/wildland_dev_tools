require 'wildland_dev_tools/updater'

namespace :wildland do
  desc 'Updates local dependencies and database.'
  task setup: [:update_ruby, :update_node, :update_ember_dependencies, :database_online, :db] do
    puts 'Ready to go!'
  end

  task :update_ruby do
    needed_ruby_version = File.read('.ruby-version')
    if WildlandDevTools::Updater.ruby_version_up_to_date?(needed_ruby_version)
      puts 'Ruby up to date.'
    else
      puts 'Ruby out of date. Updating.'
      WildlandDevTools::Updater.update_ruby(needed_ruby_version)
    end
  end

  task :update_node do
    needed_node_version = File.read('.nvmrc')
    if WildlandDevTools::Updater.node_version_up_to_date?(needed_node_version)
      puts 'Node up to date.'
    else
      puts 'Node out of date. Updating.'
      WildlandDevTools::Updater.update_node(needed_node_version)
    end
  end

  task update_ember_dependencies: 'ember:install'

  desc 'Clears local cache.'
  task :cache_clear do
    WildlandDevTools::Updater.clear_ember_cache
  end

  task :database_online do
    unless `ps aux | grep postgres[l]` != ''
      `open -a postgres`
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
task :wildland do
  Rake::Task['wildland:setup'].invoke
end
