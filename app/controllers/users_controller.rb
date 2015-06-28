class UsersController < ApplicationController #Devise::RegistrationsController

  before_action :authenticate_user!
  before_action :set_user, only: [ :edit, :update, :destroy, :unlock_user]
  #before_action :test
  filter_access_to :all
  #respond_to :html, :xml, :json
  @@model ="user"
  
=begin @deprecated  
  def invite_user
    binding.pry
    @user = User.invite!(:email => params[:user][:email], :name => params[:user][:name])
    render :html => @user
  end
=end
  # users_select        /:locale/users_select(.:format)                                    {:controller=>"users", :action=>"select"}
  def index
    #binding.pry#respond_to :html, :xml, :json
    @users = User.order("actual_name")
    extra_where_clauses = prepare_mode()
    #binding.pry
    if not extra_where_clauses.empty? then
      extra_where_clauses.each{ |c| @users = @users.where(c)}
    end
    @users = @users.paginate :page => params[:page], :per_page => 15
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
    #binding.pry
    @user = User.new
  end
  def create
    #build_resource(sign_up_params)
    #binding.pry
    @user = User.new(user_params)
    #@user.profile_ids = []
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

  def reset_user_password
    
  end
  #edit_password GET   /:locale/users/:id/edit_password(.:format)   {:controller=>"users", :action=>"edit"}
  def edit
    #@user = User.find(params[:id])
    #@user.profile_ids = @user.profiles.collect { |p| p.id }
  end

  #update_password PUT /:locale/users/:id/update_password(.:format) {:controller=>"users", :action=>"update"}
  def update
    #@user = User.find(params[:id])
   
    @user.unlock_access! unless !@user.access_locked?
   
    respond_to do |format|
      #binding.pry
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
  
  protected
  def prepare_mode
    mode = params["selection_mode"]
    extra_where_clauses = []
    invitee_where = "invitation_created_at is not null and invitation_accepted_at is null"
    valid_where = "invitation_token is null"
    if mode == "invitee" then
      extra_where_clauses << invitee_where
    elsif mode == "valid" then
      extra_where_clauses << valid_where
    else # all
      # do nothing    
    end
    return extra_where_clauses
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
=begin   
  if not @user.new_record? then
      @user.password = ''
    end
=end
  end  
  def  user_params
    #binding.pry
    
    standard_attr = [:email,  :remember_me,
                :username, :login, :actual_name, :translator, :developer, :application_administrator, 
                :country, :phone, :responds_to_contacts,
                {:profile_ids => []}, 
                {:translator_cavs_tl_ids=>[]}, 
                {:developer_cavs_tl_ids=>[]}, 
                {:administrator_cavs_tl_ids=>[]} ]
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank? then
      #If the user does not try to update the pw, the we don't update to null (fail anyway)
      return params.require(:user).permit(standard_attr)
    else
      return params.require(:user).permit(standard_attr << [:password, :password_confirmation])
    end 
  
  end
end
=begin
 <%= f.collection_check_boxes :venue_ids, Venue.all, :id, :name, checked: Venue.all.map(&:id) do |b| %>
  <span>
    <%= b.check_box %>
    <%= b.label %>
  </span>
<% end %> 
=end