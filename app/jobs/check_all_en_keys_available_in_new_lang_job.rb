class CheckAllEnKeysAvailableInNewLangJob < BaseJob #ActiveJob::Base
  queue_as :default

  def perform(cavs_translation_language_id)
    #binding.pry
    begin
      CalmappVersionsTranslationLanguage.check_en_keys_available_in_new_lang(cavs_translation_language_id)
      puts "Successfully completed " + self.class.name + " cavtl = " + CalmappVersionsTranslationLanguage.find(cavs_translation_language_id).description
    rescue => exception
      ExceptionNotifier.notify_exception(exception,
      :data=> {:class=> CalmappVersionsTranslationLanguage, :id => cavs_translation_language_id,
        :method => "check_all_en_keys_available_in_new_lang"})
        #:data => {:worker => worker.to_s, :queue => queue, :payload => payload})
        
      exception_raised(("Exception in check_all_en_keys_available_in_new_lang() " + exception.message), exception.backtrace)
      raise  
    end
    # Do something later
  end
  
  def new_trans en_trans
    if en_trans.special_structure == "plural"
      translation = {}
      plurals = entrans.plurals
      plurals.keys.each{ |v|
        translation[plurals[v]] = nil 
      }
    elsif  en_trans.special_structure == "array7"
      translation = Array.new(7)
      
    elsif  en_trans.special_structure == "array13null"
      translation = Array.new(13)
    elsif en_trans.special_structure == "order_array"
       #arr = ActiveSupport::JSON.decode(en_trans.translation)
       #size = arr.length
       translation =  en_trans.translation
    elsif en_trans.special_structure == "hash"
       translation = {}
    elsif en_trans.special_structure == "array"
      translation = Array.new
    elsif  is_boolean(en_trans)
      translation = false
    else
      return nil     
    end       
  end
    
  def is_boolean en_trans
    val = ActiveSupport::JSON.decode(en_trans.translation)
    if val.is_a?(TrueClass) || val.is_a?(FalseClass)
      return true
    else
      return false
    end
  end       
end