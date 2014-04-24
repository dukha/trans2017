class TranslationEditor < ActiveRecord::Base
  
  def self.translation_editors
    return %w(array time_format data_format array_order decimal_format long_text_editor)
  end
end
