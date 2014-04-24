require 'spec_helper'

describe "special_partial_dot_keys/index" do
  before(:each) do
    assign(:special_partial_dot_keys, [
      stub_model(SpecialPartialDotKey,
        :partial_dot_key => "Partial Dot Key",
        :type => "Type",
        :cdlr => false
      ),
      stub_model(SpecialPartialDotKey,
        :partial_dot_key => "Partial Dot Key",
        :type => "Type",
        :cdlr => false
      )
    ])
  end

  it "renders a list of special_partial_dot_keys" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Partial Dot Key".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
