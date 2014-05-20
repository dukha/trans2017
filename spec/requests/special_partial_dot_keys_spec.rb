require 'spec_helper'

describe "SpecialPartialDotKeys" do
  describe "GET /special_partial_dot_keys" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get special_partial_dot_keys_path(:locale=>'en')
      response.status.should be(302)
    end
  end
end
