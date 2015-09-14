# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Learn more: http://github.com/javan/whenever

# =======================================
# debugging this script in development
# =======================================
# to show what it would do:
#   bundle exec whenever --set 'environment=development'
# 
# to set up development jobs
#   bundle exec whenever --set 'environment=development' --update-crontab

# =======================================
# running this script in production
# =======================================
# In production it will be done by capistrano according to deploy.rb
puts "In schedule"
#binding.pry
set :output, "#{path}/log/cron.log"
puts "In schedule with path = " + output
# example 1
# every 15.minutes do
#   command "rm '#{path}/tmp/cache/foo.txt'"
# end

# example 2
# every :sunday, at: "4:22 AM" do
#  runner "Cart.clear_abandoned"
# end

# will use environment production.
# not reliable
#every :reboot do
#  #rake 'pform_queue:receive'
#  rake 'background:import_calm3_courses'
#end

# PROCESSING BACKGROUND JOBS
# 1. background 
# run the cron job only for production
# for development run the task manually as required
# rake jobs:work
#
# This method ensures the task gets restarted at the latest 1 minute after it failed for some reason
#
if environment == 'production'
  every 1.minutes, :roles => [:db] do
    command "cd #{path} && /usr/local/bin/lockrun --idempotent --lockfile=/tmp/delayed_jobs.lockrun -- nice --adjustment=10 bundle exec rake jobs:work RAILS_ENV=production"
  end
end
