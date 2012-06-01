# operations on the nodes of the location tree
# there is only one such tree, there is only one root of the tree. Therefore singular.
# the only job is to show the correct dialog for this node and the current_user

class LocationTreeController < ApplicationController
  before_filter :authenticate_user!
  filter_access_to :show
  filter_access_to :index
  filter_access_to :all

  def show
    #the menu action displays menu to ask user to add remove edit display a location
    @location = Location.find(params[:id])
  end

  def index
    @root_node = current_user.current_organisation
  end
end

