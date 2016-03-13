class TranslationLanguage < ActiveRecord::Base
 #set_table_name :language
 has_many :calmapp_versions_translation_language, dependent: :restrict_with_exception
 has_many :calmapp_versions, :through => :calmapp_versions_translation_language
 
 validates :iso_code, :name, :presence => true,:uniqueness => true
 validates :name, :presence => true, :uniqueness => true
 
  scope :english_arr, ->{TranslationLanguage.where{iso_code == 'en'}}
  
  def show_me
    return "LANG " + name + " " + iso_code  + " tl-id = " + id.to_s
  end
=begin
 @ return is the TranslationLanguage with 'en' as iso_code
 This is the developers' translation 
=end
  def self.TL_EN
    return english_arr.first
  end 
  
  def english?
    return iso_code == 'en'
  end
=begin
 Strictly speaking all chinese, korean, vietnamese, japanese, indonesian, thai, burmese, khymer all have "other" plurals
 However  all chinese, korean, vietnamese, japanese, indonesian use "one_other" in base files: so they stay with "one_other"
 burmese and kyymer have no base file
 thai is the only example of a base file which uses other
=end
 def self.seed
   
  en =  TranslationLanguage.create!(:plural_sort=>"one_other", :iso_code=> "en", :name=>"English" )
 
   TranslationLanguage.create!(:iso_code=> "nl", :name=>"Dutch", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "es", :name=>"Spanish", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "fr", :name=>"French", :plural_sort => "one_upto_two_other")
   TranslationLanguage.create!(:iso_code=> "de", :name=>"German", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "en-US", :name=>"English(US)", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "zh-Hant", :name=>"Chinese(Traditional)", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "zh-Hans", :name=>"Chinese(Simplified)", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "da", :name=>"Danish", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "pt", :name=>"Portuguese", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "it", :name=>"Italian", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "el", :name=>"Greek", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "ja", :name=>"Japanese", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "sv", :name=>"Swedish", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "hu", :name=>"Hungarian", :plural_sort =>"east_slavic")# other?
   TranslationLanguage.create!(:iso_code=> "sr", :name=>"Serbian", :plural_sort => "one_few_many_other") # one_other
   TranslationLanguage.create!(:iso_code=> "id", :name=>"Indonesian", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "th", :name=>"Thai", :plural_sort => "other")
   TranslationLanguage.create!(:iso_code=> "hi", :name=>"Hindi", :plural_sort =>"onewithzero_other")
   TranslationLanguage.create!(:iso_code=> "ne", :name=>"Nepali", :plural_sort =>"onewithzero_other" )
   TranslationLanguage.create!(:iso_code=> "ko", :name=>"Korean", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "nb", :name=>"Norwegian", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "fi", :name=>"Finnish", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "en-AU", :name=>"English(Australia)", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "en-UK", :name=>"English(UK)", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "zh-HK", :name=>"Chinese(Hong Kong)", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "pl", :name=>"Polish", :plural_sort =>"east_slavic")
   TranslationLanguage.create!(:iso_code=> "et", :name=>"Estonian", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "lt", :name=>"Lithuanian", :plural_sort =>"west_slavic")
   TranslationLanguage.create!(:iso_code=> "lv", :name=>"Latvian", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "sk", :name=>"Slovak", :plural_sort =>"west_slavic")
   TranslationLanguage.create!(:iso_code=> "cs", :name=>"Czech", :plural_sort =>"west_slavic")
   TranslationLanguage.create!(:iso_code=> "sl", :name=>"Slovenian", :plural_sort =>"west_slavic")
   TranslationLanguage.create!(:iso_code=> "kh", :name=>"Khymer", :plural_sort => "other")
   TranslationLanguage.create!(:iso_code=> "vi", :name=>"Vietnamese", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "my", :name=>"Burmese", :plural_sort => "other")
   TranslationLanguage.create!(:iso_code=> "mk", :name=>"Macedonian", :plural_sort => "one_other")
   TranslationLanguage.create!(:iso_code=> "af", :name=>"Afrikaans", :plural_sort => "one_other")
   #TranslationLanguage.create!(:iso_code=> "zh-MY", :name=>"Chinese(Malaysia)", :plural_sort => "other")
   TranslationLanguage.create!(:iso_code=> "ru", :name=>"Russian", :plural_sort =>"east_slavic")
   TranslationLanguage.create!(:iso_code=> "uk", :name=>"Ukrainian", :plural_sort =>"east_slavic")
   TranslationLanguage.create!(:iso_code=> "mn", :name=>"Mongolian", :plural_sort => "one_other")
   
   puts "Translation Languages inserted"
   return en
 end
=begin
 @todo modify this so that it only selects those translation languages of the current user 
=end
 def self.translators_language_select(current_user)
 #TranslationLanguage.order("name asc")
   # replaced scoped as is deprecated with where(nil)
   return where(nil).order("name asc") if Rails.env == "development"
   return where{iso_code != 'en'}.order("name asc") 
 end
 
 def self.language_select
  return order "name asc"
 end

 def full_name
  return name + " (" + iso_code + ")"
 end

 def plurals
   return CldrType.CLDR_PLURAL_TYPES[plural_sort]
 end
 
 def plurals_same_as_en? 
    plural = plural_sort
    plural_same_as_en = false
    if  plural == "one_other" || plural == "one_upto_two_other" || plural == "onewithzero_other" then 
      plural_same_as_en = true
    end
    return plural_same_as_en
  end
  
  def plurals_array 
    pa = CldrType.CLDR_PLURAL_TYPES[plural_sort] || []#CldrType.CLDR_PLURAL_TYPES["one_other"]
    return pa
  end

end


