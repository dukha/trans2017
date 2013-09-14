require "spec_helper"

describe TranslationsUploadsController do
  describe "routing" do

    it "routes to #index" do
      get("/translations_uploads").should route_to("translations_uploads#index")
    end

    it "routes to #new" do
      get("/translations_uploads/new").should route_to("translations_uploads#new")
    end

    it "routes to #show" do
      get("/translations_uploads/1").should route_to("translations_uploads#show", :id => "1")
    end

    it "routes to #edit" do
      get("/translations_uploads/1/edit").should route_to("translations_uploads#edit", :id => "1")
    end

    it "routes to #create" do
      post("/translations_uploads").should route_to("translations_uploads#create")
    end

    it "routes to #update" do
      put("/translations_uploads/1").should route_to("translations_uploads#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/translations_uploads/1").should route_to("translations_uploads#destroy", :id => "1")
    end

  end
end
