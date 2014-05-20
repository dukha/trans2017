require "spec_helper"

describe TranslationEditorParamsController do
  describe "routing" do

    it "routes to #index" do
      get("/en/translation_editor_params").should route_to("translation_editor_params#index", :locale=>'en')
    end

    it "routes to #new" do
      get("/en/translation_editor_params/new").should route_to("translation_editor_params#new", :locale=>'en')
    end

    it "routes to #show" do
      get("/en/translation_editor_params/1").should route_to("translation_editor_params#show", :id => "1", :locale=>'en')
    end

    it "routes to #edit" do
      get("/en/translation_editor_params/1/edit").should route_to("translation_editor_params#edit", :id => "1", :locale=>'en')
    end

    it "routes to #create" do
      post("/en/translation_editor_params").should route_to("translation_editor_params#create", :locale=>'en')
    end

    it "routes to #update" do
      put("/en/translation_editor_params/1").should route_to("translation_editor_params#update", :id => "1", :locale=>'en')
    end

    it "routes to #destroy" do
      delete("/en/translation_editor_params/1").should route_to("translation_editor_params#destroy", :id => "1", :locale=>'en')
    end

  end
end
