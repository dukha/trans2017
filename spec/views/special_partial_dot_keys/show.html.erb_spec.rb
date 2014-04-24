require 'spec_helper'

describe "special_partial_dot_keys/show" do
  before(:each) do
    @special_partial_dot_key = assign(:special_partial_dot_key, stub_model(SpecialPartialDotKey,
      :partial_dot_key => "Partial Dot Key",
      :type => "Type",
      :cdlr => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Partial Dot Key/)
    rendered.should match(/Type/)
    rendered.should match(/false/)
  end
end
