require 'rails_helper'

RSpec.describe "contacts/edit", type: :view do
  before(:each) do
    @contact = assign(:contact, Contact.create!(
      :problem_area => "MyString",
      :screen_name => "MyString",
      :last_menu_choice => "MyString",
      :description => "MyText",
      :user_id => 1
    ))
  end

  it "renders the edit contact form" do
    render

    assert_select "form[action=?][method=?]", contact_path(@contact), "post" do

      assert_select "input#contact_problem_area[name=?]", "contact[problem_area]"

      assert_select "input#contact_screen_name[name=?]", "contact[screen_name]"

      assert_select "input#contact_last_menu_choice[name=?]", "contact[last_menu_choice]"

      assert_select "textarea#contact_description[name=?]", "contact[description]"

      assert_select "input#contact_user_id[name=?]", "contact[user_id]"
    end
  end
end
