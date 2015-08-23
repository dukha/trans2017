 begin Demo.demo; rescue Exception => e ; puts e.backtrace.join("\n"); raise; end
