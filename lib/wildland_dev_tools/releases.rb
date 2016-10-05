require 'json'

module WildlandDevTools
  # :nodoc:
  module Releases
    VALID_REMOTES = %w(production staging)

    class << self
      def create_release(verbose = false)
        return false unless git_up_to_date!
        tag_name = "PRODUCTION-#{base_tag_name}"
        create_and_push_tag(tag_name, verbose)
      end

      def create_release_candidate(verbose = false)
        return false unless git_up_to_date!
        tag_name = "RC-#{base_tag_name}"
        create_and_push_tag(tag_name, verbose)
      end

      protected

      def create_and_push_tag(tag_name, verbose = false)
        puts "Creating tag #{tag_name}" if verbose
        system("OVERCOMMIT_DISABLE=1 git tag #{tag_name}")
        system("OVERCOMMIT_DISABLE=1 git push origin #{tag_name}")
      end

      def base_tag_name
        DateTime.now.strftime("%y-%m-%d-%H-%M")
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
    end
  end
end
