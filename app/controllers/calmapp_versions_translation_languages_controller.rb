class CalmappVersionsTranslationLanguagesController < ApplicationController
  before_action :set_calmapp_versions_translation_language, only: [:show, :edit, :update, :destroy]
  require 'translations_helper'
  include TranslationsHelper
  require 'will_paginate/array'
  
  @@model = "calmapp_versions_translation_language"
 # before_action :set_calmapp_versions_translation_language, only: [:show, :edit, :update, :destroy]

  # GET /calmapp_versions_translation_languages
  # GET /calmapp_versions_translation_languages.json
  def index
    #binding.pry
    @calmapp_versions_translation_languages = CalmappVersionsTranslationLanguage.paginate(:page => params[:page], :per_page=>15)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @calmapp_versions_translation_languages }
    end
  end

  # GET /calmapp_versions_translation_languages/1
  # GET /calmapp_versions_translation_languages/1.json
  def show
  end

  # GET /calmapp_versions_translation_languages/new
  def new
    @calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.new
  end

  # GET /calmapp_versions_translation_languages/1/edit
  def edit
  end

  # POST /calmapp_versions_translation_languages
  # POST /calmapp_versions_translation_languages.json
  def create
    @calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.new(params[:calmapp_versions_translation_language])

    respond_to do |format|
      if @calmapp_versions_translation_language.save
        tflash('create', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( :action => "index", notice: 'Calmapp versions translation language was successfully created.') }
        format.json { render action: 'show', status: :created, location: @calmapp_versions_translation_language }
      else
        format.html { render action: 'new' }
        format.json { render json: @calmapp_versions_translation_language.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /calmapp_versions_translation_languages/1
  # PATCH/PUT /calmapp_versions_translation_languages/1.json
  def update
    #binding.pry
    @calmapp_versions_translation_language = CalamppVersionTranslationLanguage.find(params[:id])
    @calmapp_versions_translation_language.assign_attributes(params[:calmapp_versions_translation_language])
    
    respond_to do |format|
      begin
      if @calmapp_versions_translation_language.save
        #binding.pry
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( :action => "index")}#, notice: 'Calmapp versions translation language was successfully updated.') }
        format.json { head :no_content }
      else
        #binding.pry
        format.html { render action: 'edit' }
        format.json { render json: @calmapp_versions_translation_language.errors, status: :unprocessable_entity }
      end # save
      rescue PsychSyntaxErrorWrapper => psew
        flash[:error]= "Format of file : " + psew.file_name + " is bad. Copy the following error message and contact tech support with the file. Error message : " + psew.message
        #flash[:notice] = "Failed to write file : " + pse.file_name + ". The syntax in the file was wrong. Ask for technical help. No upload done."
        format.html { redirect_to action: 'edit' }
      rescue UploadTranslationError => ute
        #binding.pry
        flash[:error]= ute.message
        flash[:notice] = "Failed to write file : " + ute.file_name + ". No upload done."
        format.html { redirect_to action: 'edit' } 
      #rescue StandardError => e
        #binding.pry
        #flash[:error]= e.message 
        #flash[:notice] = "Failed to write file : " + e.file_name + ". No upload done."
        #format.html { redirect_to action: 'edit' } 
      end  
    end
  end

  # DELETE /calmapp_versions_translation_languages/1
  # DELETE /calmapp_versions_translation_languages/1.json
  def destroy
    @calmapp_versions_translation_language.destroy
    respond_to do |format|
      format.html { redirect_to calmapp_versions_translation_languages_url }
      format.json { head :no_content }
    end  
  end
=begin    
  def write_file_to_db
    #binding.pry
    @translations_upload = TranslationsUpload.find(params[:id])
    @calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.find(@translations_upload.cavs_translation_language_id)
    if @translations_upload then
      #file = @translations_upload.yaml_upload2
     # binding.pry
      if @translations_upload.write_file_to_db2(Translation.Overwrite[:all]) then
        respond_to do |format|
          #binding.pry
          tflash("write_yaml_file", :success, :file=>@translations_upload.yaml_upload_identifier)
          format.html {render :action => 'edit'}
        end
      else
        cause = ''
        binding.pry
        @calmapp_versions_translation_language.errors.each{|m| cause = cause + m + "; " }
         
        respond_to do |format|
          tflash("write_yaml_file", :error, :cause=> cause) 
          format.html {render :action => 'edit'}
        end
      end
    else
      #error  
    end
  end  
=end  
  
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calmapp_versions_translation_language
      @calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calmapp_versions_translation_language_params
      params.require(:calmapp_versions_translation_language).permit(:translation_language_id, :calmapp_version_id)
    end
end
