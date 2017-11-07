require 'wildland_dev_tools/heroku'

namespace :wildland do
  namespace :heroku do
    desc 'Imports the latest production database backup to local database.'
    task :import_latest_production_database_backup, [:verbose] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      WildlandDevTools::Heroku.import_production_database(args[:verbose])
      Rake::Task['db:migrate'].invoke
    end

    desc 'Imports the latest staging database backup to local database.'
    task :import_latest_staging_database_backup, [:verbose] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      WildlandDevTools::Heroku.import_staging_database(args[:verbose])
      Rake::Task['db:migrate'].invoke
    end

    desc 'Backups production database'
    task :backup_production_database, [:verbose] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      WildlandDevTools::Heroku.backup_production_database(args[:verbose])
    end

    desc 'Promotes staging to production. This automatically creates a production release tag.'
    task :promote_to_production, [:verbose] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      begin
        Rake::Task['wildland:heroku:maintenance_mode_on'].execute
        Rake::Task['wildland:releases:create_release_tag'].execute
        WildlandDevTools::Heroku.promote_staging_to_production(args[:verbose])
        WildlandDevTools::Heroku.migrate_production_database(args[:verbose])
        Rake::Task['wildland:heroku:maintenance_mode_off'].execute
      rescue RuntimeError => e
        puts e
        WildlandDevTools::Heroku.rollback_production_deploy(true)
        raise
      end
    end

    desc 'Deploy master to staging. This automatically creates a release candidate tag.'
    task :deploy_to_staging, [:verbose, :force] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      begin
        WildlandDevTools::Heroku.turn_on_staging_maintenance_mode(args[:verbose])
        Rake::Task['wildland:releases:create_release_candidate_tag'].execute
        WildlandDevTools::Heroku.deploy_master_to_staging(args[:verbose], args[:force])
        WildlandDevTools::Heroku.copy_production_data_to_staging(args[:verbose])
        WildlandDevTools::Heroku.migrate_staging_database(args[:verbose])
      rescue WildlandDevTools::GitSyncException => e
        puts e
      rescue RuntimeError => e
        puts e
        WildlandDevTools::Heroku.rollback_staging_deploy(true)
        raise
      ensure
        WildlandDevTools::Heroku.turn_off_staging_maintenance_mode(args[:verbose])
      end
    end

    desc 'Deploy current branch to staging as master. This does not create a release canidate tag.'
    task :deploy_current_branch_to_staging, [:verbose, :force] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      begin
        WildlandDevTools::Heroku.turn_on_staging_maintenance_mode(args[:verbose])
        WildlandDevTools::Heroku.deploy_current_branch_to_staging(args[:verbose], args[:force])
        WildlandDevTools::Heroku.copy_production_data_to_staging(args[:verbose])
        WildlandDevTools::Heroku.migrate_staging_database(args[:verbose])
      rescue WildlandDevTools::GitSyncException => e
        puts e
      rescue RuntimeError => e
        puts e
        WildlandDevTools::Heroku.rollback_staging_deploy(true)
        raise
      ensure
        WildlandDevTools::Heroku.turn_off_staging_maintenance_mode(args[:verbose])
      end
    end

    desc 'Deploy current branch to staging as master. This does not create a release canidate tag.'
    task :deploy_current_branch_to_staging_as_rc, [:verbose, :force] => [:check_remotes, :check_heroku] do |_t, args| # rubocop:disable Metrics/LineLength
      begin
        Rake::Task['wildland:releases:create_release_candidate_tag'].execute
        Rake::Task['wildland:heroku:deploy_current_branch_to_staging'].execute
      rescue WildlandDevTools::GitSyncException => e
        puts e
      end
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
          'Missing heroku toolbelt. Run \'brew install heroku-toolbelt\'.'
        )
      end
    end

    task :check_remotes do
      unless WildlandDevTools::Heroku.staging_remote_available?
        Kernel.abort(
          'Missing staging git remote. Run \'heroku git:remote -a <app-name> -r staging\'' # rubocop:disable Metrics/LineLength
        )
      end
      unless WildlandDevTools::Heroku.production_remote_available?
        Kernel.abort(
          'Missing production git remote. Run \'heroku git:remote -a <app-name> -r production\'' # rubocop:disable Metrics/LineLength
        )
      end
    end
  end
end
