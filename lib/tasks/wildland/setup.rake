# frozen_string_literal: true

namespace :wildland do
  desc 'Resets the database, seeds the demo data, and installs frontend dependencies'
  task :setup, [:environment] => ['db:reset', 'demo:seed', 'frontend:npm_install'] do
    puts 'Ready to go!'
  end
end

task :wildland do
  Rake::Task['wildland:setup'].invoke
end
