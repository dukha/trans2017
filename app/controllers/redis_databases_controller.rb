class RedisDatabasesController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  # GET /translations
  # GET /translations.xml
  before_action :authenticate_user!
  before_action :set_redis_database, only: [ :edit, :update, :destroy, :show]
  filter_access_to :all
  
  @@model ="redis_database"
  def index
    if RedisDatabase.respond_to? :searchable_attr  
      searchable_attr = RedisDatabase.searchable_attr 
    else 
      searchable_attr = [] 
    end
    #criteria=criterion_list(searchable_attr)
    #operators=operator_list( searchable_attr, criteria)

    if RedisDatabase.respond_to? :sortable_attr  
      sortable_attr = RedisDatabase.sortable_attr     
    else   
      sortable_attr = []   
    end
    #sorting=sort_list(sortable_attr)
    
    #@redis_databases = RedisDatabase.paginate(:page => params[:page], :per_page=>15)
    if searchable_attr.empty?
      @redis_databases = RedisDatabase.paginate(:page => params[:page], :per_page=>15)
    else
      crit_list = criterion_list(searchable_attr)
      search_info = init_search(current_user, searchable_attr, sortable_attr)
      @redis_databases = RedisDatabase.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
    end
    if @redis_databases.count == 0 then
      tflash( "no_records_found", :warning)
    end  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @redis_databases }
    end
  end

  # GET /redis_databases/1
  # GET /redis_databases/1.xml
  def show
    #@redis_database = RedisDatabase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.yml { render :yml => @redis_database.redis_to_yaml }
      #format.xml  { render :xml => @redis_database }
    end
  end

  # GET /redis_databases/new
  # GET /redis_databases/new.xml
  def new
    @redis_database = RedisDatabase.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @redis_database }
    end
  end

  # GET /redis_databases/1/edit
  def edit
    #@redis_database = RedisDatabase.find(params[:id])
  end

  # POST /redis_databases
  # POST /redis_databases.xml
  def create
    @redis_database = RedisDatabase.new(params[:redis_database])
    #binding.pry
    respond_to do |format|
      #binding.pry
      #if @redis_database.create_redis_db
        if @redis_database.save then
          tflash('create', :success, {:model=>@@model, :count=>1})
          format.html { redirect_to(:action=>:index) }
          format.xml  { render :xml => @redis_database, :status => :created, :location => @redis_database }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @redis_database.errors, :status => :unprocessable_entity }
        end
      #else

      #end
    end
  end

  # PUT /redis_databases/1
  # PUT /redis_databases/1.xml
  def update
    #@redis_database = RedisDatabase.find(params[:id])

    respond_to do |format|
      if @redis_database.update_attributes(params[:redis_database])
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(:action=>:index) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @redis_database.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /redis_databases/1
  # DELETE /redis_databases/1.xml
  def destroy
    #@redis_database = RedisDatabase.find(params[:id])
    @redis_database.destroy
    tflash('delete', :success, {:model=>@@model, :count=>1})
    respond_to do |format|
      format.html { redirect_to(redis_databases_url) }
      format.js {}
    end
  end

  def redis_to_yaml_get_file
     @redis_database= RedisDatabase.find(params[:id])
     render "select_yaml_file"
  end
  def redis_to_yaml
    @redis_database= RedisDatabase.find(params[:id])
    @file = File.new params[:file]
    @redis_database.redis_to_yaml @file
  end
  
=begin
 This method publishes the whole application version to the chosen redis database  
=end
  def publish
    begin
      redis_db = RedisDatabase.find(params[:id])
      count = redis_db.publish_version 
      if request.xhr? then
        payload = {"result" => count, "status" =>200}
        flash[:notice] = "Published to #{redis_db.description} : Total Translations Published = #{count}"
        respond_to do |format|
          format.js
        end
      end
    rescue StandardError => e
      payload = {"result" => (e.message + " on #{redis_db.description}."), "status" => 400}
      flash[:error] = payload["result"] + " Try again later or contact yor system administrator."
      Rails.logger.error(e.message)
      respond_to do |format|
          format.js
      end 
    end  
  end  
  
private
    # Use callbacks to share common setup or constraints between actions.
    def set_redis_database
      @redis_database = RedisDatabase.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def redis_database_params
      params.require(:redis_database).permit(:redis_instance_id, :redis_db_index)
    end
end
