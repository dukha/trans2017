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
   @@PLURALS = %w(one two few many other)
   
   def self.PLURALS
     @@PLURALS
   end
   
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
  
  @@CLDR_PLURAL_RANGES = {
    
    "east_slavic" => { zero: 'many', one: (1..1),  few: (2..4), many: (5..9),  other: (10..10000000) }, 
   "one_other" => { zero: 'other',one: (1..1), other: ( 2..10000000)},
   "one_upto_two_other" => { zero: 'other', one: (1..2), other: ( 3..100000000)}, 
    "one_two_other" => {zero: 'other', one: (1..1), two: (2..2), other: (3..10000000000)},
    "onewithzero_other" =>{zero: 'other',one: (0..1), other: (2.10000000000 )},
    "other" =>{zero: 'other', other: (1..100000000000)},
    "romanian" =>{zero: 'other',one: (1..1), few: (2..19), other: (5..10000000000)},
    "west_slavic" =>{zero: 'other', one: (1..1), few: (2..4), other: (5..10000000000)}
  }
end