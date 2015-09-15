class RedisInstancesController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  # GET /translations
  # GET /translations.xml
  before_action :authenticate_user!
  before_action :set_redis_instance, only: [ :edit, :update, :destroy, :show]
  filter_access_to :all
  @@model="redis_instance"
  def index
    @redis_instances = RedisInstance.paginate(:page => params[:page], :per_page=>15)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @redis_instances }
    end
  end

  # GET /redis_instances/1
  # GET /redis_instances/1.xml
  def show
    #@redis_instance = RedisInstance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @redis_instance }
    end
  end

  # GET /redis_instances/new
  # GET /redis_instances/new.xml
  def new
    @redis_instance = RedisInstance.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @redis_instance }
    end
  end

  # GET /redis_instances/1/edit
  def edit
    
  end

  # POST /redis_instances
  # POST /redis_instances.xml
  def create
    @redis_instance = RedisInstance.new(redis_instance_params)


    respond_to do |format|
      #if @redis_instance.create_redis_db
        #debugger
        if @redis_instance.save
          tflash('create', :success, {:model=>@@model, :count=>1})
          format.html { redirect_to(redis_instances_path) }
          format.xml  { render :xml => @redis_instance, :status => :created, :location => @redis_instance }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @redis_instance.errors, :status => :unprocessable_entity }
        end
      #else

      #end
    end
  end

  # PUT /redis_instances/1
  # PUT /redis_instances/1.xml
  def update
    respond_to do |format|
      if @redis_instance.update(redis_instance_params)
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(:action=>:index) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @redis_instance.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /redis_instances/1
  # DELETE /redis_instances/1.xml
  def destroy
    begin
    
      @redis_instance.destroy
      tflash('delete', :success, {:model=>@@model, :count=>1})
      respond_to do |format|
        #binding.pry
        format.html { redirect_to(redis_instances_path) }
        format.js {}
      end
    rescue StandardError => e
  
      @redis_instance = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end  
  end

  def unused_redis_database_indexes
    #puts  "unused_redis_database_indexes"

    ri = RedisInstance.find(params[:redis_instance_id])
    data = ri.unused_redis_database_indexes()
    if request.xhr?
      render :json => data
    else
      return data
    end 
  end 
  
  def next_redis_database_index

    begin
      last_index = params[:last_index].to_i unless params[:last_index].nil?
      last_index ||= -1 
      ri = RedisInstance.find(params[:redis_instance_id])
      ret_val = ri.next_index last_index
      if request.xhr?
          render :json => ret_val#["error"]? ret_val["error"] : ret_val
      else
        return ret_val
      end #xhr 
    rescue Exceptions::NoRedisDatabasesLeft => e
    
        render :json => {:error => e.message}, :status=>403
    end 
  end #def
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_redis_instance
      @redis_instance = RedisInstance.find(params[:id])
    end

    
    def redis_instance_params
      params.require(:redis_instance).permit(:host, :port, :password, :max_databases, :description)
    end
end #class
