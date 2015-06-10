require 'rails_helper'

RSpec.describe "contacts/show", type: :view do
  before(:each) do
    @contact = assign(:contact, Contact.create!(
      :problem_area => "Problem Area",
      :screen_name => "Screen Name",
      :last_menu_choice => "Last Menu Choice",
      :description => "MyText",
      :user_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Problem Area/)
    expect(rendered).to match(/Screen Name/)
    expect(rendered).to match(/Last Menu Choice/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
  end
end
