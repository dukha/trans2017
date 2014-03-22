require 'spec_helper'

describe "translation_editors/edit" do
  before(:each) do
    @translation_editor = assign(:translation_editor, stub_model(TranslationEditor,
      :dot_key_code => "MyString",
      :editor => "MyString",
      :lambda => "MyString"
    ))
  end

  it "renders the edit translation_editor form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", translation_editor_path(@translation_editor), "post" do
      assert_select "input#translation_editor_dot_key_code[name=?]", "translation_editor[dot_key_code]"
      assert_select "input#translation_editor_editor[name=?]", "translation_editor[editor]"
      assert_select "input#translation_editor_lambda[name=?]", "translation_editor[lambda]"
    end
  end
end
