class CalmappVersionsController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  # GET /application_versions
  # GET /application_versions.xml
  before_action :authenticate_user!
  filter_access_to :all
  @@model="calmapp_version"
  
  def index
  
    @calmapp_versions = CalmappVersion.paginate(:page => params[:page], :per_page=>15)  #CalmappVersion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @calmapp_versions }
    end
  end

  # GET /calmapp_versions/1
  # GET /calmapp_versions/1.xml
  def show
    @calmapp_version = CalmappVersion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @calmapp_version }
    end
  end

  # GET /calmapp_versions/new
  # GET /calmapp_versions/new.xml
  def new
    @calmapp_version = CalmappVersion.new
    @calmapp_version.translation_languages << TranslationLanguage.where{iso_code == 'en'}.first#CalmappVersionsTranslationLanguage.new(:translation_language_id => TranslationLanguage.where{iso_code == 'en'}.first)
    #@calmapp_version.translation_languages_assigned = [] 
    #@calmapp_version.translation_languages_assigned << TranslationLanguage.where{iso_code == 'en'}.first#CalmappVersionsTranslationLanguage.new(:translation_language_id => TranslationLanguage.where{iso_code == 'en'}.first)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @calmapp_version }
    end
  end

  # GET /calmapp_versions/1/edit
  def edit
    @calmapp_version = CalmappVersion.find(params[:id])
  end

  # POST /calmapp_versions
  # POST /calmapp_versions.xml
  def create
    #binding.pry
=begin
    if not redis_db_update? then
      attr_hash = prepare_params_with_translation_language(params[:id], params[:calmapp_version][:calmapp_versions_translation_language_ids])
      params["calmapp_version"]["calmapp_versions_translation_languages_attributes"] = attr_hash
      params[:calmapp_version].delete(:calmapp_versions_translation_language_ids)
    end
