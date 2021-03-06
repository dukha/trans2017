class ReleaseStatusesController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  # GET /release_statuses
  # GET /release_statuses.xml
  before_action :authenticate_user!
  before_action :set_release_status, only: [ :edit, :update, :destroy, :show]
  filter_access_to :all
  @@model = "release_status"
  
  def index
    @release_statuses = ReleaseStatus.paginate(:page => params[:page], :per_page=>15)  #ReleaseStatus.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @release_statuses }
    end
  end

  # GET /release_statuses/1
  # GET /release_statuses/1.xml
  def show
    #@vrelease_status = ReleaseStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @release_status }
    end
  end

  # GET /release_statuses/new
  # GET /release_statuses/new.xml
  def new
    @release_status = ReleaseStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @release_status }
    end
  end

  # GET /release_statuses/1/edit
  def edit
    #@release_status = ReleaseStatus.find(params[:id])
  end

  # POST /release_statuses
  # POST /release_statuses.xml
  def create
    @release_status = ReleaseStatus.new(release_status_params)

    respond_to do |format|
      if @release_status.save
        tflash('create', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( release_statuses_path)} #(@release_status #, :notice => 'version status was successfully created.') }
        format.xml  { render :xml => @release_status, :status => :created, :location => @release_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @release_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /release_statuses/1
  # PUT /release_statuses/1.xml
  def update
    respond_to do |format|
      if @release_status.update_attributes(release_status_params)
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( release_statuses_path)} #(@release_status, :notice => 'version status was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @release_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /release_statuses/1
  # DELETE /release_statuses/1.xml
  def destroy
    begin
    @release_status.destroy
    tflash('delete', :success, {:model=>@@model})
    respond_to do |format|
      format.html { redirect_to(release_statuses_path) }
      format.js {}
    end
    rescue StandardError => e
      @release_status = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end
  
   private
    # Use callbacks to share common setup or constraints between actions.
    def set_release_status
      @release_status = ReleaseStatus.find(params[:id])
    end

    def release_status_params
        params.require(:release_status).permit(:status)
    end
    
end
