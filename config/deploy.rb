# config valid only for Capistrano 3.1
lock '3.2.1'
require "whenever/capistrano"

set :application, 'translator'
#set :repo_url, "ssh://gitrepo@git.dhamma.org.au:8022/home/gitrepo/repositories/#{fetch(:application)}"
set :repo_url, "ssh://gitrepo@git.dhamma.org.au:22/home/gitrepo/repositories/#{fetch(:application)}"
#set :rvm1_ruby_version, "rbx-2.2.10"
set :rvm1_ruby_version, "ruby-2.2.3" #"ruby-2.1.3" #"ruby-2.2.1" #
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/home/calm/apps/#{fetch(:application)}"


# for all stages
set :rails_env, "production"
set :whenever_environment, 'production'
# added mpl
# only if you are using rvm directly, appaarently
#set :whenever_command, 'bundle exec whenever'
#set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
# allows deploying on 'whatever' server
#set :whenever_roles, [:all]
#set :whenever_command_environment_variables, ->{ {} }
set :whenever_roles,        ->{ :db }
set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
set :whenever_command_environment_variables, ->{ {} }
set :whenever_identifier,   ->{ fetch :application }
set :whenever_environment,  ->{ fetch :rails_env, fetch(:stage, "production") }
set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }

set :rake, "#{fetch(:rake)} --trace"
#set :rvm_type, :system    # :user is the default
set :rake, "#{fetch(:rake)} --trace" # debug when rake errors
#support/dependencies.rb:317:in `rescue in depend_on': No such file to load -- iconv (LoadError)
set :rvm_autolibs_flag, "read-only"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/database.yml config/puma.rb}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
#  namespace :assets do
#    task :precompile, :roles => assets_role, :except => { :no_release => true } do
#      run <<-CMD.compact
#        cd -- #{latest_release.shellescape} &&
#        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile
#      CMD
#    end
#  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')

      # todo
      # kill safely the running cron jobs so they get replaced with the newly deployed ones.

      invoke 'deploy:stop'
      invoke 'deploy:start'
    end
  end

  # after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc 'Stop application'
  task :stop do
    on roles :app, in: :sequence, wait: 1 do
      execute "rm -f #{current_path}/public/maintenance.html"
      execute "ln -s #{current_path}/public/maintenance.html.template #{current_path}/public/maintenance.html"
      begin
        execute :sudo, "stop puma app=#{current_path}"
      rescue
        # it may already be stopped!
      end
    end

  end

  # This can be done manually on server with
  # cd ~/apps/atlist/current
  # bundle exec puma -C config/puma.rb -e production
  desc 'Start application'
  task :start do
    on roles :app, in: :sequence, wait: 5 do
      execute :sudo, "start puma app=#{current_path}"
      sleep 10 # seconds. Show maintenance page while puma is starting up
      execute "rm -f #{current_path}/public/maintenance.html"
    end
  end

  desc 'Get run status of application'
  task :status do
    on roles :app, in: :sequence, wait: 1 do
      begin
        execute :sudo, "status puma app=#{current_path}"
      rescue
        puts "Puma is not running, so it seems."
      end
    end
  end

  desc 'Trust MPAPIS so we can install rvm in the next step - see https://github.com/wayneeseguin/rvm/issues/3110'
  before 'deploy', :trust_rvm_install do
    on roles :app, in: :sequence, wait: 1 do
      execute "gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
    end
  end

  before 'deploy', 'rvm1:install:rvm' # install/update RVM
  
  after :publishing, 'rvm1:install:gems' # install/update gems from Gemfile into gemset

  after :publishing, :restart


end
