require 'wildland_dev_tools/heroku'

namespace :wildland do
  namespace :heroku do
    desc 'Promotes staging to production.'
    task :promote_to_production, [:verbose] => [:check_remotes, :check_heroku]  do |t, args|
      begin
        Rake::Task['wildland:heroku:maintenance_mode_on'].execute
        WildlandDevTools::Heroku.backup_production_database(args[:verbose])
        WildlandDevTools::Heroku.promote_staging_to_production(args[:verbose])
        WildlandDevTools::Heroku.migrate_production_database(args[:verbose])
        Rake::Task['wildland:heroku:maintenance_mode_off'].execute
      rescue RuntimeError => e
        WildlandDevTools::Heroku.rollback_deploy(true)
        raise
      end
    end

    task :maintenance_mode_on do
      WildlandDevTools::Heroku.turn_on_heroku_maintenance_mode(true)
    end

    task :maintenance_mode_off do
      WildlandDevTools::Heroku.turn_off_heroku_maintenance_mode(true)
    end

    task :check_heroku do
      unless WildlandDevTools::Heroku.heroku_toolbelt_available?
        Kernal::abort('Missing heroku toolbelt')
      end
    end

    task :check_remotes do
      unless WildlandDevTools::Heroku.staging_remote_available?
        Kernal::abort('Missing staging git remote')
      end
      unless WildlandDevTools::Heroku.production_remote_available?
        Kernal::abort('Missing production git remote')
      end
    end
  end
end