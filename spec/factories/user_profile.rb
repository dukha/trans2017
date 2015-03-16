# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_profile, :class => 'UserProfile' do
    user_id 1
    profile_id 1
  end
end
