class DotKeyCodeTranslationEditor < ActiveRecord::Base
  
  validates :dot_key_code, :presence => true, :uniqueness=>true
  validates :editor, :presence => true
  def self.seed
    attrs = [
      {:dot_key_code =>"number.currency.format.format", :editor=>"decimal_format"},
      {:dot_key_code =>"number.human_decimal_units.format", :editor=>"decimal_format"},
      {:dot_key_code =>"number.human.storage_units.format", :editor=>"decimal_format"},
      {:dot_key_code =>"number.human.percentage.format", :editor=>"decimal_format"},
     
      {:dot_key_code =>"time.formats.default", :editor=>"time_format"},
      {:dot_key_code =>"time.formats.long", :editor=>"time_format"},
      {:dot_key_code =>"time.formats.short", :editor=>"time_format"},
     
      {:dot_key_code =>"date.formats.default", :editor=>"date_format"},
      {:dot_key_code =>"date.formats.long", :editor=>"date_format"},
      {:dot_key_code =>"date.formats.short", :editor=>"date_format"},
      
      {:dot_key_code =>"date.abbr_day_names", :editor=>"array"}, # first_nil, member_count
      {:dot_key_code =>"date.min_day_names", :editor=>"array"},
      {:dot_key_code =>"date.day_names", :editor=>"array"},
      
      {:dot_key_code =>"date.abbr_month_names", :editor=>"array"},
      {:dot_key_code =>"date.min_month_names", :editor=>"array"},
      {:dot_key_code =>"date.month_names", :editor=>"array"},
      
      {:dot_key_code =>"date.order", :editor=>"array_order"}
    ]
    attrs.each{|hash| DotKeyCodeTranslationEditor.new(hash).save!}
  end
end
