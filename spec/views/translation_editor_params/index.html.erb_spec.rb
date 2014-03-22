require 'spec_helper'

describe "translation_editor_params/index" do
  before(:each) do
    assign(:translation_editor_params, [
      stub_model(TranslationEditorParam,
        :dot_key_code => "Dot Key Code",
        :param_name => "Param Name",
        :param_order => "Param Order",
        :param_default => "Param Default"
      ),
      stub_model(TranslationEditorParam,
        :dot_key_code => "Dot Key Code",
        :param_name => "Param Name",
        :param_order => "Param Order",
        :param_default => "Param Default"
      )
    ])
  end

  it "renders a list of translation_editor_params" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Dot Key Code".to_s, :count => 2
    assert_select "tr>td", :text => "Param Name".to_s, :count => 2
    assert_select "tr>td", :text => "Param Order".to_s, :count => 2
    assert_select "tr>td", :text => "Param Default".to_s, :count => 2
  end
end
