require 'rails_helper'

RSpec.describe "translation_hints/new", :type => :view do
  before(:each) do
    assign(:translation_hint, TranslationHint.new(
      :heading => "MyString",
      :example => "MyString",
      :description => "MyString"
    ))
  end

  it "renders new translation_hint form" do
    render

    assert_select "form[action=?][method=?]", translation_hints_path, "post" do

      assert_select "input#translation_hint_heading[name=?]", "translation_hint[heading]"

      assert_select "input#translation_hint_example[name=?]", "translation_hint[example]"

      assert_select "input#translation_hint_description[name=?]", "translation_hint[description]"
    end
  end
end
