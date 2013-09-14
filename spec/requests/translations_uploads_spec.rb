require 'spec_helper'

describe "TranslationsUploads" do
  describe "GET /translations_uploads" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get translations_uploads_path
      response.status.should be(200)
    end
  end
end
