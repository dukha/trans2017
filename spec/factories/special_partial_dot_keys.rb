# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :special_partial_dot_key do
    partial_dot_key "MyString"
    type ""
    cdlr false
  end
end
