require "spec_helper"

describe TranslationEditorsController do
  describe "routing" do

    it "routes to #index" do
      get("/translation_editors").should route_to("translation_editors#index")
    end

    it "routes to #new" do
      get("/translation_editors/new").should route_to("translation_editors#new")
    end

    it "routes to #show" do
      get("/translation_editors/1").should route_to("translation_editors#show", :id => "1")
    end

    it "routes to #edit" do
      get("/translation_editors/1/edit").should route_to("translation_editors#edit", :id => "1")
    end

    it "routes to #create" do
      post("/translation_editors").should route_to("translation_editors#create")
    end

    it "routes to #update" do
      put("/translation_editors/1").should route_to("translation_editors#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/translation_editors/1").should route_to("translation_editors#destroy", :id => "1")
    end

  end
end
