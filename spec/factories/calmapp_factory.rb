FactoryGirl.define do
  factory :calmapp do
    sequence(:name){|n| "app#{n}" }
    factory :calmapp_with_versions do
      # FG v 4.4.0 use ignore, not transient until 5.0.0
      ignore do
        versions_count 3
      end
      after(:create) do |calmapp, evaluator|
       create_list(:calmapp_version, evaluator.versions_count, calmapp: calmapp)
      end #after
      #factory :calmapp_with_version_add_english do
        
      #end # factory :calmapp_with_version_add_english do
    end # calmapp_with_versions
  end #calmapp
end #factorygirl