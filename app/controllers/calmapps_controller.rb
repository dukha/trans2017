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

    respond_to do |format|
      if @calmapp.save( )
        format.html { redirect_to calmapps_path, notice: 'Calmapp was successfully created.' }
        format.json { render action: 'show', status: :created, location: @calmapp }
      else
    
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
  
      if @calmapp.update(calmapp_params) #params[:calmapp], without_protection: true)
        
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(calmapps_path) }
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
      tflash('delete', :success, {:model=>@@model, :count=>1})
      respond_to do |format|
        tflash('delete', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(calmapps_path) }
        format.js {}
      end 
    rescue StandardError => e
      @calmapp = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end


  def calmapp_params
    params.require(:calmapp).permit(:name,  {calmapp_versions_attributes: [:id, :version, :_destroy]})#, :developer_ids => []})
  end
  
  def set_calmapp
    @calmapp = Calmapp.find(params[:id])
  end
  private

end
