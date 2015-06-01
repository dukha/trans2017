#class Users::InvitationsController < Devise::InvitationsController
#This odes not work for {:controller =>  { :invitations => 'users/invitations' }} in routes
class InvitationsController < Devise::InvitationsController
  #This works for {:controller =>  { :invitations => 'invitations' }} in routes
  before_action :authenticate_user!
  filter_access_to :all
  
  # the views that are found are devise/invitations/new
  def new
    binding.pry
    super
  end
  def update
    binding.pry
    super
  end
  def create
    binding.pry
    super
  end
  def edit
    binding.pry
    super
  end
end