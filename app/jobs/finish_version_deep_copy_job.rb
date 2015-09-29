class FinishVersionDeepCopyJob< BaseJob
  queue_as :default

  def perform(old_version_id, new_version_id, user_id, copy_translation_languages, copy_translations)
    begin
    CalmappVersion.finish_deep_copy(old_version_id, new_version_id, user_id, copy_translation_languages, copy_translations )
    rescue Exception => exception
      ExceptionNotifier.notify_exception(exception,
      {:data=> {:class=> CalmappVersion, 
        :old_version_id => old_version_id, :new_version_id=> new_version_id, :method=>"finish_deep_copy"}})
        
        
        exception_raised(("Exception in deep_copy() " + exception.message),exception.backtrace)
        raise
    end  
  end  
end
