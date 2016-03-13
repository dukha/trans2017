class AddOtherLanguageRecordsToVersionJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(translation_id)
    begin
      t = Translation.find(translation_id)
      t.add_other_language_records_to_version
      puts "Successfully competed " + self.class.name + " translation = " + t.description
    rescue => exception
      #puts "Exception in add_other_language_records_to_version()"
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> Translation, :id => translation_id})
      exception_raised(("Exception in add_other_language_records_to_version() " + exception.message), exception.backtrace)
      raise  
    end
  end
end