require 'git'
require 'higline/import'
require 'json'

module WildlandDevTools
  # :nodoc:
  module Releases
    VALID_REMOTES = %w(production staging)
    VERSION_FILE_NAME = '.app-version.json'

    class << self
      def create_release(verbose = false)
        current_release_name = determine_new_release_name
      end

      def create_release_candidate(verbose = false)

      end

      protected

      def create_named_release(release_name, verbose = false)
        return false unless git_up_to_date!
      end

      def determine_new_release_name
        if File.file?(VERSION_FILE_NAME)
          create_app_version_release_name
        else
          create_date_release_name
        end
      end

      def create_app_version_release_name
        current_version = JSON.parse(File.read(VERSION_FILE_NAME))['version']
        major, minor, patch = current_version.split('.').map(&:to_int)
        new_version = HighLine.new.choose do |menu|
          menu.prompt "Current version: #{current_version}. How should we increment?"
          menu.choice(:major) { [major + 1, minor, patch].join('.') }
          menu.choice(:minor) { [major, minor + 1, patch].join('.') }
          menu.choice(:patch) { [major, minor, patch + 1].join('.') }
        end
        # Write back to file
      end

      def create_date_release_name
        DateTime.new.strftime("%Y-%m-%d")
      end

      def git_up_to_date!
        local = `OVERCOMMIT_DISABLE=1 git rev-parse @`
        remote = `OVERCOMMIT_DISABLE=1 git rev-parse @{u}`
        base = `OVERCOMMIT_DISABLE=1 git merge-base @ @{u}`
        case
        when local == remote
          return true
        when local == base
          raise GitSyncException, 'Need to pull master from origin.'
        when remote == base
          raise GitSyncException, 'Need to push master to origin.'
        else
          raise GitSyncException, 'Your local master has diverged from origin.'
        end
      end

      def ensure_valid_remote(remote)
        unless VALID_REMOTES.include?(remote)
          raise ArgumentError, "remote argument is required and must be %{VALID_REMOTES}"
        end
      end
    end
  end
end
