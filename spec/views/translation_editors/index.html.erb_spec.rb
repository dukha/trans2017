require 'spec_helper'

describe "translation_editors/index" do
  before(:each) do
    assign(:translation_editors, [
      stub_model(TranslationEditor,
        :dot_key_code => "Dot Key Code",
        :editor => "Editor",
        :lambda => "Lambda"
      ),
      stub_model(TranslationEditor,
        :dot_key_code => "Dot Key Code",
        :editor => "Editor",
        :lambda => "Lambda"
      )
    ])
  end

  it "renders a list of translation_editors" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Dot Key Code".to_s, :count => 2
    assert_select "tr>td", :text => "Editor".to_s, :count => 2
    assert_select "tr>td", :text => "Lambda".to_s, :count => 2
  end
end
