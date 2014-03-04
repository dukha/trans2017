require 'spec_helper'

describe "create_translation_editors/new" do
  before(:each) do
    assign(:create_translation_editor, stub_model(CreateTranslationEditor,
      :dot_key_code => "MyString",
      :editor => "MyString",
      :lambda => "MyString"
    ).as_new_record)
  end

  it "renders new create_translation_editor form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", create_translation_editors_path, "post" do
      assert_select "input#create_translation_editor_dot_key_code[name=?]", "create_translation_editor[dot_key_code]"
      assert_select "input#create_translation_editor_editor[name=?]", "create_translation_editor[editor]"
      assert_select "input#create_translation_editor_lambda[name=?]", "create_translation_editor[lambda]"
    end
  end
end
