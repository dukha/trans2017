# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :translation_hint do
    heading "MyString"
    example "MyString"
    description "MyString"
    dot_key_code "MyString"
  end
end
