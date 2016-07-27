require 'wildland_dev_tools/releases'

namespace :wildland do
  namespace :releases, [:verbose] do
    desc 'Creates a git tag for the release.'
    task :create_release do
      WildlandDevTools::Releases.create_release(args[:verbose])
    end

    desc 'Creates a git tag for the release candidate.'
    task :create_release_candidate, [:verbose] do
      WildlandDevTools::Releases.create_release_candidate(args[:verbose])
    end
  end
end
