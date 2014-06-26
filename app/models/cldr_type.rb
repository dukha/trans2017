class CldrType
  # even though the plurals are duplicated for some cases, the plural rules differentiate them 
  @@CLDR_PLURAL_TYPES = {"east_slavic" => %w(one few many other), 
                "one_other" => %w(one other),
                "one_upto_two_other" => %w(one other), 
                "one_two_other" =>%w(one two other),
                "onewithzero_other" =>%w(one other),
                "other" =>%w(other),
                "romanian" =>%w(one few other),
                "west_slavic" =>%w(one few other)
              }
   def self.CLDR_PLURAL_TYPES
     return @@CLDR_PLURAL_TYPES
   end
   
=begin
   cldr plurals (used for models and other things in translation files (different in different files))
  zero
  one (singular)
  two (dual)
  few (paucal)
  many
  other (general plural form -- also used if the language only has a single form, or for fractions if they are different)
=end
  def self.CLDR_plurals
    return %w(zero one two few many other)
  end
end