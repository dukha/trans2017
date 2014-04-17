require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe TranslationEditorsController do

  # This should return the minimal set of attributes required to create a valid
  # TranslationEditor. As you add validations to TranslationEditor, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "dot_key_code" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TranslationEditorsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all translation_editors as @translation_editors" do
      translation_editor = TranslationEditor.create! valid_attributes
      get :index, {}, valid_session
      assigns(:translation_editors).should eq([translation_editor])
    end
  end

  describe "GET show" do
    it "assigns the requested translation_editor as @translation_editor" do
      translation_editor = TranslationEditor.create! valid_attributes
      get :show, {:id => translation_editor.to_param}, valid_session
      assigns(:translation_editor).should eq(translation_editor)
    end
  end

  describe "GET new" do
    it "assigns a new translation_editor as @translation_editor" do
      get :new, {}, valid_session
      assigns(:translation_editor).should be_a_new(TranslationEditor)
    end
  end

  describe "GET edit" do
    it "assigns the requested translation_editor as @translation_editor" do
      translation_editor = TranslationEditor.create! valid_attributes
      get :edit, {:id => translation_editor.to_param}, valid_session
      assigns(:translation_editor).should eq(translation_editor)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TranslationEditor" do
        expect {
          post :create, {:translation_editor => valid_attributes}, valid_session
        }.to change(TranslationEditor, :count).by(1)
      end

      it "assigns a newly created translation_editor as @translation_editor" do
        post :create, {:translation_editor => valid_attributes}, valid_session
        assigns(:translation_editor).should be_a(TranslationEditor)
        assigns(:translation_editor).should be_persisted
      end

      it "redirects to the created translation_editor" do
        post :create, {:translation_editor => valid_attributes}, valid_session
        response.should redirect_to(TranslationEditor.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved translation_editor as @translation_editor" do
        # Trigger the behavior that occurs when invalid params are submitted
        TranslationEditor.any_instance.stub(:save).and_return(false)
        post :create, {:translation_editor => { "dot_key_code" => "invalid value" }}, valid_session
        assigns(:translation_editor).should be_a_new(TranslationEditor)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TranslationEditor.any_instance.stub(:save).and_return(false)
        post :create, {:translation_editor => { "dot_key_code" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested translation_editor" do
        translation_editor = TranslationEditor.create! valid_attributes
        # Assuming there are no other translation_editors in the database, this
        # specifies that the TranslationEditor created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TranslationEditor.any_instance.should_receive(:update).with({ "dot_key_code" => "MyString" })
        put :update, {:id => translation_editor.to_param, :translation_editor => { "dot_key_code" => "MyString" }}, valid_session
      end

      it "assigns the requested translation_editor as @translation_editor" do
        translation_editor = TranslationEditor.create! valid_attributes
        put :update, {:id => translation_editor.to_param, :translation_editor => valid_attributes}, valid_session
        assigns(:translation_editor).should eq(translation_editor)
      end

      it "redirects to the translation_editor" do
        translation_editor = TranslationEditor.create! valid_attributes
        put :update, {:id => translation_editor.to_param, :translation_editor => valid_attributes}, valid_session
        response.should redirect_to(translation_editor)
      end
    end

    describe "with invalid params" do
      it "assigns the translation_editor as @translation_editor" do
        translation_editor = TranslationEditor.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TranslationEditor.any_instance.stub(:save).and_return(false)
        put :update, {:id => translation_editor.to_param, :translation_editor => { "dot_key_code" => "invalid value" }}, valid_session
        assigns(:translation_editor).should eq(translation_editor)
      end

      it "re-renders the 'edit' template" do
        translation_editor = TranslationEditor.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TranslationEditor.any_instance.stub(:save).and_return(false)
        put :update, {:id => translation_editor.to_param, :translation_editor => { "dot_key_code" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested translation_editor" do
      translation_editor = TranslationEditor.create! valid_attributes
      expect {
        delete :destroy, {:id => translation_editor.to_param}, valid_session
      }.to change(TranslationEditor, :count).by(-1)
    end

    it "redirects to the translation_editors list" do
      translation_editor = TranslationEditor.create! valid_attributes
      delete :destroy, {:id => translation_editor.to_param}, valid_session
      response.should redirect_to(translation_editors_url)
    end
  end

end