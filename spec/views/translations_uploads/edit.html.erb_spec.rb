require 'spec_helper'

describe "translations_uploads/edit" do
  before(:each) do
    @translations_upload = assign(:translations_upload, stub_model(TranslationsUpload,
      :translation_language_id => 1,
      :description => "MyString"
    ))
  end

  it "renders the edit translations_upload form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", translations_upload_path(@translations_upload), "post" do
      assert_select "input#translations_upload_translation_language_id[name=?]", "translations_upload[translation_language_id]"
      assert_select "input#translations_upload_description[name=?]", "translations_upload[description]"
    end
  end
end
