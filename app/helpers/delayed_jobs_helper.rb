module DelayedJobsHelper
  def display_timestamp (time)
    if time.blank?
      return ''
    else
      return time.localtime.strftime("%e-%b-%y %H:%M:%S")  
    end
  end
end
