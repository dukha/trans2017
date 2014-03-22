require "spec_helper"

describe TranslationEditorParamsController do
  describe "routing" do

    it "routes to #index" do
      get("/translation_editor_params").should route_to("translation_editor_params#index")
    end

    it "routes to #new" do
      get("/translation_editor_params/new").should route_to("translation_editor_params#new")
    end

    it "routes to #show" do
      get("/translation_editor_params/1").should route_to("translation_editor_params#show", :id => "1")
    end

    it "routes to #edit" do
      get("/translation_editor_params/1/edit").should route_to("translation_editor_params#edit", :id => "1")
    end

    it "routes to #create" do
      post("/translation_editor_params").should route_to("translation_editor_params#create")
    end

    it "routes to #update" do
      put("/translation_editor_params/1").should route_to("translation_editor_params#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/translation_editor_params/1").should route_to("translation_editor_params#destroy", :id => "1")
    end

  end
end
