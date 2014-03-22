require 'spec_helper'

describe "anslation_editors/new" do
  before(:each) do
    assign(:anslation_editor, stub_model(TranslationEditor,
      :dot_key_code => "MyString",
      :editor => "MyString",
      :lambda => "MyString"
    ).as_new_record)
  end

  it "renders new anslation_editor form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", anslation_editors_path, "post" do
      assert_select "input#anslation_editor_dot_key_code[name=?]", "anslation_editor[dot_key_code]"
      assert_select "input#anslation_editor_editor[name=?]", "anslation_editor[editor]"
      assert_select "input#anslation_editor_lambda[name=?]", "anslation_editor[lambda]"
    end
  end
end
