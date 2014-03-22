require 'spec_helper'

describe "translation_editor_params/new" do
  before(:each) do
    assign(:translation_editor_param, stub_model(TranslationEditorParam,
      :dot_key_code => "MyString",
      :param_name => "MyString",
      :param_order => "MyString",
      :param_default => "MyString"
    ).as_new_record)
  end

  it "renders new translation_editor_param form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", translation_editor_params_path, "post" do
      assert_select "input#translation_editor_param_dot_key_code[name=?]", "translation_editor_param[dot_key_code]"
      assert_select "input#translation_editor_param_param_name[name=?]", "translation_editor_param[param_name]"
      assert_select "input#translation_editor_param_param_order[name=?]", "translation_editor_param[param_order]"
      assert_select "input#translation_editor_param_param_default[name=?]", "translation_editor_param[param_default]"
    end
  end
end
