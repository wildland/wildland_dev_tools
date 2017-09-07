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

      def node_version_up_to_date?(needed_version)
        current_version = `node -v`
        current_version.include?(needed_version.strip)
      end

      def update_node(version)
        # Try to use the version or install and use
        system("nvm use #{version}")
        unless node_version_up_to_date?(version)
          system("nvm install #{version}")
          system("nvm use #{version}")
        end
      end

      def ruby_version_up_to_date?(needed_version)
        current_version = `ruby -v`
        current_version.include?(needed_version.strip)
      end

      def update_ruby(version)
        case
        when system('which rvm > /dev/null 2>&1')
          warn "[DEPRECATION] `rvm` is deprecated.  Please use `rbenv` to manage ruby versions instead."
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

      def update_ruby_with_rbenv(version)
        system('brew upgrade rbenv ruby-build')
        system("rbenv install #{version}")
        system("rbenv rehash")
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
