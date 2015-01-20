require 'rails_helper'

RSpec.describe "translation_hints/index", :type => :view do
  before(:each) do
    assign(:translation_hints, [
      TranslationHint.create!(
        :heading => "Heading",
        :example => "Example",
        :description => "Description"
      ),
      TranslationHint.create!(
        :heading => "Heading",
        :example => "Example",
        :description => "Description"
      )
    ])
  end

  it "renders a list of translation_hints" do
    render
    assert_select "tr>td", :text => "Heading".to_s, :count => 2
    assert_select "tr>td", :text => "Example".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
