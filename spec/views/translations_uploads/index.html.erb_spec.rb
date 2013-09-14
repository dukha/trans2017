require 'spec_helper'

describe "translations_uploads/index" do
  before(:each) do
    assign(:translations_uploads, [
      stub_model(TranslationsUpload,
        :translation_language_id => 1,
        :description => "Description"
      ),
      stub_model(TranslationsUpload,
        :translation_language_id => 1,
        :description => "Description"
      )
    ])
  end

  it "renders a list of translations_uploads" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
