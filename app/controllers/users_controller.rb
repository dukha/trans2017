class UsersController < ApplicationController

  before_filter :authenticate_user!
  filter_access_to :all

  @@model ="user"
  

  # users_select        /:locale/users_select(.:format)                                    {:controller=>"users", :action=>"select"}
  def select
    @users = User.paginate :page => params[:page], :per_page => 15 
    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @users }
    end
  end

  #edit_password GET   /:locale/users/:id/edit_password(.:format)   {:controller=>"users", :action=>"edit"}
  def edit
    @user = User.find(params[:id])
  end

  #update_password PUT /:locale/users/:id/update_password(.:format) {:controller=>"users", :action=>"update"}
  def update
    @user = User.find(params[:id])
    @user.unlock_access! unless !@user.access_locked?
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(users_select_path, :notice => "User #{@user.username} was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  #unlock_user PUT /:locale/users/:id/unlock_user(.:format) {:controller=>"users", :action=>"unlock_user"}
  def unlock_user
    @user = User.find(params[:id])
    @user.unlock_access! unless !@user.access_locked?
    respond_to do |format|
      if @user.save
        format.html { redirect_to(users_select_path, :notice => "User #{@user.username} was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end


end
