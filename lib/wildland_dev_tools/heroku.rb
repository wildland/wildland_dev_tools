require 'git'
module WildlandDevTools
  # :nodoc:
  module Heroku
    class << self
      def rollback_deploy(verbose = false)
        rollback_codebase(verbose)
        rollback_database(verbose)
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
        remote = 'production'
        puts "Migrating the database for #{remote}" if verbose
        system("heroku run rake db:migrate -r #{remote}")
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

      def rollback_codebase(verbose = false)
        remote = 'production'
        puts "Rolling back #{remote}" if verbose
        system("heroku rollback #{remote}")
      end

      def rollback_database(verbose = false)
        remote = 'production'
        if verbose
          puts "Manually restore database for #{remote}"
          puts 'Then run \"rake wildland:heroku:maintenance_mode_off\"'
        end
      end
    end
  end
end
