class TranslationLanguagesController < ApplicationController
  require 'translations_helper'
  include TranslationsHelper
  # GET /translation_languages
  # GET /translation_languages.xml
  before_action :authenticate_user!#, :except=> :change_application_language
  before_filter :set_translation_language, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all
  @@model ="translation_language"
  
  def index
    @translation_languages = TranslationLanguage.paginate(:page => params[:page], :per_page=>15)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @translation_languages }
    end
  end

  # GET /translation_languages/1
  # GET /translation_languages/1.xml
  def show
    #@translation_language = TranslationLanguage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @translation_language }
    end
  end

  # GET /translation_languages/new
  # GET /translation_languages/new.xml
  def new
    @translation_language = TranslationLanguage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @translation_language }
    end
  end

  # GET /translation_languages/1/edit
  def edit
    #@translation_language = TranslationLanguage.find(params[:id])
  end

  # POST /translation_languages
  # POST /translation_languages.xml
  def create
    @translation_language = TranslationLanguage.new(translation_language_params)

    respond_to do |format|
      if @translation_language.save
        tflash('create', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(translation_languages_path)} # , :notice => t('messages.create.success', :model=>@@model)) }
        format.xml  { render :xml => @translation_language, :status => :created, :location => @translation_language }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @translation_language.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /translation_languages/1
  # PUT /translation_languages/1.xml
  def update
    respond_to do |format|
      if @translation_language.update(translation_language_params)
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(translation_languages_path)} #, :notice => t('messages.update.success', :model=>@@model)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @translation_language.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /translation_languages/1
  # DELETE /translation_languages/1.xml
  def destroy
    begin
      @translation_language.destroy
       tflash('delete', :success, {:model=>@@model, :count=>1})
      respond_to do |format|
        format.html { redirect_to(translation_languages_path) }
        format.js {}
      end
    rescue StandardError => e
      @translation_language = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end


=begin
  def upload_yaml_translation_file
  end
=end  
  private
  def set_translation_language
    @translation_language = TranslationLanguage.find(params[:id])
  end
  
  def translation_language_params
    params.require(:translation_language).permit(:iso_code, :name, :plural_sort )
  end
  
end
