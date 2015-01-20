require 'rails_helper'

RSpec.describe "translation_hints/edit", :type => :view do
  before(:each) do
    @translation_hint = assign(:translation_hint, TranslationHint.create!(
      :heading => "MyString",
      :example => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit translation_hint form" do
    render

    assert_select "form[action=?][method=?]", translation_hint_path(@translation_hint), "post" do

      assert_select "input#translation_hint_heading[name=?]", "translation_hint[heading]"

      assert_select "input#translation_hint_example[name=?]", "translation_hint[example]"

      assert_select "input#translation_hint_description[name=?]", "translation_hint[description]"
    end
  end
end
