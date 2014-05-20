# == Schema Information
# Schema version: 20110918232413
#
# Table name: calmapp_versions_languages
#
#  id                 :integer         not null, primary key
#  calmapp_version_id :integer         not null
#  language_id        :integer         not null
#

class CalmappVersionsTranslationLanguage < ActiveRecord::Base
  include Validations
  extend SearchModel
  include SearchModel
  attr_accessible :calmapp_version_id, :calmapp_version, :translation_language_id, 
  :translation_language, :translations_uploads_attributes, :calmapp_versions_translation_languages_attributes
  
  #attr_accessor :warnings
  def self.searchable_attr 
     %w(calmapp_version_id translation_language_id )
  end
  def self.sortable_attr
      []
  end
  belongs_to :calmapp_version_tl, :inverse_of=>:calmapp_versions_translation_languages, :class_name => "CalmappVersion", :foreign_key =>"calmapp_version_id"
  belongs_to :translation_language

  validates :translation_language_id, :uniqueness => {:scope=> :calmapp_version_id}
  validates :calmapp_version_id, :uniqueness => {:scope=> :translation_language_id}
  #validates :calmapp_version, :existence=>true
  #validates :language, :existence=>true
  #attr_accessor :write
  has_many :translations_uploads, :foreign_key=> "cavs_translation_language_id"
  accepts_nested_attributes_for :translations_uploads, :reject_if => :all_blank, :allow_destroy => true
  # once we have saved a new language then we upload the base file for that translation 
  after_create :base_locale_translations_for_new_translation_languages
 
  
    
    
 

  def name
    return CalmappVersion.find(calmapp_version_id).name + " " + TranslationLanguage.find(translation_language_id).name
  end
  
  def base_locale_translations_for_new_translation_languages
    
    puts "after save in base_locale_translations_for_new_translation_languages"
    
    uploads =  TranslationsUpload.where{cavs_translation_language_id == my{id}}.load
    found=false
    if not uploads.empty? then
      # the file is already uploaded
      uploads.each do |u|
        # This doesn't always work: if u.yaml_upload.identifier == base_locale_file_name then
        if u.yaml_upload_identifier == base_locale_file_name then
          found=true
          return
        end
      end  #each       
    end # not empty
    if not found then
         # all the standard base files are in a rails dir as below (they havebeen downloaded from /home/mark/.rvm/gems/ruby-2.0.0-p247/gems/rails-i18n-4.0.1/rails/locale/)
        file_to_upload = File.join(TranslationsUpload.base_locales_folder,  base_locale_file_name())
        
        if File.exists?(file_to_upload) then          
          tu = TranslationsUpload.new(:cavs_translation_language_id=>id, 
               :yaml_upload=> File.open(file_to_upload) , :description=> "Automatic base locale upload " + base_locale_file_name())
          
          tu.save
          #if tu.save then
            #tu.write_file_to_db2 #Translation.Overwrite[:continue_unless_blank]
          #end #upload saved
        else
          # The file may not exist, in which case we don"t write but warn"
          calmapp_version_tl.warnings=ActiveModel::Errors.new(self) if calmapp_version_tl.warnings.nil?
          calmapp_version_tl.warnings.add(:base, I18n.t($MS + "base_locale_file_not_found.warning", :folder => TranslationsUpload.base_locales_folder, :file_name=> base_locale_file_name,:fuchs=> "https://github.com/svenfuchs/rails-i18n/tree/master/rails/locale"))
          #flash.now[:warning] = "The file " + base_locale_file_name + " does not exist in " + File.join(Rails.root, "base_locales") + " You will have to fill in about 160 more translations if you can't find this file. You can also copy and rename a file from a close locale. e.g. copy zh-CN.yml renaming to zh-MY.yml for Mayaysian Chinese."
          Rails.logger.warn "The file " + base_locale_file_name + " does not exist in " + TranslationsUpload.base_locales_folder + " You will have to fill in about 160 more translations if you can't find this file. You can also copy and rename a file from a close locale. e.g. copy zh-CN.yml renaming to zh-MY.yml for Mayaysian Chinese."
        end # base file exists
   end # not found
  end # def
  
  
  def base_locale_file_name
    translation_language.iso_code + ".yml"
  end
  def self.find_by_language_and_version language_id, version_id
    where{calmapp_version_id == version_id}.where{translation_language_id == language_id}
    
  end
  
  def self.find_languages_not_in_version  language_ids_array, version_id
    where{calmapp_version_id == version_id}.where{translation_language_id << language_ids_array}
  end
end
