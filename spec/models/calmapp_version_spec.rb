describe CalmappVersion do
  before(:each) do
    if not TranslationLanguage.where{iso_code=='en'}.exists?
      TranslationLanguage.seed()
    end
  end
  it {should belong_to(:calmapp)}
  it {should have_many(:redis_database) }
  it { should accept_nested_attributes_for(:redis_database) }
  
  #it {should have_many(:redis_databases).through(:calmapp_versions_redis_database) }
  describe "validations" do
    before(:all) do
       CalmappVersion.delete_all
       Calmapp.delete_all
       @calmapp = create(:calmapp_with_versions)
       CalmappVersion.skip_callback(:create, :after, :add_english )
    end
    it { should validate_presence_of(:version)}
    #binding.pry
    it { should validate_uniqueness_of(:version).scoped_to(:calmapp_id) }
    #it {should validate_numericality_of(:version)}
  end #validations
  
  #CalmappVersion.create(:calmapp_id =>4, version: 6.7)
  #it "should validate uniqueness of version attr" do
    # we have to wrap this in an an extra it so that FG create can work
    # shoulda can then check the uniqueness with existing records like it wants to
    # otherwise it throws an error
    #@calmapp = create(:calmapp_with_versions)#.calmapp_versions.first
    #it { should validate_uniqueness_of(:version).scoped_to(:calmapp)}
  #end
  
end # CalmappVersion