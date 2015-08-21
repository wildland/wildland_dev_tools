namespace :wildland do
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

