require 'spec_helper'

describe "translations_uploads/show" do
  before(:each) do
    @translations_upload = assign(:translations_upload, stub_model(TranslationsUpload,
      :translation_language_id => 1,
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Description/)
  end
end
