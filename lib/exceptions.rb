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
    attr_accessor :translation_interpolations, :translation_code
    # Use the message slot to hold the translation_code instead of message
#<<<<<<< HEAD
    def initialize  translation_code, translation_interpolations = nil
#=======
    #def initialize  translation_code
      # no whitespace
      # options={}
      # super translation_code, options  ?
#>>>>>>> 20f0f4d2ffb721f7e08426940623d391440860bd
      @translation_code = translation_code
      @translation_interpolations = translation_interpolations
    end
    def message
        return I18n.t($EM + translation_code, @translation_interpolations)  
    end
    
    #def translation_code
      #return super.message
    #end
    
    def message_in_english
      hash = @translation_interpolations.clone
      hash[:locale] = :en
      puts @translation_interpolations
      puts hash
      return I18n.t( $EM + translation_code, hash) 
    end
      
  end



  
  class InvalidBelongsToAssociation < InternationalStandardError
    #require "translations_helper"
    #include TranslationsHelper
    #extend TranslationsHelper
    # TranslationHelper apparently couldn't help here!!
    @@Translation_code =  I18n.t($MS + "existence" +".error")# TranslationsHelper.tmessage("existence", "error" )#
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
  

end
