require 'spec_helper'

describe "TranslationEditorParams" do
  describe "GET /translation_editor_params" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get translation_editor_params_path(:locale=>'en')
      response.status.should be(302)
    end
  end
end
