class Translation < ActiveRecord::Base
  # needed for self.search
  extend SearchModel
  
  
  #validates :translation, :presence=>true
  
  # for developers  we want to be able to process up to 3 translations from 1 form: thus extra virtual attributes
  # to be saved as separate translations
  attr_accessor  :dot_key_code0, :translation0, :translation_message0, :dot_key_code1, :translation1, :translation_message1, :dot_key_code2, :translation2,  :translation_message2#, :developer_params
  
 
  #scope :all, -> {order('dot_key_code asc')}
  validates :dot_key_code, :uniqueness=>{:scope=> :language}#, :presence=>true 
  
  def full_dot_key_code
    return language + "." + dot_key_code
  end
=begin
  def english_translation 
    new_locale = replace_locale_in_dot_key_code('en')
    en = Translation.where{dot_key_code == my{new_locale}}
    puts  en.all.to_s
    return en
  end
  def translation_locale 
    dot_key_code[0..(dot_key_code.index('.')-1)]
  end
  def remove_locale_from_dot_key_code
    dot_key_code[(dot_key_code.index('.')+1)..(dot_key_code.size() -1)]
  end
  def replace_locale_in_dot_key_code new_locale
    new_locale + '.' +remove_locale_from_dot_key_code
  end
=end
  def self.save_multiple translation_array
    #debugger
    transaction do 
      translation_array.each do |t|
        t.save!
      end
    end
  end
=begin
   def self.searchable_attr 
    return %w[dot_key_code0 translation0 translation_message dot_key_code1 translation1 translation_message1 dot_key_code2 translation2  translation_message2]
  end
  def self.sortable_attr 
    return %w[dot_key_code0 translation0 translation_message dot_key_code1 translation1 translation_message1 dot_key_code2 translation2  translation_message2]
  end
=end
  def self.searchable_attr
    %w(iso_code dot_key_code translation)
  end
  
  def self.sortable_attr
    %w(dot_key_code translation)
  end
  def self.search_dot_key_code_operators
     %w(ends_with matches does_not_match equals )
  end
  def self.search_translation_operators
    %w(begins_with ends_with matches  does_not_match equals is_null is_not_null)
  end
  # need a model as param
  # overrides search() in search_model.rb
  def self.search(current_user, search_info={}, ar_relation = nil)
    criteria = search_info[:criteria]
    operators = search_info[:operators]
    sorting= search_info[:sorting]
    translations= all
    #puts translations.class.name
    #debugger
    #@val=nil
    if ! criteria['iso_code'].nil? then
      #operators["dot_key_code"] = 'begins_with'
      #criteria["dot_key_code"] = criteria['iso_code'] + '.'
      # We have to do it like this as language is a separate selection criterion which uses dot_key_code
      # This ways we can select again on dot_key_code to narrow the selection further 
      
      translations= translations.where{ dot_key_code  =~ criteria['iso_code'] + '.%' }
      operators.delete('iso_code')
      criteria.delete('iso_code')
    end
    # We need to do this for dot key code otherwise it will split on '.'
    # in and not_in are a bit shakey. They come to the controller as lists as a string. So we try to split
    # using space, or comma
    if criteria['dot_key_code'] then
      if operators['dot_key_code'] == 'in' || operators['dot_key_code'] == 'not_in' then
        array = criteria['dot_key_code'].split(" ")
        if array.size == 1 then
          array = criteria['dot_key_code'].split(", ")
          if array.size == 1 then
            array = criteria['dot_key_code'].split(",")
            criteria['dot_key_code']= array
          end 
        else
          criteria['dot_key_code']= array  
        end
      end
    end

    #binding.pry
    translations = build_lazy_loader(translations, criteria, operators)
    #puts translations.class.name
    return translations
  end
  
    def self.translations_to_db_from_file hash, overwrite
    keys =  hash.keys
    
    keys.each{ |k| puts k + ": " + hash[k]}
    puts "Number of keys in hash " + keys.count.to_s
    count=0
    translation = nil
    keys.each do |k| 
      translation = translation_to_db_from_file(k, hash[k], overwrite)    
      if not translation.valid? then
        return translation
      end
      count += 1
    end
    puts "keys written to db = " + count.to_s
    return translation
  end
=begin
 Writes 1 key and translation to Translation 
=end
  def self.translation_to_db_from_file key, translation, overwrite
    split_hash= split_full_dot_key_code key
    exists = Translation.where{(dot_key_code == split_hash[:dot_key_code]) & (language== split_hash[:language])} 
    if exists.count > 0
     object = exists.first
     puts "object exists"
    end
    object_persisted = false
    if overwrite == Overwrite[:all] then
      if not object.nil?
        puts "all object to be persisted persisted because of all"
        b = object.update_attributes(:translation=> translation)
        #binding.pry
        object_persisted = true
        puts "all object persisted"
        return object
      end
      "object is nil : major error"
    elsif overwrite == Overwrite[:none] then
      puts "none"
      if object && object.translation.nil? then 
        #We update where the transaltion is nil anyway
        b = object.update_attributes(:translation=> translation)
        object_persisted = true
        puts "none: persisted anyway"
        return object
      else
        "none correctly not persisted"
        # We don't persist because of :none condition
      end 
    elsif overwrite == Overwrite[:cancel]
      puts "cancel"
      if not object.nil? then
       object.errors.messages << I18n.t("messages.write_file_to_db.cancel", {:language=> object.language, :dot_key_code=> object.dot_key_code})
       return object 
      end
      puts "cancel but no return"
    end
    
    # if not overwrite or match language and keys count=0 then this code executes
    if not object_persisted then
      puts "Write new"
      t = Translation.new(:language => split_hash[:language], :dot_key_code=> split_hash[:dot_key_code], :translation=>translation)
      b = t.save
      binding.pry
      return t
     else
       "error"
       # this is an error
       raise RuntimeError, I18n,t("messages.write_file_to_db.object_persisted_but_not_returned", {:language=> object.language, :dot_key_code=> object.dot_key_code}), caller
     end  
  end

=begin
 Splits a full_dot_key_code into language and dot_key_code (without language)
 #return hash keyed by ":language" and ":dot_key_code" 
=end  
  def self.split_full_dot_key_code full_dot_key_code
    code_array = full_dot_key_code.split(".") 
    return {:language=> code_array[0], :dot_key_code=> code_array[1..(code_array.length-1)].join(".")}
  end
end

# == Schema Information
#
# Table name: translations
#
#  id                 :integer         not null, primary key
#  dot_key_code       :string(255)     not null
#  translation        :text            not null
#  calmapp_version_id :integer         not null
#  origin             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

