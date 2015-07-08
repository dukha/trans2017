class CalmappsController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  before_action :authenticate_user!
  before_action :set_calmapp, only: [ :edit, :update, :destroy, :show]
  filter_access_to :all
 
  @@model ="calmapp"
  
  def index
    #@applications = Calmapp.all
    @calmapps =  Calmapp.paginate(:page => params[:page], :per_page=>15)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @calmapps }
    end
  end

  # GET /calmapps/1
  # GET /applications/1.xml
  def show
    #binding.pry
    #@calmapp = Calmapp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calmapp }
    end
  end


  def new   
    @calmapp = Calmapp.new
    @calmapp_version = CalmappVersion.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @calmapp }
    end
  end
  def create
    @calmapp = Calmapp.new(calmapp_params) 
    #binding.pry
    respond_to do |format|
      if @calmapp.save( )
        format.html { redirect_to calmapps_url, notice: 'Calmapp was successfully created.' }
        format.json { render action: 'show', status: :created, location: @calmapp }
      else
        #binding.pry
        format.html { render action: 'new' }
        format.json { render json: @calmapp.errors, status: :unprocessable_entity }
      end
    end
 
  end
  # GET /calmapps/1/edit
  def edit

  end

  # PUT /applications/1
  # PUT /calmapps/1.xml
  def update
    #@calmapp = Calmapp.find(calmapp_params)#params[:id])
  
    
    respond_to do |format|
      #binding.pry
      if @calmapp.update(calmapp_params) #params[:calmapp], without_protection: true)
        
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(:action=>:index) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @calmapp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /applications/1
  # DELETE /calmapps/1.xml
  def destroy
    begin
      @calmapp.destroy
      #tflash('delete', :success, {:model=>@@model, :count=>1})
      respond_to do |format|
        tflash('delete', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(calmapps_url) }
        format.js {}
      end 
    rescue ActiveRecord::DeleteRestrictionError => e
      # We need to do this here as an calmapp cannot be deleted whilst it has dependent versions
      @calmapp.errors.add(:base, e)
      #redirect_to calmapps_path
      render :action=> "index"
    end
  end

  # rails 4 Strong Params needs this: Not tested yet
  def calmapp_params
    params.require(:calmapp).permit(:name,  {calmapp_versions_attributes: [:id, :version, :_destroy]})#, :developer_ids => []})
  end
  
  def set_calmapp
    @calmapp = Calmapp.find(params[:id])
  end
  private

end
