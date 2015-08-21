namespace :wildland do
  desc 'Updates libs and database'
  task :setup do
    # Checkout ruby and node versions

    print 'Checking ruby version... '
    needed_ruby_version = File.read('.ruby-version')
    unless ruby_version_up_to_date?(needed_ruby_version)
      puts "out of date. Updating."
      update_ruby(needed_ruby_version)
    else
      puts 'up to date.'
    end

    Dir.chdir('app-ember') do
      system('npm install')
      system('bower install')
    end
    system('rake db:create')
    system('rake db:migrate')
    system('rake db:setup')
    system('rake demo:seed')
  end
end

desc 'Gets development environment setup.'
task wildland: 'wildland:setup'

def ruby_version_up_to_date?(needed_ruby_version)
  ruby_version = `ruby -v`
  ruby_version.include?(needed_ruby_version)
end

def update_ruby(version)
  case
  when system("which rvm > /dev/null 2>&1")
    update_ruby_with_rvm(version)
  when system("which rbenv > /dev/null 2>&1")
    update_ruby_with_rbenv(version)
  else
    puts "No ruby manager installed. Please manually update to Ruby #{version}"
  end
end

def update_ruby_with_rvm(version)
  # Try to use the version or install and use
  system("rvm use #{version}")
  unless ruby_version_up_to_date?(version)
    system("rvm install #{version}")
    system("rvm use #{version}")
  end
end

def update_ruby_with_rbenv(version)
  puts 'rbenv updater not written.'
end
