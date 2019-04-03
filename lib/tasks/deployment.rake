namespace :deploy do
  desc 'Deploys current branch to staging as an RC'
  task staging: :environment do # Check that git is clean
    HighLine.new.tap do |cli|
      if cli.agree('Create a new release?')
        cli.ask(
          'What is the version of this release? (vX.XX)'
        ).tap do |tag_name|
          sh("OVERCOMMIT_DISABLE=1 git tag #{tag_name}") # TODO Change to git gem
          sh("OVERCOMMIT_DISABLE=1 git push origin #{tag_name}")
        end
        Rake::Task['release:update'].invoke
      end
    end
    sh 'staging maintenance:on'
    sh 'production backup'
    sh 'staging deploy'
    sh 'staging restore-from production'
    sh 'staging migrate' # Required to migrate data restored from production
    sh 'staging maintenance:off'
    sh 'staging restart'
    sh 'staging run rake xero:convert_production'
    sh 'staging run rake stripe:convert_production'
  end

  namespace :production do
    desc 'Promotes the current staging deploy to production with a zero downtime deploy (using pre-boot)'
    task zero_downtime: :environment do
      HighLine.new.tap do |cli|
        unless cli.agree(
          'Do you want to do a zero downtime deploy to staging?'
        ) { |q| q.confirm = true }
          abort 'Did not agree to the deploy'
        end
        if cli.agree('Does your deploy require a migration?')
          abort 'Unable to do zero downtime deploys with migrations'
        end
        sh 'production features:enable preboot'
        sh 'staging pipelines:promote'
        sh 'production features:disable preboot'
      end
    end
  end

  task :check_for_parity do
    # https://github.com/thoughtbot/parity#install
  end
end
