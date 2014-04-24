require 'spec_helper'

describe "special_partial_dot_keys/new" do
  before(:each) do
    assign(:special_partial_dot_key, stub_model(SpecialPartialDotKey,
      :partial_dot_key => "MyString",
      :type => "",
      :cdlr => false
    ).as_new_record)
  end

  it "renders new special_partial_dot_key form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", special_partial_dot_keys_path, "post" do
      assert_select "input#special_partial_dot_key_partial_dot_key[name=?]", "special_partial_dot_key[partial_dot_key]"
      assert_select "input#special_partial_dot_key_type[name=?]", "special_partial_dot_key[type]"
      assert_select "input#special_partial_dot_key_cdlr[name=?]", "special_partial_dot_key[cdlr]"
    end
  end
end
