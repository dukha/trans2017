require 'rails_helper'

RSpec.describe "translation_hints/show", :type => :view do
  before(:each) do
    @translation_hint = assign(:translation_hint, TranslationHint.create!(
      :heading => "Heading",
      :example => "Example",
      :description => "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Heading/)
    expect(rendered).to match(/Example/)
    expect(rendered).to match(/Description/)
  end
end
