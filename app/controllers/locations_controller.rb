# Actions are defined here, Subclass controllers only define 
class LocationsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_location, only: [ :edit, :update, :destroy, :show]
  #filter_access_to :all

  @@model = $ARM + "location"+".one"

  # the model name (e.g. "Venue") can be deduced from the subclassed controller name.
  # This is a requirement
  # model_name is a hook method
  def model_name
    answer = self.class.name
    answer.sub("Controller","").singularize
  end

  # model_class is a hook method
  # find the model class e.g. Venue
  def model_class
    model_name.constantize
  end

  # e.g. :venue
  def model_sym
    model_name.downcase.to_sym
  end
=begin
  def index
    @locations = model_class.paginate(:page => params[:page], :per_page=>15)    #model_class.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end
=end
  def index
    @root_node = current_user.current_organisation
  end
  # GET /locations/1
  # GET /locations/1.xml
  def show
    #@location = model_class.find(params[:id])
    binding.pry
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end

 # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = model_class.new
    @location.parent_id = params[:parent_id]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end




  # GET /locations/1/edit
  def edit
    #@location = model_class.find(params[:id])
    binding.pry
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = model_class.new(params[model_sym])

    respond_to do |format|
      if @location.save
        tflash('create', :success, {:model=>@@model, :count=>1})
        #flash[:success] = t('messages.create.success', :model=>t(
        format.html { redirect_to( location_tree_index_path)}# :action => "index")} #(@location #, :notice => 'model_class was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, model_sym => @location }
      else
        #dwhere is the translation happening here???
        flash.now[:error] = @location.errors
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /locations/1/delete
  def destroy
    #@location = model_class.find(params[:id])
    if !@location.deletable?
      #flash[:warning] = t('messages.deletion.rejected', :model=>t(
      tflash('delete.deletion_rejected', :warning, :model=>@location.class.name)
      #flash[:warning] = 'messages.deletion.rejected'
      redirect_to(location_tree_path)
      return
    end
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(location_tree_index_path) }
      format.xml  { head :ok }
    end
  end

  def update
    #debugger
    #@location = model_class.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[model_sym])
        #debugger
        #logger.info("in updated")
        tflash('update', :success, {:model=>@@model, :count=>1})
        #flash[:success] = t('messages.update.success', :model=>t(
        format.html { redirect_to(location_tree_path)} 
            #, :notice => t('messages.update.success', :model=>@@model)) }
        #format.html { redirect_to(  locations_path)}
            #:action => "index")} #(@location, :notice => 'model_class was successfully updated.') }
        format.xml  { head :ok }
        
        #logger.info("in updated 2")
      else
        #debugger
        #logger.info("in failed")
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
        
        #logger.info("in failed 2")
      end
    end
    
  end
=begin
  This function put in for clarity with the mark_deleted action.
  Note that the params from request are carried thru to update. The only updated attribute in the location
  hash is marked_delete
=end
  def mark_deleted
    update
  end
private
  def set_location
    @location = model_class.find(params[:id])
  end
  
  def location_params
    params.require(:location).permit(:name, :type, :parent_id, :translation_code, :marked_deleted, :fqdn)
  end
end
