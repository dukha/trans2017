class Users::InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!
  filter_access_to :all
  
  def new
    super
  end
  def update
    super
  end
  def create
    super
  end
  def edit
    super
  end
end