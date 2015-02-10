class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  filter_access_to :all

  # GET /profiles
  # GET /profiles.xml
  def index
    @profiles = Profile.paginate :page => params[:page], :per_page => 15 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    #@profile = Profile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.xml
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    #@profile = Profile.find(params[:id])
  end

  # POST /profiles
  # POST /profiles.xml
  def create
    @profile = Profile.new(profile_params)
 
    respond_to do |format|
      if @profile.save
        format.html { redirect_to(profiles_url, :notice => 'Profile was successfully created.') }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    #@profile = Profile.find(params[:id])
    binding.pry
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to(profiles_url, :notice => 'Profile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    #@profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.js {}
    end
  end
  
  private
    def  profile_params
      roles_array_2_sym
      params.require(:profile).permit(:name, :rools=>[])
    end
    
    def set_profile
      @profile = Profile.find(params[:id])
    end  
    
    def roles_array_2_sym
      #binding.pry
      if not params["profile"]["rools"].nil? then
        if params["profile"]["rools"].is_a? Array
          params["profile"]["rools"].collect! { |role| role.to_sym  if role.is_a? String}
        end
      end
    end
end
