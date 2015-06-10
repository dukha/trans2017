require 'rails_helper'

RSpec.describe "contacts/index", type: :view do
  before(:each) do
    assign(:contacts, [
      Contact.create!(
        :problem_area => "Problem Area",
        :screen_name => "Screen Name",
        :last_menu_choice => "Last Menu Choice",
        :description => "MyText",
        :user_id => 1
      ),
      Contact.create!(
        :problem_area => "Problem Area",
        :screen_name => "Screen Name",
        :last_menu_choice => "Last Menu Choice",
        :description => "MyText",
        :user_id => 1
      )
    ])
  end

  it "renders a list of contacts" do
    render
    assert_select "tr>td", :text => "Problem Area".to_s, :count => 2
    assert_select "tr>td", :text => "Screen Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Menu Choice".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
