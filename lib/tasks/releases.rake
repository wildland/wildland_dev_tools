require 'wildland_dev_tools/releases'

namespace :wildland do
  namespace :releases do
    desc 'Creates a git tag for the release.'
    task :create_release_tag, [:verbose] do |_t, args|
      WildlandDevTools::Releases.create_release(args[:verbose])
    end

    desc 'Creates a git tag for the release candidate.'
    task :create_release_candidate_tag, [:verbose] do |_t, args|
      WildlandDevTools::Releases.create_release_candidate(args[:verbose])
    end
  end
end
