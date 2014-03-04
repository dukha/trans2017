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
    @calmapp_versions_translation_language.update_attributes(params[:calmapp_versions_translation_language])
    respond_to do |format|
      if @calmapp_versions_translation_language.save
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( :action => "index")}#, notice: 'Calmapp versions translation language was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @calmapp_versions_translation_language.errors, status: :unprocessable_entity }
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
    
  def write_file_to_db
    @translations_upload = TranslationsUpload.find(params[:id])
    @calmapp_versions_translation_language = CalmappVersionsTranslationLanguage.find(@translations_upload.cavs_translation_language_id)
    if @translations_upload then
      #file = @translations_upload.yaml_upload2
      if @translations_upload.write_file_to_db then
        respond_to do |format|
          tflash("write_yaml_file", :success)
          format.html {render :action => 'edit'}
        end
      end
    else
      #error  
    end
  end  
  
  
  
  
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
