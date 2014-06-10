FactoryGirl.define do
  factory :calmapp_version do
    sequence(:version) {|n| "#{n}.#{n+1}"}
    #binding.pry
    calmapp
    
    before(:create) do |version, evaluator|
      if not TranslationLanguage.where{iso_code=='en'}.exists?
        TranslationLanguage.seed()
      end # if
    end # before 
=begin    
    after(:create) do |version, evaluator|
      allow(version).to_receive(:add_english).and_return("add english stub")
    end #after 
=end 
  end #calmapp_version
end #FG