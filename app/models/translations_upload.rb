class TranslationsUpload < ActiveRecord::Base
  attr_accessible :description, :translation_language_id, :calmapp_version_id, :yaml_upload, :translation_language, :calmapp_version
  belongs_to :translation_language
  belongs_to :calmapp_version
  
  validates :translation_language_id,  :presence=>true
  validates :translation_language_id, :existence => true
  
  validates :calmapp_version_id,  :presence=>true
  validates :calmapp_version_id, :existence => true
  
  validates :description,  :presence=>true
  #puts "#{translation_language.iso_code}"
  has_attached_file :yaml_upload#,# :styles => { :iso_code => translation_language.iso_code },
     #:url => "/uploads/upload/:id/:style/:basename.:extension",
     #:path => ":rails_root/public/uploads/uploads/:id/:basename.:extension"
     #:path => :path2
     #:path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"
     #:path => :rails_root/public/system/:class/:attachment/:id_partition/:style/:filename
=begin     
   def path2
     return Rails.root.to_s + '/public/system/' + self.class.name + '/yaml_upload/' + translation_language.iso_code + "/:filename"
   end
=end  
end
