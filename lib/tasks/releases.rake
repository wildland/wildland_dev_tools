unless Rails.env.production?
  require 'git'
  require 'highline'

  namespace :release do
    desc 'Update the .release_version file with the latest git information'
    task :update do
      version_file_name = "#{Rails.root}/.release_version"
      git = Git.open(Dir.pwd)
      File.open(version_file_name, 'w') do |file|
        file.write git.describe(nil, always: true, tags: true, long: true)
      end
    end
  end
end
