=begin
I18n::Backend::Base.module_eval do
  def translate(locale, key, options = {})
    #binding.pry
    puts "marks eval"
    raise InvalidLocale.new(locale) unless locale
    entry = key && lookup(locale, key, options[:scope], options)
    
    if options.empty?
      entry = resolve(locale, key, entry, options)
    else
      count, default = options.values_at(:count, :default)
      values = options.except(*RESERVED_KEYS)
      entry = entry.nil? && default ?
        default(locale, key, default, options) : resolve(locale, key, entry, options)
    end
    pluralized =false
    if entry.nil? then
      if options[:count] then
=begin        
       tl = TranslationLanguage.where{iso_code == my{locale.to_s}} 
       plurals = tl.plurals_array
       plurals.each { |p|
         
         test_key = key + "." + p
         entry = resolve(locale, test_key, entry, options)
       }
= end
        binding.pry
        entry  = pluralize(locale, entry, count)
        pluralized = true
        puts "in entry nil count"
        plural_from_count(options[:count])    
      end
    end 
 
    throw(:exception, I18n::MissingTranslation.new(locale, key, options)) if entry.nil?
    entry = entry.dup if entry.is_a?(String)
    if not pluralized
      entry = pluralize(locale, entry, count) if count
    end
    entry = interpolate(locale, entry, values) if values
    entry
  end 

  def plural_from_count count
    puts "In base plural_from_count " + count.class.name
  end
end

I18n::Backend::Pluralization.module_eval do
  def pluralize(locale, entry, count)
=begin
    require 'rails_i18n/common_pluralizations/east_slavic'
    require 'rails_i18n/common_pluralizations/one_other'
    require 'rails_i18n/common_pluralizations/one_two_other'
    require 'rails_i18n/common_pluralizations/one_upto_two_other'
    require 'rails_i18n/common_pluralizations/one_with_zero_other'
    require 'rails_i18n/common_pluralizations/other'
    require 'rails_i18n/common_pluralizations/romanian'
    require 'rails_i18n/common_pluralizations/west_slavic'
= end
   
    puts "in pluralize"
    if I18n.backend.class.name == "I18n::Backend::KeyValue" then
      puts "key value"
      return entry unless count
    else
      puts I18n.backend.class.name
      return entry unless entry.is_a?(Hash) and count
    end
    binding.pry

    pluralizer = pluralizer(locale)
    if pluralizer.respond_to?(:call)
      key = count == 0 && entry.has_key?(:zero) ? :zero : pluralizer.call(count)
      raise InvalidPluralizationData.new(entry, count) unless entry.has_key?(key)
      entry[key]
    else
      super
    end
  end
end

=end