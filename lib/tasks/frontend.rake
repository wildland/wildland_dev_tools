# frozen_string_literal: true

namespace :frontend do
  desc 'Installs the frontend packages with npm and correct version of node.'
  task npm_install: :environment do
    puts 'Running frontend:npm_install'
    node_version = Dir.chdir('./') { `node -v` }
    puts "Using node version #{node_version}"
    Dir.chdir('./app-ember') { `npm install` }
  end
end
