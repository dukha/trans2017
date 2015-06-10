class StaticPagesController < ApplicationController
  before_filter :authenticate_user!
  
  def about
    @title="About"
  end

 
  
  

end
