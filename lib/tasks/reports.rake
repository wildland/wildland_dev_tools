namespace :wildland do
  desc 'Runs all the pre pull request tasks.'
  task :pre_pull_request do
    Rake::Task['wildland:pre_pull_request:all'].invoke
  end
  desc 'Alias to pre pull request.'
  task :pre_pr do
    Rake::Task['wildland:pre_pull_request'].invoke
  end
  namespace :pre_pull_request do
    task all: [
      :notes,
      :fixme_notes,
      :ruby_debugger,
      :js_debugger,
      :rubocop_recent
    ] do
      puts 'PR Check completed.'
    end

    desc 'Run brakeman & rubocop with html formats and save them to /reports'
    task :html do
      system 'bundle exec rubocop -RDf progress -f html -o reports/rubocop.html'
      system 'bundle exec brakeman -o reports/brakeman.html'
    end

    desc 'Create a report on all notes'
    task :notes do
      puts "\nCollecting all of the standard code notes..."
      system 'bin/rake notes'
      puts "\nCollecting all HACK code notes..."
      system 'bin/rake notes:custom ANNOTATION=HACK'
      puts "\nCollecting all spec code notes..."
      system "grep -rnE 'OPTIMIZE:|OPTIMIZE|FIXME:|FIXME|TODO:|TODO|HACK:|HACK'"\
             ' spec'
    end

    desc 'Print only FIXME notes'
    task :fixme_notes do
      puts "\nFIXME Notes:"
      system 'bin/rake notes:fixme'
      system "grep -rnE 'FIXME:|FIXME'"\
             ' spec'
      system "grep -rnE 'FIXME:|FIXME'"\
             ' app/views'
    end

    desc 'Find ruby debugger statements.'
    task :ruby_debugger do
      puts "\nRuby debuggers:"
      %w(binding.pry puts).each do |debugger|
        %w(app/).each do |dir|
          system "grep -rnE '#{debugger}' #{dir}"
        end
      end
    end

    desc 'Find js debugger statements.'
    task :js_debugger do
      puts "\nJS debuggers:"
      %w(debugger).each do |debugger|
        %w(app-ember/app).each do |dir|
          system "grep -rnE '#{debugger}' #{dir}"
        end
      end
    end

    desc 'Run rubocop against all created/changed ruby files'
    task :rubocop_recent, [:autocorrect] do |_t, args|
      puts 'Running rubocop...'
      require 'rubocop'

      module RuboCop
        # :nodoc:
        class TargetFinder
          def find(_args)
            changed_git_files = `git diff --name-only --cached`.split(/\n/)

            rubocop_target_finder = RuboCop::TargetFinder.new(
              RuboCop::ConfigStore.new
            )
            rubocop_config_store = RuboCop::ConfigStore.new
            rubocop_base_config = rubocop_config_store.for(
              File.expand_path(__dir__)
            )

            files_to_check = changed_git_files.select do |file|
              rubocop_target_finder.to_inspect?(file, [], rubocop_base_config)
            end

            files_to_check
          end
        end
      end

      if args[:autocorrect]
        exit RuboCop::CLI.new.run(['-aD'])
      else
        exit RuboCop::CLI.new.run(['-D'])
      end
    end
  end
end
