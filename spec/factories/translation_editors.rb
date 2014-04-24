# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :translation_editor do
    dot_key_code "MyString"
    editor "MyString"
    #lambda "MyString"
  end
end
