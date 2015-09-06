class TranslationHint < ActiveRecord::Base
  #attr_accessor :criterion_dot_key_code
  validates :dot_key_code, :uniqueness => true, :presence=> true
  validates :description, :presence => true
  extend SearchModel
  
  belongs_to  :translation 
  
  def self.searchable_attr
    %w(dot_key_code heading description)
  end
  
  def self.sortable_attr
    %w(dot_key_code heading)
  end
  
  def self.seed
    TranslationHint.delete_all


    TranslationHint.create!(:dot_key_code => "activemodel.errors.format",:heading => "Message Format", :example => "'%{attribute} %{message}' says that the attribute name will be added before the message:<br> e.g. if attribute is 'name' and message is 'can not be blank' the the user sees 'Name cannot be blank'", :description => "Tells the program the order of the attribute and message. Attribute can be left out") # %{attribute} %{message}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.accepted",:heading => "User Error Message", :example => "attribute: 'licence_agreement',<br> message: 'must be accepted'<br>gives 'Licence Agreement must be accepted'", :description => "Tells the user that he must accept the conditions.") # must be accepted
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.blank",:heading => "User Error Message", :example => "", :description => "Tells the user that some data is required") # can't be blank
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.confirmation",:heading => "Confirmation Message", :example => "", :description => "Tells the user that 2 lots of data must match e.g. Password confirmation.") # doesn't match %{attribute}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.empty",:heading => "User Error Message", :example => "", :description => "Tells the user that he must choose or type some data for attribute") # can't be empty
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.equal_to",:heading => "User Error Message", :example => "", :description => "Tells the user that the wrong number of pieces of data have been entered.") # must be equal to %{count}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.even",:heading => "Error Message", :example => "", :description => "Tells the user that the count of data items must be an even number") # must be even
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.exclusion",:heading => "User Error Message", :example => "", :description => "Tells the user that the data entered is reserved for another purpose") # is reserved
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.greater_than",:heading => "User Error Message", :example => "", :description => "Tells the user that the value of numerical or date data must be larger than a value") # must be greater than %{count}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.greater_than_or_equal_to",:heading => "User Error Message", :example => "", :description => "Tells the user that the value of numerical or date data must be larger than or equal to a value") # must be greater than or equal to %{count}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.inclusion",:heading => "User Error Message", :example => "", :description => "Tells the user that an attribute is not included in a list") # is not included in the list
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.invalid",:heading => "User Error Message", :example => "", :description => "Tells the user that a piece of data is invalid") # is invalid
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.less_than",:heading => "User Error Message", :example => "", :description => "Tells the user that  the value of numerical or date data must be less than a value") # must be less than %{count}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.less_than_or_equal_to",:heading => "User Error Message", :example => "", :description => "Tells the user that the value of numerical or date data must be less than or equal to a value") # must be less than or equal to %{count}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.not_a_number",:heading => "User Error Message", :example => "", :description => "Tells the user that a number is reuire for this attribute") # is not a number
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.not_an_integer",:heading => "User Error Message", :example => "", :description => "Tells the user that an integer is required for this attribute") # must be an integer
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.odd",:heading => "User Error Message", :example => "", :description => "Tells the user that the count of data items must be an odd number") # must be odd
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.other_than",:heading => "User Error Message", :example => "", :description => "Tells the user that the number of items must something else.") # must be other than %{count}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.present",:heading => "User Error Message", :example => "", :description => "Tells the user that an attribute has a value but should be left blank") # must be blank
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.record_invalid",:heading => "User Error Message", :example => "", :description => "Tells the user that the data is invalid and lists the errors") # Validation failed: %{errors}
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.restrict_dependent_destroy.many",:heading => "User Error Message", :example => "", :description => "Tells the user that many records depend on the record that they try to delete. Delete can't be done unless the dependent records are deleted") # Cannot delete record because dependent %{record} exist
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.restrict_dependent_destroy.one",:heading => "User Error Message", :example => "", :description => "Tells the user that a record depends on the record that they try to delete. Delete can't be done unless the dependent record is deleted") # Cannot delete record because a dependent %{record} exists
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.taken",:heading => "User Error Message", :example => "", :description => "Tells the user that a value has already been used. It cannot be used again.") # has already been taken
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.too_long.one",:heading => "User Error Message", :example => "", :description => "Tells the user that he has typed too many characters for an attribute. Only 1 is allowed.") # is too long (maximum is 1 character)") # is too long (maximum is 1 character)
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.too_long.other",:heading => "User Error Message", :example => "", :description => "Tells the user that he has typed too many characters for an attribute. Gives the nubmer of chars allowd.")  # is too long (maximum is %{count} characters)
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.too_short.one",:heading => "User Error Message", :example => "", :description => "Tells the user that he has typed too few characters for an attribute.  1 is allowed.")  # is too short (minimum is 1 character)
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.too_short.other",:heading => "User Error Message", :example => "", :description => "Tells the user that he has typed few many characters for an attribute. The number needed is given eg password.") # is too short (minimum is %{count} characters)
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.wrong_length.one",:heading => "User Error Message", :example => "", :description => "Tells the user that he has typed the wrong number of characters for an attribute. Only 1 is allowed.")  # is the wrong length (should be 1 character)
    TranslationHint.create!(:dot_key_code => "activemodel.errors.messages.wrong_length.other",:heading => "User Error Message", :example => "", :description => "Tells the user that he has typed the wrong number of characters for an attribute. Gives the number allowed.") # is the wrong length (should be %{count} characters)
    TranslationHint.create!(:dot_key_code => "activemodel.errors.template.body",:heading => "User Error Message", :example => "", :description => "Tells the user that there are problesm with a number of fields on the form( they will be highlighted on the form.).") # There were problems with the following fields:
    TranslationHint.create!(:dot_key_code => "activemodel.errors.template.header.one",:heading => "", :example => "", :description => "Tells the user that there was 1 error that prevented the form from being saved. (error will be highlighted.)") # 1 error prohibited this %{model} from being saved
    TranslationHint.create!(:dot_key_code => "activemodel.errors.template.header.other",:heading => "User Error Message", :example => "", :description => "Tells the user that tells the user the number of errors that prevent saving and the object name.") # %{count} errors prohibited this %{model} from being saved
    
  TranslationHint.create!(:dot_key_code => "date.abbr_day_names",:heading => "Days of Week", :example => "", :description => "Days of the week, each abbreviated to 3 characters") # ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  TranslationHint.create!(:dot_key_code => "date.abbr_month_names",:heading => "Months of Year", :example => "", :description => "Months of year, each abbreviated to 3 characters") # [null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
  TranslationHint.create!(:dot_key_code => "date.day_names",:heading => "Days of Week", :example => "", :description => "Days of the week, fully written out") # ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
  TranslationHint.create!(:dot_key_code => "date.formats.default",:heading => "Date Format", :example => "", :description => "This is the date format given when the app does not give one. 'Default' ") # %Y-%m-%d
  TranslationHint.create!(:dot_key_code => "date.formats.long",:heading => "Date Format", :example => "", :description => "Choose the format for a date with a lot of information") # %B %d, %Y
  TranslationHint.create!(:dot_key_code => "date.formats.short",:heading => "Date Format", :example => "", :description => "Choose the format for a date the is quite short and easy to read.") # %b %d
  TranslationHint.create!(:dot_key_code => "date.month_names",:heading => "Months of Year", :example => "", :description => "Months of the year in full") # [null,"January","February","March","April","May","June","July","August","September","October","November","December"]
  TranslationHint.create!(:dot_key_code => "date.order",:heading => "Date Format", :example => "", :description => "When using a date the app will assume this order if none is given") # ["year","month","day"]
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.about_x_hours.one",:heading => "Easy Read", :example => "A Time of 1 hour 25 minutes will be seen by the user as 'About 1 hour", :description => "Makes is easier for the user to read a time period") # about 1 hour
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.about_x_hours.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # about %{count} hours
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.about_x_months.one",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # about 1 month
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.about_x_months.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # about %{count} months
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.about_x_years.one",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # about 1 year
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.about_x_years.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # about %{count} years
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.almost_x_years.one",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # almost 1 year
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.almost_x_years.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # almost %{count} years
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.half_a_minute",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # half a minute
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.less_than_x_minutes.one",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # less than a minute
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.less_than_x_minutes.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # less than %{count} minutes
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.less_than_x_seconds.one",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # less than 1 second
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.less_than_x_seconds.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # less than %{count} seconds
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.over_x_years.one",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # over 1 year
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.over_x_years.other",:heading => "Easy Read", :example => "", :description => "Makes is easier for the user to read a time period") # over %{count} years
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_days.one",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # 1 day
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_days.other",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # %{count} days
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_minutes.one",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # 1 minute
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_minutes.other",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # %{count} minutes
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_months.one",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # 1 month
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_months.other",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # %{count} months
   TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_seconds.one",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # 1 second
  TranslationHint.create!(:dot_key_code => "datetime.distance_in_words.x_seconds.other",:heading => "", :example => "Easy Read", :description => "Makes is easier for the user to read a time period") # %{count} seconds
  TranslationHint.create!(:dot_key_code => "datetime.prompts.day",:heading => "Label", :example => "", :description => "Day") # Day
  TranslationHint.create!(:dot_key_code => "datetime.prompts.hour",:heading => "Label", :example => "", :description => "Hour") # Hour
  TranslationHint.create!(:dot_key_code => "datetime.prompts.minute",:heading => "Label", :example => "", :description => "Minute") # Minute
  TranslationHint.create!(:dot_key_code => "datetime.prompts.month",:heading => "Label", :example => "", :description => "Month") # Month
  TranslationHint.create!(:dot_key_code => "datetime.prompts.second",:heading => "Label", :example => "", :description => "Seconds") # Seconds
  TranslationHint.create!(:dot_key_code => "datetime.prompts.year",:heading => "Label", :example => "", :description => "Year") # Year
  TranslationHint.create!(:dot_key_code => "helpers.select.prompt",:heading => "Button Label", :example => "", :description => "Label on a button that asks the user to select something: Please select") # Please select
  TranslationHint.create!(:dot_key_code => "helpers.submit.create!",:heading => "Button Label", :example => "If you have a user object to change in the database then then the app gives the button 'User' as 'model'. The button will say 'create! User'", :description => "Label on a button that asks the user to create! an object in the database. The name of the object will be given by the app.") # create! %{model}
  TranslationHint.create!(:dot_key_code => "helpers.submit.submit",:heading => "Button Label", :example => "If you have a user object to add to the database then then the app gives the button 'User' as 'model'. The button will say 'Save User'", :description => "Label on a button that asks the user to save an object in the database. The name of the object will be given by the app.") # Save %{model}
  TranslationHint.create!(:dot_key_code => "helpers.submit.update",:heading => "Button Label", :example => "If you have a user object to save in the database then then the app gives the button 'User' as 'model'. The button will say 'Update User'", :description => "Label on a button that asks the user to update an object in the database. The name of the object will be given by the app.") # Update %{model}
  TranslationHint.create!(:dot_key_code => "number.currency.format.delimiter",:heading => "Currency Format", :example => "If delimiter is ',' then 5200 dollars is written as $5,200", :description => "Separates the thousands from the hundreds") # ,
  TranslationHint.create!(:dot_key_code => "number.currency.format.format",:heading => "Currency Order Format", :example => "If the format has the unit(%u) before the number(%n) for dollars then we may $40 ", :description => "The order of the currency unit and number") # %u%n
  TranslationHint.create!(:dot_key_code => "number.currency.format.precision",:heading => "Currency Format", :example => "", :description => "Gives the number of digits after the decimal in currency") # 2
  TranslationHint.create!(:dot_key_code => "number.currency.format.separator",:heading => "Currency Format", :example => "", :description => "Gives the character that shows the decimal part of the number") # .
  TranslationHint.create!(:dot_key_code => "number.currency.format.significant",:heading => "Currency Format", :example => "", :description => "Shoud be either '! false' or false.  'false' means that everything is rounded down by default. '! false' means that currency is rounded as you expect") # false
  TranslationHint.create!(:dot_key_code => "number.currency.format.strip_insignificant_zeros",:heading => "Currency Format", :example => "", :description => "Should be '! false' or false. 'false' means that you remove and zeros that don't mean anything") # false
  TranslationHint.create!(:dot_key_code => "number.currency.format.unit",:heading => "Currency Unit", :example => "€", :description => "Symbol of unit of currency") # $
  TranslationHint.create!(:dot_key_code => "number.format.delimiter",:heading => "Number Format", :example => "", :description => "This character separates thousands from hundres") # ,
  TranslationHint.create!(:dot_key_code => "number.format.precision",:heading => "Number Format", :example => "", :description => "Number of digits after the decimal for ordinary numbers") # 3
  TranslationHint.create!(:dot_key_code => "number.format.separator",:heading => "Number Format", :example => "", :description => "Decimal character for ordinary numbers") # .
  TranslationHint.create!(:dot_key_code => "number.format.significant",:heading => "Number Format", :example => "", :description =>"Leave as false")#"'false' indicates no proper rounding on easy read numbers. '! 'false'' indicates proper rounding up when needed") # false
  TranslationHint.create!(:dot_key_code => "number.format.strip_insignificant_zeros",:heading => "Number Format", :example => "1.00 beccomes 1 if this is true", :description => "'false' indictates no extra zeroes that have no meaning") # false
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.format",:heading => "Easy Read Format", :example => "If the format has the unit(%u) before the number(%n) for billions then we may 40 Billion ", :description => "The order of the number unit and number") # %n %u
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.units.billion",:heading => "Easy Read Format", :example => "", :description => "Billion") # Billion
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.units.million",:heading => "Easy Read Format", :example => "", :description => "Million") # Million
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.units.quadrillion",:heading => "Easy Read Format", :example => "", :description => "Quadrillion") # Quadrillion
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.units.thousand",:heading => "Easy Read Format", :example => "", :description => "Thousand") # Thousand
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.units.trillion",:heading => "Easy Read Format", :example => "", :description => "Trillion") # Trillion
  TranslationHint.create!(:dot_key_code => "number.human.decimal_units.units.unit",:heading => "Easy Read Format", :example => "", :description => "Used for making custom units: leave blank.") #
  TranslationHint.create!(:dot_key_code => "number.human.format.delimiter",:heading => "Easy Read", :example => "", :description => "Blank in English, Ok to leave blank unless youknow that it is needed.") #
  TranslationHint.create!(:dot_key_code => "number.human.format.precision",:heading => "Easy Read", :example => "number_to_human(1200000000) => 1 billion<br>number_to_human(1200000000) with precision 1 gives 1.2 billion", :description => "The number of decimals after the humanised number") # 3
  TranslationHint.create!(:dot_key_code => "number.human.format.significant",:heading => "Easy Read", :example => "", :description => "Leave as true") # true
  TranslationHint.create!(:dot_key_code => "number.human.format.strip_insignificant_zeros",:heading => "Easy Read", :example => "1.00 beccomes 1 if this is true", :description => "true indictates no extra zeroes that have no meaning") # true
  
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.format",:heading => "Computer Units", :example => "With %n %u 10 gigabytes becomes '10 GB'<br>With %u %n the user sees 'GB 10'", :description => "Specifies whether the number or the unit name comes first")# %n %u
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.units.byte.one",:heading => "Computer Units", :example => "", :description => "Singular of byte") # Byte
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.units.byte.other",:heading => "Computer Units", :example => "", :description => "Plural of byte") # Bytes
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.units.gb",:heading => "Computer Units", :example => "", :description => "Abbreviation for gigabytes") # GB
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.units.kb",:heading => "Computer Units", :example => "Computer Units", :description => "Abbreviation for kilobytes") # KB
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.units.mb",:heading => "Computer Units", :example => "", :description => "Abbreviation for megabytes") # MB
  TranslationHint.create!(:dot_key_code => "number.human.storage_units.units.tb",:heading => "Computer Units", :example => "", :description => "Abbreviation for terabytes") # TB
  TranslationHint.create!(:dot_key_code => "number.percentage.format.delimiter",:heading => "Pecentage Format", :example => "", :description => "Blank in English, Ok to leave blank unless youknow that it is needed.") #
  TranslationHint.create!(:dot_key_code => "number.percentage.format.format",:heading => "Pecentage Format", :example => "Using %n% 90 percent is 90%. Using %%n 90 percent is %90", :description => "Specify where the percentage symbol comes.") # %n%
  TranslationHint.create!(:dot_key_code => "number.precision.format.delimiter",:heading => "Number Format", :example => "", :description => "Blank in English, Ok to leave blank unless youknow that it is needed.") #
  TranslationHint.create!(:dot_key_code => "support.array.last_word_connector",:heading => "List Format", :example => "", :description => "In English 'and' is added between the second-last and last items of a list. Add your word or nothing here.") # , and
  TranslationHint.create!(:dot_key_code => "support.array.two_words_connector",:heading => "List Format", :example => "", :description => "In English 'and' is added between the 2 items of a 2-item-list. Add your word or nothing here.") #  and
  TranslationHint.create!(:dot_key_code => "support.array.words_connector",:heading => "List Format", :example => "", :description => "The separator for all items in a list except second last and last") # ,
  TranslationHint.create!(:dot_key_code => "time.am",:heading => "Time Format", :example => "", :description => "Abbreviation for before noon") # am
  TranslationHint.create!(:dot_key_code => "time.formats.default",:heading => "Time Format", :example => "", :description => "Choose the time format to be used when none is given") # %a, %d %b %Y %H:%M:%S %z
  TranslationHint.create!(:dot_key_code => "time.formats.long",:heading => "Time Format", :example => "", :description => "Choose the short(abbreviated) time format") # %B %d, %Y %H:%M
  TranslationHint.create!(:dot_key_code => "time.formats.short",:heading => "Time Format", :example => "", :description => "Choose the long time format for showing a detailed time") # %d %b %H:%M
  TranslationHint.create!(:dot_key_code => "time.pm",:heading => "Time Format", :example => "", :description => "Abbreviation for after noon and evening") # pm
  
  copy_am_errors_to_errors_and_ar
  end
  
  def self.copy_am_errors_to_errors_and_ar()
    am_hints = TranslationHint.where{dot_key_code =~ 'activemodel.errors.%'}
    am_hints.all.each do |hint|
      errors_code_array = hint.dot_key_code.split('.')
      errors_code = errors_code_array[1..errors_code_array.length - 1].join('.')
      ar_code = "activerecord." + errors_code
      TranslationHint.create!(:dot_key_code => errors_code, :heading=> hint.heading, :example => hint.example, :description => hint.description)
      TranslationHint.create!(:dot_key_code => ar_code, :heading=> hint.heading, :example => hint.example, :description => hint.description)
    end
  end
end
