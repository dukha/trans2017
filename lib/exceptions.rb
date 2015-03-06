module Exceptions
=begin
Contains all application specific exceptions
You will need to add
require 'exceptions'
to your ruby file before raising an exception
as the lib directory where is is located is on the rails_path but not autoload
Otherwise in config/application.rb
config.autoload_paths += %W(#{config.root}/lib
=end

  require File.join(Rails.root, "app", "/helpers" "/translations_helper.rb" ) #'app/helpers/translations_helper.rb'
  include TranslationsHelper
  
=begin
  This class can be used as a documentation for using i18n with application exceptions
  It does nothing other than change the name of the parameter name for StandardError to
  translation_code
=end
  class InternationalStandardError < StandardError
    attr_accessor :translation_interpolations, :translation_code, :level

    def initialize translation_code, translation_interpolations = {}, level= "error"
      @translation_code = translation_code
      @translation_interpolations = translation_interpolations
      @level = level
      log
    end
    def message locale = nil
        locale = (locale.nil?? I18n.locale : locale)
        
        return I18n.t($MS + translation_code + "." + level, translation_interpolations.merge({:locale=> locale}))  
    end
    def log
      if level == "warning"
      Rails.logger.warn(message)
     elsif level == 'error' 
       Rails.logger.error(message)
     elsif level == 'info'
       Rails.logger.info(message)
     elsif level == 'debug'
       Rails.logger.debug(message)
     end    
    end  
    #def translation_code
      #return super.message
    #end
    
    def message_in_english
      #hash = @translation_interpolations.clone
      #hash[:locale] = :en
      #puts @translation_interpolations
      #puts hash
      return message 'en' 
    end
      
  end



  
  class InvalidBelongsToAssociation < InternationalStandardError
    #require "translations_helper"
    #include TranslationsHelper
    #extend TranslationsHelper
    # TranslationHelper apparently couldn't help here!!
    @@Translation_code = "existence." +"error" #I18n.t($MS + "existence" +".error")# TranslationsHelper.tmessage("existence", "error" )#
    def initialize record, attribute, value, target
      super @@Translation_code
      @record = record
      @attribute = attribute
      @value = value
      @target = target
    end

    def record
      @record
    end
    def message
      @record.errors[@attribute]= I18n.t(super , :attribute => @attribute, :value=>@value, :target=>@target )
      return @record.errors[@attribute]
    end
  end

  class SubClassShouldImplement < NotImplementedError
  end

  class Calm3ConnectionError < StandardError
  
  end
  
  # SilentException is an exception that is only to be logged.
  # The user can continue to work.
  # This situation occurs when there is an automatic process going on which needs to raise and exception (e.g AT update)
  class SilentException < Exception
    
  end
  
  class NoAuthorisation < InternationalStandardError
    
  end
  
  class NoLanguageDeleteAuthorisation < NoAuthorisation
    
    @@Translation_code = "calmapp_versions_translation_language.delete.no_language_authorisation"
=begin
 @param interpolations must have :version as version name and :language as in translation_langauge name
=end
    def initialize interpolations = {}, level = 'warning' 
       super(@@Translation_code,  interpolations)
       
         
    end
  end
  
  
  
   class NoRedisDatabasesLeft < InternationalStandardError
    
    @@Translation_code = "redis_instance.all_redis_db_indexes_taken"
=begin
 @param interpolations must have :description as description of Redis Instance
=end
    def initialize interpolations = {}, level = 'warning' 
      binding.pry
       super(@@Translation_code,  interpolations, level )
      
    end
  end
end
