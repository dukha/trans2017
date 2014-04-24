require "spec_helper"

describe SpecialPartialDotKeysController do
  describe "routing" do

    it "routes to #index" do
      get("/special_partial_dot_keys").should route_to("special_partial_dot_keys#index")
    end

    it "routes to #new" do
      get("/special_partial_dot_keys/new").should route_to("special_partial_dot_keys#new")
    end

    it "routes to #show" do
      get("/special_partial_dot_keys/1").should route_to("special_partial_dot_keys#show", :id => "1")
    end

    it "routes to #edit" do
      get("/special_partial_dot_keys/1/edit").should route_to("special_partial_dot_keys#edit", :id => "1")
    end

    it "routes to #create" do
      post("/special_partial_dot_keys").should route_to("special_partial_dot_keys#create")
    end

    it "routes to #update" do
      put("/special_partial_dot_keys/1").should route_to("special_partial_dot_keys#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/special_partial_dot_keys/1").should route_to("special_partial_dot_keys#destroy", :id => "1")
    end

  end
end
