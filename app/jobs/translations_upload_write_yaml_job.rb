class TranslationsUploadWriteYamlJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(translations_upload_id)
    Rails.logger.error "2. TranslationsUploadWriteYamlJob rrr " + Rails.root.to_path
    begin
    TranslationsUpload.write_yaml(translations_upload_id)  
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      {:data=> {:class=> TranslationsUpload, :id => translations_upload_id,
        :method =>"write_yaml"}})
        exception_raised(("Exception in write_yaml() " + exception.message),exception.backtrace)  
        raise
    end
  end
end
