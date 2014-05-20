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
  # GET /calmapp_versions/new.xmlcalmapp_version_tl.
  def new
    @calmapp_version = CalmappVersion.new
    #@calmapp_version.translation_languages << TranslationLanguage.where{iso_code == 'en'}.first#CalmappVersionsTranslationLanguage.new(:translation_language_id => TranslationLanguage.where{iso_code == 'en'}.first)
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
    #new_calmapp_versions_translations_languages = new_languages()
    #We are going to create just the basic version with none of the assoications
    # We then use a delayed update to add all the associations
    @calmapp_version = CalmappVersion.new({:version=>params[:calmapp_version][:version], :calmapp_id=>params[:calmapp_version][:calmapp_id] })
    #binding.pry
    respond_to do |format|
      if @calmapp_version.save
        #binding.pry
        if @calmapp_version.delay.update_attributes(params[:calmapp_version])
          #binding.pry
          ApplicationController.start_delayed_jobs_queue()
        #if @calmapp_version.delay.save
      #if @calmapp_version.valid? then
        #if version_create_detached then
          tflash('valid_version_on_queue', :success, {:model=>@@model, :count=>1})
          format.html { redirect_to( :action => "index")} #(@calmapp_version #, :notice => 'Application version was successfully created.') }
          format.xml  { render :xml => @calmapp_version, :status => :created, :location => @calmapp_version }
        #end 
      else
        #binding.pry
        format.html { render :action => "new" }
        format.xml  { render :xml => @calmapp_version.errors, :status => :unprocessable_entity }
      end # save
     else
       format.html { render :action => "new" }
        format.xml  { render :xml => @calmapp_version.errors, :status => :unprocessable_entity }
     end #save 2   
    end #do
  end

  # PUT /calmapp_versions/1
  # PUT /calmapp_versions/1.xml
  def update
    #binding.pry
    @calmapp_version = CalmappVersion.find(params[:id])
    #binding.pry
    prepare_params
    #new_calmapp_versions_translations_languages = new_languages() 
    #binding.pry
    respond_to do |format|
      #begin
        #binding.pry
        if @calmapp_version.delay.update_attributes(params[:calmapp_version])
          system "RAILS_ENV=#{Rails.env} bin/delayed_job start --exit-on-complete"
          tflash('update', :success, {:model=>@@model, :count=>1})
          
          flash[:warning] = @calmapp_version.warnings.messages[:base] if @calmapp_version.warnings 
          
          format.html { redirect_to( :action => "index")} #(@calmapp_version, :notice => 'Application version was successfully updated.') }
          format.xml  { head :ok }
        else
          #binding.pry
          # @todo get the errors from the after_save parts of the transaction and put them up
          flash[:error] = "Record not saved."
          if redis_db_update? then
            format.html { render :action => "version_alterwithredisdb" }
          else
            format.html { render :action => "edit" } 
          end
          
          format.xml  { render :xml => @calmapp_version.errors, :status => :unprocessable_entity }
        end
      #rescue Exception => e #ActiveRecord::RecordNotSaved => e
         # @todo This branch doesn't actually execute. Needs removing
         
         #tflash('update', :error,{:model=>@@model, :count=>1}  )
         #binding.pry
         #errors = []
         # @calmapp_version.calmapp_versions_translation_languages.each do |tl|
         #          errors << tl.errors.full_messages
         #end
         #binding.pry
         #flash[:error] = e.to_s
         #format.html { render :action => "edit" }
      #end
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
=begin
 We are not going to use it. Too hard to call rake from within giving it params as json
 We'll fudge and use delayed_job instead 
 @deprecated until next version
=end  
  def version_create_detached
    #@calmapp_version = CalmappVersion.new(params[:calmapp_version])
    #params_json = JSON.generate(params)
    return call_rake("version:create")
  end
  
  
  def version_alterwithredisdb
    @calmapp_version = CalmappVersion.find(params[:id])
  end
  
  def publish_to_redis
    
  end

   private
     def redis_db_update? 
       #binding.pry
       return params[:calmapp_version][:calmapp_versions_translation_language_ids] == nil
     end
     
     def prepare_params
       #binding.pry
       return if not params[:calmapp_version]
   
       if not redis_db_update? then
         # This puts the params in the correct format for accepts_nested_attributes_for() 
         attr_hash = prepare_params_with_translation_language(params[:id], params[:calmapp_version][:calmapp_versions_translation_language_ids])
         params["calmapp_version"]["calmapp_versions_translation_languages_attributes"] = attr_hash
         # Now remove the param that is not part of the update: it only brought in the 2 languages
         # It will bomb if this delete is not done.
         params[:calmapp_version].delete(:calmapp_versions_translation_language_ids)
         params[:calmapp_version].delete(:translation_languages_available)
      end
     end
     
     def prepare_params_with_translation_language calmapp_version_id, translation_language_ids 
      #binding.pry
      translation_language_ids.delete ""
      #translation_language_ids.uniq!
      #binding.pry
      #These lines should be in the model
      en_id = TranslationLanguage.where{iso_code=='en'}.first.id
=begin
      if not translation_language_ids.include?(en_id.to_s) then
        translation_language_ids << en_id.to_s
      end
=end
      attr_hash = {}
      if not calmapp_version_id.nil? then
        # a new version
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
      #index = 0
      #binding.pry
      translation_language_ids.each do |tlid|
        tl_id = tlid.to_i
        cvtl = CalmappVersionsTranslationLanguage.find_by_language_and_version(tl_id,calmapp_version_id )#.first
        
        if not cvtl.empty? then
          #puts "cvtl " + cvtl.to_s
          attr_hash[index.to_s] =  {"translation_language_id"=>cvtl.first.translation_language_id, 
              "calmapp_version_id"=>calmapp_version_id, "_destroy"=>false, "id"=>cvtl.first.id}
          index += 1
        else
          puts "cvtl empty"
          attr_hash[rand(1299999999999..1399999999999).to_s] = {"translation_language_id"=>tl_id, "calmapp_version_id"=>calmapp_version_id,  "_destroy"=>false}
        end # empty
        puts "end prepare_params_with_translation_language"
      end #each
      #binding.pry
    return attr_hash
   end

end
