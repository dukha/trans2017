require 'rails_helper'

RSpec.describe "TranslationHints", :type => :request do
  describe "GET /translation_hints" do
    it "works! (now write some real specs)" do
      get translation_hints_path
      expect(response).to have_http_status(200)
    end
  end
end
