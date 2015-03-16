require "spec_helper"

describe TranslationsUploadsController do
  describe "routing" do
=begin
    it "routes to #index" do
      get("/en/translations_uploads").should route_to("translations_uploads#index", :locale=>'en')
    end

    it "routes to #new" do
      get("/en/translations_uploads/new").should route_to("translations_uploads#new", :locale=>'en')
    end

    it "routes to #show" do
      get("/en/translations_uploads/1").should route_to("translations_uploads#show", :id => "1", :locale=>'en')
    end

    it "routes to #edit" do
      get("/en/translations_uploads/1/edit").should route_to("translations_uploads#edit", :id => "1", :locale=>'en')
    end

    it "routes to #create" do
      post("/en/translations_uploads").should route_to("translations_uploads#create", :locale=>'en')
    end

    it "routes to #update" do
      put("/en/translations_uploads/1").should route_to("translations_uploads#update", :id => "1", :locale=>'en')
    end

    it "routes to #destroy" do
      delete("/en/translations_uploads/1").should route_to("translations_uploads#destroy", :id => "1", :locale=>'en')
    end
=end
  end
end
