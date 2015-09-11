class TranslationsUploadWriteYamlJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(translations_upload_id)
    begin
      #tu = TranslationsUpload.find(translations_upload_id)
      #tu.write_yaml()
    TranslationsUpload.write_yaml(translations_upload_id)  
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      {:data=> {:class=> TranslationsUpload, :id => translations_upload_id,
        :method =>"write_yaml"}})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        #:data => { :queue => queue, :payload => payload})
        info "Exception in write_yaml() " + exception.message
        exception_raised
        raise
    end
    # Do something later
  end
end
