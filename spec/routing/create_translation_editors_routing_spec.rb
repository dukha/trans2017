require "spec_helper"

describe CreateTranslationEditorsController do
  describe "routing" do

    it "routes to #index" do
      get("/create_translation_editors").should route_to("create_translation_editors#index")
    end

    it "routes to #new" do
      get("/create_translation_editors/new").should route_to("create_translation_editors#new")
    end

    it "routes to #show" do
      get("/create_translation_editors/1").should route_to("create_translation_editors#show", :id => "1")
    end

    it "routes to #edit" do
      get("/create_translation_editors/1/edit").should route_to("create_translation_editors#edit", :id => "1")
    end

    it "routes to #create" do
      post("/create_translation_editors").should route_to("create_translation_editors#create")
    end

    it "routes to #update" do
      put("/create_translation_editors/1").should route_to("create_translation_editors#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/create_translation_editors/1").should route_to("create_translation_editors#destroy", :id => "1")
    end

  end
end
