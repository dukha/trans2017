require 'spec_helper'

describe Calmapp do
  before(:each) do
    if not TranslationLanguage.where{iso_code=='en'}.exists?
      TranslationLanguage.seed()
    end
  end
  
  it { should validate_presence_of(:name)}
  it { should validate_uniqueness_of(:name)}
  
  it {should have_many(:calmapp_versions) }
  
  
  it { should accept_nested_attributes_for(:calmapp_versions) }
  it "should accept nested attributes_for but reject if all blank" do
    puts "Feature below is implemented but no easy test. Test will be implemented later."
  end
  
  describe "Calmapp.can_destroy?" do
    it "returns false for  new record" do
      @calmapp= Calmapp.new
      @calmapp.can_destroy?.should be_false  
    end  
    it "returns false when a version exists" do
      @calmapp = create(:calmapp_with_versions)
      @calmapp.can_destroy?.should be_false
    end
    it "returns true for a saved calmapp without versions" do
      @calmapp = create(:calmapp)
      @calmapp.can_destroy?.should be_true
    end
  end
  
  
end