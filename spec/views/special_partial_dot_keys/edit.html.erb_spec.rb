require 'spec_helper'

describe "special_partial_dot_keys/edit" do
  before(:each) do
    @special_partial_dot_key = assign(:special_partial_dot_key, stub_model(SpecialPartialDotKey,
      :partial_dot_key => "MyString",
      :type => "",
      :cdlr => false
    ))
  end

  it "renders the edit special_partial_dot_key form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", special_partial_dot_key_path(@special_partial_dot_key), "post" do
      assert_select "input#special_partial_dot_key_partial_dot_key[name=?]", "special_partial_dot_key[partial_dot_key]"
      assert_select "input#special_partial_dot_key_type[name=?]", "special_partial_dot_key[type]"
      assert_select "input#special_partial_dot_key_cdlr[name=?]", "special_partial_dot_key[cdlr]"
    end
  end
end
