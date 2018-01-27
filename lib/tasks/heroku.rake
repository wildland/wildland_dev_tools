require 'wildland_dev_tools/heroku'
require 'highline'

namespace :wildland do
  namespace :heroku do
    desc 'Imports the latest production database backup to local database.'
    task :import_latest_production_database_backup, [:verbose] => [:check_production_remote, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      WildlandDevTools::Heroku.import_production_database(args[:verbose])
      Rake::Task['db:migrate'].invoke
    end

    desc 'Imports the latest staging database backup to local database.'
    task :import_latest_staging_database_backup, [:verbose] => [:check_staging_remote, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      WildlandDevTools::Heroku.import_staging_database(args[:verbose])
      Rake::Task['db:migrate'].invoke
    end

    desc 'Backups production database'
    task :backup_production_database, [:verbose] => [:check_production_remote, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      WildlandDevTools::Heroku.backup_production_database(args[:verbose])
    end

    desc 'Copys the production database to staging'
    task :copy_production_database_to_staging, [:verbose] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      Rake::Task['wildland:heroku:maintenance_mode_on'].execute
      WildlandDevTools::Heroku.copy_production_data_to_staging(args[:verbose])
      WildlandDevTools::Heroku.migrate_staging_database(args[:verbose])
    ensure
      Rake::Task['wildland:heroku:maintenance_mode_off'].execute
    end

    desc 'Promotes staging to production. This automatically creates a production release tag.'
    task :promote_to_production, [:verbose] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      Rake::Task['wildland:heroku:maintenance_mode_on'].execute
      Rake::Task['wildland:releases:create_release_tag'].execute
      WildlandDevTools::Heroku.promote_staging_to_production(args[:verbose])
      WildlandDevTools::Heroku.migrate_production_database(args[:verbose])
      Rake::Task['wildland:heroku:maintenance_mode_off'].execute
    rescue RuntimeError => e
      puts e
      WildlandDevTools::Heroku.rollback_production_deploy(true)
      raise
    ensure
      Rake::Task['wildland:heroku:maintenance_mode_off'].execute
    end

    desc 'Deploy master to staging. This automatically creates a release candidate tag.'
    task :deploy_to_staging, [:verbose, :force] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      Rake::Task['wildland:heroku:maintenance_mode_on'].execute
      Rake::Task['wildland:releases:create_release_candidate_tag'].execute
      WildlandDevTools::Heroku.deploy_master_to_staging(args[:verbose], args[:force])
      if WildlandDevTools::Heroku.production_remote_available?
        WildlandDevTools::Heroku.copy_production_data_to_staging(args[:verbose])
        WildlandDevTools::Heroku.migrate_staging_database(args[:verbose])
      end
    rescue WildlandDevTools::GitSyncException => e
      puts e
    rescue RuntimeError => e
      puts e
      WildlandDevTools::Heroku.rollback_staging_deploy(true)
      raise
    ensure
      Rake::Task['wildland:heroku:maintenance_mode_off'].execute
    end

    desc 'Deploy current branch to staging as master. This does not create a release canidate tag.'
    task :deploy_current_branch_to_staging, [:verbose, :force] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      Rake::Task['wildland:heroku:maintenance_mode_on'].execute
      WildlandDevTools::Heroku.deploy_current_branch_to_staging(args[:verbose], args[:force])
      if WildlandDevTools::Heroku.production_remote_available?
        WildlandDevTools::Heroku.copy_production_data_to_staging(args[:verbose])
        WildlandDevTools::Heroku.migrate_staging_database(args[:verbose])
      end
    rescue WildlandDevTools::GitSyncException => e
      puts e
    rescue RuntimeError => e
      puts e
      WildlandDevTools::Heroku.rollback_staging_deploy(true)
      raise
    ensure
      Rake::Task['wildland:heroku:maintenance_mode_off'].execute
    end

    desc 'Deploy current branch to staging as master. This does not create a release canidate tag.'
    task :deploy_current_branch_to_staging_as_rc, [:verbose, :force] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      Rake::Task['wildland:releases:create_release_candidate_tag'].execute
      Rake::Task['wildland:heroku:deploy_current_branch_to_staging'].execute
    rescue WildlandDevTools::GitSyncException => e
      puts e
    end

    desc 'Turns on maintenance mode for both heroku remotes.'
    task :maintenance_mode_on do
      WildlandDevTools::Heroku.turn_on_heroku_maintenance_mode(true)
    end

    desc 'Turns off maintenance mode for both heroku remotes.'
    task :maintenance_mode_off do
      WildlandDevTools::Heroku.turn_off_heroku_maintenance_mode(true)
    end

    task :check_heroku do
      unless WildlandDevTools::Heroku.heroku_toolbelt_available?
        Kernel.abort(
          'Missing heroku toolbelt. See \'https://devcenter.heroku.com/articles/heroku-cli\'.'
        )
      end
    end

    task :check_remotes => [:check_staging_remote, :check_production_remote]

    task :check_staging_remote do |t, args|
      ask = args[:force] || args[:verbose] || false
      manual_override = false
      unless WildlandDevTools::Heroku.staging_remote_available?
        if ask
          cli = HighLine.new
          cli.choose do |menu|
            menu.prompt = "Staging remote not found. Try to continue anyways? "
            menu.choice(:yes) do 
              cli.say("Trying to continue.")
              manual_override = true
            end
            menu.choice(:no)
            menu.default = :no
          end
        end
        Kernel.abort(
          'Missing staging git remote. Run \'heroku git:remote -a <app-name> -r staging\'' # rubocop:disable Metrics/LineLength
        ) unless manual_override
      end
    end

    task :check_production_remote do |t, args|
      ask = args[:force] || args[:verbose] || false
      manual_override = false
      unless WildlandDevTools::Heroku.production_remote_available?
        if ask
          cli = HighLine.new
          cli.choose do |menu|
            menu.prompt = "Production remote not found. Try to continue anyways? "
            menu.choice(:yes) do 
              cli.say("Trying to continue.")
              manual_override = true
            end
            menu.choice(:no)
            menu.default = :no
          end
        end
        Kernel.abort(
          'Missing production git remote. Run \'heroku git:remote -a <app-name> -r production\'' # rubocop:disable Metrics/LineLength
        ) unless manual_override
      end
    end
  end
end
