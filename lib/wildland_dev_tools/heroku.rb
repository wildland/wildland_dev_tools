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
          if remote_available? remote
            puts "Turning on maintenance mode for #{remote}" if verbose
            system("heroku maintenance:on -r #{remote}")
          end
        end
      end

      def turn_off_heroku_maintenance_mode(verbose = false)
        %w(staging production).each do |remote|
          if remote_available? remote
            puts "Turning off maintenance mode for #{remote}" if verbose
            system("heroku maintenance:off -r #{remote}")
          end
        end
      end

      def deploy_master_to_staging(verbose = false, force = false)
        puts 'Detecting current branch name.' if verbose
        raise GitSyncException, 'Please checkout master branch' unless on_master_branch?
        deploy_to_staging(get_current_branch_name, verbose, force)
      end


      def deploy_current_branch_to_staging(verbose = false, force = false)
        puts 'Detecting current branch name.' if verbose
        deploy_to_staging(get_current_branch_name, verbose, force)
      end

      def deploy_to_staging(branch, verbose = false, force = false)
        case status_of_current_branch
        when 'Up-to-date'
          if force
            puts "Force deploying #{branch} to staging." if verbose
            system("OVERCOMMIT_DISABLE=1 git push -f staging #{branch}:master")
          else
            puts "Deploying #{branch} to staging." if verbose
            system("OVERCOMMIT_DISABLE=1 git push staging #{branch}:master")
          end
        when 'Need to pull'
          raise GitSyncException, "Need to pull #{branch} from origin."
        when 'Need to push'
          raise GitSyncException, "Need to push #{branch} to origin."
        else
          raise GitSyncException, "Your local #{branch} has diverged from origin."
        end
      end

      def promote_staging_to_production(verbose = false)
        puts 'Promoting staging to production' if verbose
        system('heroku pipelines:promote -r staging')
      end

      def import_production_database(verbose = false)
        puts 'Determining heroku app names.' if verbose
        production_app_name = get_app_name('production', verbose)
        scratch_file_name = 'latest.dump'
        database_name = Rails.configuration.database_configuration['development']['database']
        download_database(production_app_name, scratch_file_name, verbose)
        import_database(database_name, scratch_file_name, verbose)
        File.delete(scratch_file_name)
      end

      def import_staging_database(verbose = false)
        puts 'Determining heroku app names.' if verbose
        staging_app_name = get_app_name('staging', verbose)
        scratch_file_name = 'latest.dump'
        database_name = Rails.configuration.database_configuration['development']['database']
        download_database(staging_app_name, scratch_file_name, verbose)
        import_database(database_name, scratch_file_name, verbose)
        File.delete(scratch_file_name)
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
        remote_available? 'staging'
      end

      def production_remote_available?
        remote_available? 'production'
      end

      def remote_available?(remote_name)
        Git.open('.').remotes.map(&:to_s).include?(remote_name)
      end

      def heroku_toolbelt_available?
        system('which heroku > /dev/null 2>&1')
      end

      protected

      def download_database(app_name, filename, verbose = false)
        puts "Downloading #{app_name} database to tmp file #{filename}" if verbose
        system(
          "curl -o #{filename} `heroku pg:backups:public-url --app #{app_name}`"
        )
      end

      def import_database(database_name, filename, verbose = false)
        puts "Importing #{filename} to #{database_name}" if verbose
        system(
          "pg_restore --clean --no-owner --no-acl --dbname=#{database_name} #{filename}"
        )
      end

      def rollback_codebase(remote, verbose = false)
        ensure_valid_remote(remote)
        puts "Rolling back #{remote}" if verbose
        system("heroku rollback #{remote}")
      end

      def rollback_database(remote)
        ensure_valid_remote(remote)
        puts "Manually restore database for #{remote}"
        puts 'Then run \"rake wildland:heroku:maintenance_mode_off\"'
      end

      def migrate_database(remote, verbose = false)
        ensure_valid_remote(remote)
        puts "Migrating the database for #{remote}" if verbose
        system("heroku run rake db:migrate -r #{remote}")
      end

      def status_of_current_branch
        local = `OVERCOMMIT_DISABLE=1 git rev-parse @`
        remote = `OVERCOMMIT_DISABLE=1 git rev-parse @{u}`
        base = `OVERCOMMIT_DISABLE=1 git merge-base @ @{u}`
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

      def get_current_branch_name
        `git rev-parse --abbrev-ref HEAD`.strip # TODO swap to ruby-git
      end

      def on_master_branch?
        on_branch? 'master'
      end

      def on_branch?(branch_name)
        get_current_branch_name == branch_name
      end

      def get_app_name(remote, verbose = false)
        ensure_valid_remote(remote)
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
