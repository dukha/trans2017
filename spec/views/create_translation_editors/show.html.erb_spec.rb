require 'spec_helper'

describe "create_translation_editors/show" do
  before(:each) do
    @create_translation_editor = assign(:create_translation_editor, stub_model(CreateTranslationEditor,
      :dot_key_code => "Dot Key Code",
      :editor => "Editor",
      :lambda => "Lambda"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Dot Key Code/)
    rendered.should match(/Editor/)
    rendered.should match(/Lambda/)
  end
end
