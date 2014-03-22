require 'spec_helper'

describe "translation_editor_params/show" do
  before(:each) do
    @translation_editor_param = assign(:translation_editor_param, stub_model(TranslationEditorParam,
      :dot_key_code => "Dot Key Code",
      :param_name => "Param Name",
      :param_order => "Param Order",
      :param_default => "Param Default"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Dot Key Code/)
    rendered.should match(/Param Name/)
    rendered.should match(/Param Order/)
    rendered.should match(/Param Default/)
  end
end
