namespace :wildland do
  desc 'Runs all the pre deploy tasks.'
  task :pre_deploy do
    Rake::Task['wildland:pre_deploy:all'].invoke
  end

  desc 'Legacy alias to ember build.'
  namespace :ember do
    task :build do
      warn "[DEPRECATION] `wildland:ember:build` is deprecated.  Please use `wildland:pre_deploy` instead."
      Rake::Task['wildland:pre_deploy:ember:build'].invoke
    end
  end

  namespace :pre_deploy do
    task all: [
      :ember
    ] do
      puts 'Deploy Check completed.'
    end

    namespace :ember do
      desc 'Builds Ember'
      task :build do
        EMBER_DIR = 'app-ember'
        Dir.chdir(EMBER_DIR) do
          sh './node_modules/.bin/ember build --environment=production'
        end

        sh 'rm -rf public.bak/'
        sh 'mv public/ public.bak/'
        sh 'mkdir public/'
        sh "cp -r #{EMBER_DIR}/dist/ public/"
        sh 'mv public/index.html public/ember.html'
      end
    end
  end
end

