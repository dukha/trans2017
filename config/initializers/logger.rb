
def time_in_ms(start, finish)
  return ( ((finish - start).to_f * 100000).round / 100.0 ).to_s
end

# Formatter for rails logger
class ActiveSupport::Logger::SimpleFormatter
  SEVERITY_TO_TAG_MAP     = {'DEBUG'=>'meh', 'INFO'=>'fyi', 'WARN'=>'hmm', 'ERROR'=>'wtf', 'FATAL'=>'omg', 'UNKNOWN'=>'???'}
  SEVERITY_TO_COLOR_MAP   = {'DEBUG'=>'0;37', 'INFO'=>'32', 'WARN'=>'33', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}
  USE_HUMOROUS_SEVERITIES = false
 
  def call(severity, time, progname, msg)
    if USE_HUMOROUS_SEVERITIES
      formatted_severity = sprintf("%-3s",SEVERITY_TO_TAG_MAP[severity])
    else
      formatted_severity = sprintf("%-5s",severity)
    end
 
    formatted_time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
    color = SEVERITY_TO_COLOR_MAP[severity]
 
    "\033[0;37m#{formatted_time}\033[0m [\033[#{color}m#{formatted_severity}\033[0m] #{msg.strip} (pid:#{$$})\n"
  end
end
=begin 
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
 
  logger = Log4r::Logger['rails']
 
  controller_format = "@method @status @path @durationms"
 
  if !payload[:exception].nil? || payload[:status] == 500
    #["process_action.action_controller", 0.033505, "b4ebe16ef3da4c5eb902", {:controller=>"MongotestController", :action=>"index", :params=>{"action"=>"index", "controller"=>"mongotest"}, :format=>:html, :method=>"GET", :path=>"/mongotest", :exception=>["Mongoid::Errors::DocumentNotFound", "\nPro   ...  "]}
    logger.error { 
      message = controller_format.clone
      message.sub!(/@status/, payload[:status].to_s)
      message.sub!(/@method/, payload[:method])
      message.sub!(/@path/, payload[:path])
      message.sub!(/@duration/, time_in_ms(start,finish))
      message += " EXCEPTION: #{payload[:exception]}"
      message
    }
  end
 
  if payload[:status] != 200 && payload[:status] != 500 && payload[:exception].nil?
    logger.warn { 
      message = controller_format.clone
      message.sub!(/@status/, payload[:status].to_s)
      message.sub!(/@method/, payload[:method])
      message.sub!(/@path/, payload[:path])
      message.sub!(/@duration/, time_in_ms(start,finish))
      message += " EXCEPTION: #{payload[:exception]}"
      message
    }
  end
 
  if payload[:status] == 200 && time_in_ms >= 500
    logger.warn { 
      message = controller_format.clone
      message.sub!(/@status/, payload[:status].to_s)
      message.sub!(/@method/, payload[:method])
      message.sub!(/@path/, payload[:path])
      message.sub!(/@duration/, time_in_ms(start,finish))
      message
    }
  end
 
  if payload[:status] == 200 && time_in_ms < 2000
    logger.info { 
      message = controller_format.clone
      message.sub!(/@status/, payload[:status].to_s)
      message.sub!(/@method/, payload[:method])
      message.sub!(/@path/, payload[:path])
      message.sub!(/@duration/, time_in_ms(start,finish))
      message
    }
  end
 
  logger.params { "PARAMS: #{payload[:params].to_json }" }
  logger.debug {
    db = (payload[:db_runtime] * 100).round/100.0 rescue "-"
    view = (payload[:view_runtime] * 100).round/100.0 rescue "-"
    "TIMING[ms]: sum:#{time_in_ms(start,finish)} db:#{db} view:#{view}" 
  }
 
end
# log sql queries and times
ActiveSupport::Notifications.subscribe "sql.active_record" do |name, start, finish, id, payload|
  logger = Log4r::Logger["mysql"] 
  logger.debug { "(#{time_in_ms(start,finish)}) #{payload[:sql]}" }
end

# log exceptions
ActiveSupport::Notifications.subscribe "exception.action_controller" do |name, start, finish, id, payload|
  logger = Log4r::Logger['rails']
  logger.exception { "msg:#{payload[:message]} - inspect:#{payload[:inspect]} - backtrace:#{payload[:backtrace].to_json}" }
end
 
=end