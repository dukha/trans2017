require 'bundler/capistrano'
set :rake, "#{rake} --trace"
set :application, "translator"
# this is the integration repo
set :repository,  "ssh://gitrepo@tools.calm.dhamma-eu.org/home/gitrepo/repositories/translator"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# the we server, db and app are all on the same server
role :web, "calm4test.dhamma.org.au"                          # Your HTTP server, Apache/etc
role :app, "calm4test.dhamma.org.au"                          # This may be the same as your `Web` server
role :db,  "calm4test.dhamma.org.au", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :deploy_to,       "/home/calm/wwwshare/translator"
set :user,            "calm"
set :use_sudo,        false
set :ssh_options,     { :forward_agent => true }

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
set :deploy_via, :remote_cache
# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts


set :default_environment, {
  #'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p290/bin:   /path/to/.rvm/bin  : /path/to/.rvm/ree-1.8.7-2009.10/bin :$PATH",
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.2-p290/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ruby-1.9.2-p290/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.2-p290',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.2-p290',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.2-p290',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.2-p290'  # If you are using bundler.
}

after 'deploy:setup', :create_configs
desc 'Create the shared/config dir for various config files'
# database.yml does not come from repo so make it now
task :create_configs do
  run "mkdir -p #{shared_path}/config"
  run "touch #{shared_path}/config/database.yml"
end

after 'deploy:finalize_update', :update_configs
desc 'Copy the shared config files to the release config dir'
task :update_configs do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config"
end

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
   # start and stop. Nothing to do
   task :start do ; end
   task :stop do ; end
   # Use restart
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end