class TranslationsUpload < ActiveRecord::Base
  include Validations
  mount_uploader :yaml_upload2, YamlTranslationFileUploader
  attr_accessible :description, :translation_language_id, :calmapp_version_id, :yaml_upload, :translation_language, :calmapp_version, :yaml_upload, :yaml_upload2 
  belongs_to :translation_language
  belongs_to :calmapp_version
  
  validates :translation_language_id,  :presence=>true
  validates :translation_language_id, :existence => true
  
  validates :calmapp_version_id,  :presence=>true
  validates :calmapp_version_id, :existence => true
  
  validates :description,  :presence=>true
  
   
  #puts "#{translation_language.iso_code}"
  #-----has_attached_file :yaml_upload, :styles => { :iso_code => 'en'}, :processors => [:parseyaml]#,# :styles => { :iso_code => translation_language.iso_code },
     #:url => "/uploads/upload/:id/:style/:basename.:extension",
     #:path => ":rails_root/public/uploads/uploads/:id/:basename.:extension"
     #:path => :path2
     #:path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"
     #:path => :rails_root/public/system/:class/:attachment/:id_partition/:style/:filename
=begin
 !!! Gotcha 
 The validates statement below must come after the has_attached_file call
=end
  #x = lambda{|tu| tu.yaml_upload.original_filename}
  #x = lambda{|tu| tu.original_filename}
  #x = lambda{|yaml_upload| yaml_upload.original_filename}
  #-----validates_attachment :yaml_upload, :presence => true 
  #validates_attachment_content_type :yaml_upload, :content_type=>"application/x-yaml", :message=>  I18n.t($MS + "yaml_attachment_content_type.error", :yu=> ->(translations_upload){translations_upload.to_s})#lambda{|yaml_upload| yaml_upload.original_filename}) #x.call(yaml_upload)) 
  
  #----validate :validate_content_type 
=begin     
   def path2
     return Rails.root.to_s + '/public/system/' + self.class.name + '/yaml_upload/' + translation_language.iso_code + "/:filename"
   end
=end  

=begin
 I needed to do things this way rather than use the validates_attachment_content_type helper because 
   there was no way of including the name of the wrongly chosen file in the helper (that I could find!)
=end
  def validate_content_type
    if not ['application/x-yaml'].include?(self.yaml_upload_content_type)
      errors.add(:yaml_upload_file_name,  I18n.t($MS + "yaml_upload_content_type.error", :yu=> self.yaml_upload_file_name))
    end
  end
end
