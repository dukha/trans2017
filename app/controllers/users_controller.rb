class UsersController < ApplicationController #Devise::RegistrationsController

  before_action :authenticate_user!
  before_action :set_user, only: [ :edit, :update, :destroy, :unlock_user]
  #before_action :test
  filter_access_to :all
  #respond_to :html, :xml, :json
  @@model ="user"
  
  
  def invite_user
    binding.pry
    @user = User.invite!(:email => params[:user][:email], :name => params[:user][:name])
    render :html => @user
  end

  # users_select        /:locale/users_select(.:format)                                    {:controller=>"users", :action=>"select"}
  def index
    #binding.pry#respond_to :html, :xml, :json
    @users = User.paginate :page => params[:page], :per_page => 15
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @translation_languages }
    end
 
=begin    
    respond_to do |format|
      format.html  
      format.xml  { render :xml => @users }
    end
=end
  end
  
  def new
    @user = User.new
  end
  def create
    #build_resource(sign_up_params)
    #binding.pry
    @user = User.new(user_params)
    if @user.save
      #redirect_to admin_editors_path
      redirect_to users_path
    else
      #clean_up_passwords resource
      #respond_with resource
      flash[:error] = "Failed to save " + @user.username
      render :action => :new
    end
  end
=begin
  def create
    @user = User.new(user_params)
    binding.pry
    respond_to do |format|
      if @user.save
        binding.pry
        format.html{redirect_to(users_select_path, :notice => "Creating user: #{@user.username} was successful.") }
        format.xml{head :ok }
      else
        binding.pry
        format.html { render :action => "new" }
        format.xml  { render :xml => @calmapp_version.errors, :status => :unprocessable_entity }
     end #save 2   
    end #do    
  end
=end  
  #edit_password GET   /:locale/users/:id/edit_password(.:format)   {:controller=>"users", :action=>"edit"}
  def edit
    #@user = User.find(params[:id])
  end

  #update_password PUT /:locale/users/:id/update_password(.:format) {:controller=>"users", :action=>"update"}
  def update
    #@user = User.find(params[:id])
    @user.unlock_access! unless !@user.access_locked?
    respond_to do |format|
      if @user.update(user_params)#params[:user])
        format.html { redirect_to(users_path, :notice => "User #{@user.username} was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  #unlock_user PUT /:locale/users/:id/unlock_user(.:format) {:controller=>"users", :action=>"unlock_user"}
  def unlock_user
    #@user = User.find(params[:id])
    @user.unlock_access! unless !@user.access_locked?
    respond_to do |format|
      if @user.save
        format.html { redirect_to(users_path, :notice => "User #{@user.username} was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    tflash('delete', :success, {:model=>@@model, :count=>1, :now=> true})
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.js {}
    end
  end
private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end  
  def  user_params
  params.require(:user).permit(:email, :password, :password_confirmation, :remember_me,
                :username, :login, :actual_name)
  end
end
