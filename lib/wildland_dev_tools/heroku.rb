require 'git'
module WildlandDevTools
  # :nodoc:
  module Heroku
    VALID_REMOTES = %w(production staging)

    class << self
      def rollback_production_deploy(verbose = false)
        rollback_production_codebase(verbose)
        rollback_production_database(verbose)
      end

      def turn_on_heroku_maintenance_mode(verbose = false)
        %w(staging production).each do |remote|
          puts "Turning on maintenance mode for #{remote}" if verbose
          system("heroku maintenance:on -r #{remote}")
        end
      end

      def turn_off_heroku_maintenance_mode(verbose = false)
        %w(staging production).each do |remote|
          puts "Turning off maintenance mode for #{remote}" if verbose
          system("heroku maintenance:off -r #{remote}")
        end
      end

      def deploy_master_to_staging(verbose = false)
        case status_of_master_branch
        when 'Up-to-date'
          puts 'Deploying to staging.' if verbose
          system('git push staging master')
        when 'Need to pull'
          raise GitSyncException, 'Need to pull master from origin.'
        when 'Need to push'
          raise GitSyncException, 'Need to push master to origin.'
        else
          raise GitSyncException, 'Your local master has diverged from origin.'
        end
      end

      def copy_production_data_to_staging(verbose = false)
        puts 'Determining heroku app names.' if verbose
        staging_app_name = get_app_name('staging', verbose)
        production_app_name = get_app_name('production', verbose)
        puts "Copying #{production_app_name} database to #{staging_app_name}." if verbose
        system(
          "heroku pg:copy #{production_app_name}::DATABASE_URL DATABASE_URL -a #{staging_app_name} --confirm #{staging_app_name}"
        )
      end

      def backup_production_database(verbose = false)
        remote = 'production'
        puts "Backing up the database for #{remote}" if verbose
        system("heroku pg:backups capture DATABASE -r #{remote}")
      end

      def promote_staging_to_production(verbose = false)
        puts 'Promoting staging to production' if verbose
        system('heroku pipelines:promote -r staging')
      end

      def migrate_production_database(verbose = false)
        migrate_database('production', verbose)
      end

      def migrate_staging_database(verbose = false)
        migrate_database('staging', verbose)
      end

      def rollback_production_database(verbose = false)
        rollback_codebase('production', verbose)
      end

      def rollback_staging_database(verbose = false)
        rollback_database('staging', verbose)
      end

      def staging_remote_available?
        Git.open('.').remotes.map(&:to_s).include?('staging')
      end

      def production_remote_available?
        Git.open('.').remotes.map(&:to_s).include?('production')
      end

      def heroku_toolbelt_available?
        system('which heroku > /dev/null 2>&1')
      end

      protected

      def rollback_codebase(remote, verbose = false)
        ensure_valid_remote(remote)
        puts "Rolling back #{remote}" if verbose
        system("heroku rollback #{remote}")
      end

      def rollback_database(remote, verbose = false)
        ensure_valid_remote(remote)
        if verbose
          puts "Manually restore database for #{remote}"
          puts 'Then run \"rake wildland:heroku:maintenance_mode_off\"'
        end
      end

      def migrate_database(remote, verbose = false)
        ensure_valid_remote(remote)
        puts "Migrating the database for #{remote}" if verbose
        system("heroku run rake db:migrate -r #{remote}")
      end

      def status_of_master_branch
        local = `git rev-parse @`
        remote = `git rev-parse @{u}`
        base = `git merge-base @ @{u}`
        case
        when local == remote
          'Up-to-date'
        when local == base
          'Need to pull'
        when remote == base
          'Need to push'
        else
          'Diverged'
        end
      end

      def get_app_name(remote, verbose = false)
        response = `heroku apps:info -r #{remote}`
        response.split(/\r?\n/).first[4..-1] # This is brittle
      end

      def ensure_valid_remote(remote)
        unless VALID_REMOTES.include?(remote)
          raise ArgumentError, "remote argument is required and must be %{VALID_REMOTES}"
        end
      end
    end
  end
end