=end
    prepare_params
    @calmapp_version = CalmappVersion.new(params[:calmapp_version])
    #binding.pry
    respond_to do |format|
      if @calmapp_version.save
        tflash('create', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( :action => "index")} #(@calmapp_version #, :notice => 'Application version was successfully created.') }
        format.xml  { render :xml => @calmapp_version, :status => :created, :location => @calmapp_version }
      else
        #binding.pry
        format.html { render :action => "new" }
        format.xml  { render :xml => @calmapp_version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /calmapp_versions/1
  # PUT /calmapp_versions/1.xml
  def update
    @calmapp_version = CalmappVersion.find(params[:id])
    
    prepare_params 
    #binding.pry
    respond_to do |format|
      begin
        
        #valid_new_associations = @calmapp_version.check_translation_languages_validity(params[:calmapp_version][:calmapp_versions_translation_language_ids])
        binding.pry
        #params[:calmapp_version][:calmapp_versions_translation_languages_attributes] = []
        
        if @calmapp_version.update_attributes(params[:calmapp_version])
          tflash('update', :success, {:model=>@@model, :count=>1})
          format.html { redirect_to( :action => "index")} #(@calmapp_version, :notice => 'Application version was successfully updated.') }
          format.xml  { head :ok }
        else
          if redis_db_update? then
            format.html { render :action => "version_alterwithredisdb" }
          else
            format.html { render :action => "edit" } 
          end
          
          format.xml  { render :xml => @calmapp_version.errors, :status => :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotSaved => e
         #tflash('update', :error,{:model=>@@model, :count=>1}  )
         #binding.pry
         #errors = []
         # @calmapp_version.calmapp_versions_translation_languages.each do |tl|
         #          errors << tl.errors.full_messages
         #end
         flash[:error] = e.to_s
         format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /calmapp_versions/1
  # DELETE /calmapp_versions/1.xml
  def destroy
    @calmapp_version = CalmappVersion.find(params[:id])
    @calmapp_version.destroy

    respond_to do |format|
      tflash('delete', :success, {:model=>@@model, :count=>1})
      format.html { redirect_to(calmapp_versions_url) }
      format.xml  { head :ok }
    end
  end
  
  def version_alterwithredisdb
    @calmapp_version = CalmappVersion.find(params[:id])
  end
  
  def publish_to_redis
    
  end
=begin
  prepare_params_with_translation_language(translation_language_ids)
 
  This method allows the use of the dual listbox for adding and subtracting languages from a version. 
  (We may have to stop removal as this would require the removal of all individual translations as well as publications)
  
  It seems easier to setup the params properly and let rails to the transaction. 
  Another alternative would be to do the database stuff here inside a transaction. Seems messy.
  
  @param calmapp_version_id usuallu obtained from params[:id]
  @param translation_language_ids normally obtained from the params.Ok to have empty strings
  @ return A hash that can be added to params. The format of the hash is like the tasks attribute in each of the projects below (for project has many tasks)
  project with 2nd task updated
"project"=>
  {"name"=>"mark proj",
   "description"=>" marks project",
   "tasks_attributes"=>
    {"0"=>
      {"description"=>"create erb", "done"=>"0", "_destroy"=>"", "id"=>"3"},
     "1"=>
      {"description"=>"test erb", "done"=>"1", "_destroy"=>"", "id"=>"4"}}}

with third task added
"project"=>
  {"name"=>"mark proj",
   "description"=>" marks project",
   "tasks_attributes"=>
    {"0"=>
      {"description"=>"create erb",
       "done"=>"0",
       "_destroy"=>"false",
       "id"=>"3"},
     "1"=>
      {"description"=>"test erb", "done"=>"1", "_destroy"=>"false", "id"=>"4"},
     "1387255366300"=>
      {"description"=>"run test", "done"=>"0", "_destroy"=>"false"}}}

delete third task

"project"=>
  {"name"=>"mark proj",
   "description"=>" marks project",
   "tasks_attributes"=>
    {"0"=>
      {"description"=>"create erb",
       "done"=>"0",
       "_destroy"=>"false",
       "id"=>"3"},
     "1"=>
      {"description"=>"test erb", "done"=>"1", "_destroy"=>"false", "id"=>"4"},
     "2"=>
      {"description"=>"run test", "done"=>"0", "_destroy"=>"1", "id"=>"8"}}}
=end  
  def prepare_params_with_translation_language calmapp_version_id, translation_language_ids 
    translation_language_ids.delete ""
    #translation_language_ids.uniq!
    en_id = TranslationLanguage.where{iso_code=='en'}.first.id
    if not translation_language_ids.include?(en_id.to_s) then
      translation_language_ids << en_id.to_s
    end
    attr_hash = {}
    if not calmapp_version_id.nil? then
      index = 0
      # Do deletes first
      
      languages_to_be_deleted = CalmappVersionsTranslationLanguage.find_languages_not_in_version(translation_language_ids ,calmapp_version_id).all
      #binding.pry
      if  not languages_to_be_deleted.count == 0 then
        languages_to_be_deleted.each do |l|
          attr_hash[index.to_s] = {"translation_language_id"=>l.translation_language_id, "calmapp_version_id"=>l.calmapp_version_id, "_destroy"=>"1", "id" =>l.id}
          index += 1  
        end
      end 
    end # calmapp_version not nil  
    # now the inserts and updates
    puts "in prepare_params_with_translation_language"
    index = 0
    #binding.pry
    translation_language_ids.each do |tlid|
      tl_id = tlid.to_i
      cvtl = CalmappVersionsTranslationLanguage.find_by_language_and_version(tl_id,calmapp_version_id )#.first
      
      if not cvtl.empty? then
        puts "cvtl " + cvtl.to_s
        attr_hash[index.to_s] =  {"translation_language_id"=>cvtl.first.translation_language_id, 
            "calmapp_version_id"=>calmapp_version_id, "_destroy"=>false, "id"=>cvtl.first.id}
        index += 1
      else
        puts "cvtl empty"
        attr_hash[rand(1299999999999..1399999999999).to_s] = {"translation_language_id"=>tl_id, "calmapp_version_id"=>calmapp_version_id,  "_destroy"=>false}
      end
      puts "end prepare_params_with_translation_language"
    end

    return attr_hash
   end
   private
     def redis_db_update? 
       #return params[:calmapp_version] if params[:calmapp_version] == nil
         return params[:calmapp_version][:calmapp_versions_translation_language_ids] == nil
     end
     
     def prepare_params
       #binding.pry
       return if not params[:calmapp_version]
   
       if not redis_db_update? then
        attr_hash = prepare_params_with_translation_language(params[:id], params[:calmapp_version][:calmapp_versions_translation_language_ids])
        params["calmapp_version"]["calmapp_versions_translation_languages_attributes"] = attr_hash
        params[:calmapp_version].delete(:calmapp_versions_translation_language_ids)
      end
     end
end
