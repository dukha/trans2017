class WhiteboardTypesController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  # GET /whiteboard_types
  # GET /whiteboard_types.xml
  before_action :authenticate_user!
  before_filter :set_whiteboard_type, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all
  
  @@model ="whiteboard_type"
  
  def index
    @whiteboard_types = WhiteboardType.paginate(:page => params[:page], :per_page=>15)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @whiteboard_types }
    end
  end

  # GET /whiteboard_types/1
  # GET /whiteboard_types/1.xml
  def show
    #@whiteboard_type = WhiteboardType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @whiteboard_type }
    end
  end

  # GET /whiteboard_types/new
  # GET /whiteboard_types/new.xml
  def new
    @whiteboard_type = WhiteboardType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @whiteboard_type }
    end
  end

  # GET /whiteboard_types/1/edit
  def edit
    #@whiteboard_type = WhiteboardType.find(params[:id])
  end

  # POST /whiteboard_types
  # POST /whiteboard_types.xml
  def create
    @whiteboard_type = WhiteboardType.new(whiteboard_type_params)#params[:whiteboard_type])
    @whiteboard_type.save
    flash[:notice] = "successfully created " + @whiteboard_type.name_english
    redirect_to(whiteboard_types_path)
  end

  # PUT /whiteboard_types/1
  # PUT /whiteboard_types/1.xml
  def update
    respond_to do |format|
      if @whiteboard_type.update(whiteboard_type_params)#params[:whiteboard_type])
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(whiteboard_types_path)} #, :notice => t('messages.update.success', :model=>@@model)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @whiteboard_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /whiteboard_types/1
  # DELETE /whiteboard_types/1.xml
  def destroy
    begin
    @whiteboard_type.destroy
    tflash('delete', :success, {:model=>@@model, :count=>1})
    respond_to do |format|
      format.html { redirect_to(whiteboard_types_path) }
      format.xml  { head :ok }
      format.js {}
    end
    rescue StandardError => e
      @whiteboard_type = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end
  
private
  def set_whiteboard_type
    @whiteboard_type = WhiteboardType.find(params[:id])
  end
  
  def whiteboard_type_params
    params.require(:whiteboard_type).permit(:name_english, :translation_code)
  end
end
