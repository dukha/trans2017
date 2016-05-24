class UsersController < ApplicationController #Devise::RegistrationsController

  before_action :authenticate_user!, except: :timezone_offset
  before_action :set_user, only: [ :edit, :update, :destroy, :unlock_user, :translatorpublishing]
  filter_access_to [:edit, :update, :destroy, :unlock_user, :translatorpublishing, :new,:index,:create]#:all
  @@model ="user"
  
  def index
    per_page = 20
    if User.respond_to? :searchable_attr  
      searchable_attr = User.searchable_attr 
    else 
      searchable_attr = [] 
    end
    if User.respond_to? :sortable_attr  
      sortable_attr = User.sortable_attr     
    else   
      sortable_attr = []   
    end
    
    @users = User.order("actual_name")
    extra_where_clauses = prepare_mode()

    if not extra_where_clauses.empty? then
      extra_where_clauses.each{ |c| @users = @users.where(c)}
    end
    if searchable_attr.nil? || searchable_attr.empty?  
      @users = @users.paginate(:page => params[:page], :per_page=>per_page)
    else
      search_info = init_search(current_user, searchable_attr, sortable_attr)
      @users = @users.search(current_user, search_info).paginate(:page => params[:page], :per_page=>per_page)
    end
    #@users = @users.paginate :page => params[:page], :per_page => 15
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @translation_languages }
    end
  end
  
  def new

    @user = User.new
  end
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path
    else
      flash[:error] = "Failed to save " + @user.username
      render :action => :new
    end
  end


  
  def edit
    
  end

  #update_password PUT /:locale/users/:id/update_password(.:format) {:controller=>"users", :action=>"update"}
  def update   
    @user.unlock_access! unless !@user.access_locked?
    
    assign_first_premissions = false
    
    if set_permission_after_invitation_accept()
      assign_first_premissions = true     
    end
    
    respond_to do |format|
  
      if @user.update(user_params)#params[:user])
       
        if assign_first_premissions && (! @user.roles_list.empty?) then
          begin
            AdminMailer.notify_user_permissions_assigned_after_invitation(@user.id).deliver_later
          rescue Exception => e
            ExceptionNotifier.notify_exception(e,
             :data=> {:message => e.message})
          end
        end
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
    begin
    @user.destroy
    tflash('delete', :success, {:model=>@@model, :count=>1, :now=> true})
    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.js {}
    end
    rescue StandardError => e
      @user = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end
  
  def timezone_offset
    #binding.pry
    puts "TZO1"
    tzo = params[:tzo]
    puts "TZO2 " + tzo
    if ! tzo.nil?
      if JSON.is_json?(tzo) then
        tzo = ActiveSupport::JSON.decode(tzo)
      end
      
=begin      
      binding.pry
      puts "TZO3 session" 
      session[:timezone_offset] = tzo
      cookies[:timezone_offset] = tzo
      cookies.permanent[:timezone_offset] = tzo
      puts "Showing Session offset"
      puts session[:timezone_offset]
      puts session[:timezone_offset].is_a? Integer
      puts cookies[:timezone_offset]
      puts cookies[:timezone_offset].is_a? Integer
      puts cookies.permanent[:timezone_offset]
      puts cookies.permanent[:timezone_offset].is_a? Integer
=end      
    end
    #current_user.timezone_offset = tzo
    #current_user.save
    render :nothing => true
  end
  def translatorpublishing
    begin
      result = User.what_translations_can_user_publish(@user)
      view_none = "You cannot publish to any redis database." if  result.empty?
      @view = ''
      
      if result.is_a? Array
        result.each{ |rdb|
          @view = @view + "\n" + rdb.description
        }
      end
      @view = view_none if @view == ''
    rescue StandardError => se
        @view = se.message
    end
    flash[:info] = @view
    respond_to do |format|
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
  def set_permission_after_invitation_accept
    
    ret_val =  ((! @user.invited_by_id.nil?)  && 
      (@user.profiles.count == 1) &&
      (@user.profiles[0].name == "guest") )#&&
      #(! @user.invitation_token.nil?)) #&& (signin_count == 1)
      
    return ret_val  
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end  
  def  user_params
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
