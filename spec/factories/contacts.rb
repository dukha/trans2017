# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    problem_area "MyString"
    screen_name "MyString"
    last_menu_choice "MyString"
    description "MyText"
    user_id 1
  end
end
