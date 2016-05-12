module WildlandDevTools
  # :nodoc:
  module Updater
    class << self
      def reset_database
        system('rake db:drop')
        system('rake db:create')
        system('rake db:migrate')
        system('annotate') if system('which annotate > /dev/null 2>&1')
      end

      def reseed_database
        system('rake db:seed')
        system('rake demo:seed')
      end

      def ruby_version_up_to_date?(needed_ruby_version)
        ruby_version = `ruby -v`
        ruby_version.include?(needed_ruby_version)
      end

      def update_ruby(version)
        case
        when system('which rvm > /dev/null 2>&1')
          update_ruby_with_rvm(version)
        when system('which rbenv > /dev/null 2>&1')
          update_ruby_with_rbenv(version)
        else
          puts "Please manually update to Ruby #{version}"
        end
      end

      def update_ruby_with_rvm(version)
        # Try to use the version or install and use
        system("rvm use #{version}")
        unless ruby_version_up_to_date?(version)
          system("rvm install #{version}")
          system("rvm use #{version}")
        end
      end

      def update_ruby_with_rbenv(_version)
        puts 'rbenv updater not written.'
      end

      def ember_cli_rails_installed?
        File.exist?('bin/heroku_install') && File.exist?('package.json')
      end

      def old_ember_setup
        Dir.chdir('app-ember') do
          system('npm install')
          system('bower install')
        end
      end

      def clear_ember_cache
        Dir.chdir('app-ember') do
          system('npm cache clean && bower cache clean')
          system('rm -rf node_modules && rm -rf bower_components')
          system('npm install && bower install')
        end
      end
    end
  end
end
