class BaseJob < ActiveJob::Base
#@@last_job =  Time.now
@@time_last_job_failure = Time.now
@@failures_in_hour = 0

=begin
 def time_last
   @@time_last_job_failure
 end
 def time_last time
   @@time_last_job_failure = time
 end
 def failure_count
   @@failures_in_hour
 end
 def failure_count int
   if @@failures_in_hour.nil?
     @@failures_in_hour = int
   else
     @@failures_in_hour = @@failures_in_hour + int
   end
 end
=end
 
  before_perform do |job|
    # mailgun only allows 300 jobs per hour so in the case of a lot of generated tasks which go wrong, we space them out  
=begin    
    time_interval = @@last_job - Time.now
    if time_interval < 10
      puts "Waiting to start job: " + job.class.name + " in #{time_interval.to_s} secs."
      @@last_job = @@last_job + 10.seconds
      sleep 10       
    end 
=end     
    msg =  "Starting job: " + job.class.name
    info msg
  end
  
  after_perform do |job|
    msg = "Ending job: " + job.class.name
    info msg
  end  
  
  def exception_raised
    #@@time_last_job_failure = Time.now
    @@failures_in_hour = (@@failures_in_hour + 1)
    if @@failures_in_hour >= 290
      wait = (Time.now + 300.seconds - @@time_last_job_failure)
      msg =  "Sleeping for #{(wait/60).to_s} minutes because of too many failures............"
      info msg
      sleep wait
      @@time_last_job_failure =  0
      @@time_last_job_failure = Time.now
    end
  end
  
  def info msg
    puts msg
    Rails.logger.info msg
  end
end