class TranslationsController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_translation, only: [ :edit, :update, :destroy, :show]
  filter_access_to :all
  # RecordInvalid is thrown when a constaint is violated (e.g. uniqueness)
  rescue_from ActiveRecord::RecordInvalid, :with => :record_invalid
  #RecordNotUnique is thrown when the database unique constraint is violated. 
  #It is derived from the more general ActiveRecord::RecordInvalid
  rescue_from ActiveRecord::RecordNotUnique, :with => :record_not_unique
  #rescue_from ActiveRecord::RecordInvalid, :with => :record_not_unique
  @@model='translation'
  
  def new
  end
   def dev_new
    @translation = Translation.new
    
    @developer_param = DeveloperParam.new
    respond_to do |format|
      format.html
    end
  end
  def update
    #binding.pry
      if params[:editor] == Translation::TRANS_PLURAL
        my_params = {:translation=> params[:translation_plural]}
      else
        my_params = translation_params
      end
      begin
        result = @translation.update(my_params)
      rescue StandardError =>sd
        
        @translation.errors.add(sd.message)
      end  
       #c
       #binding.pry
      if result
       #binding.pry
        puts "successful update"
        flash.now[:success] = "Successful Update now"
        flash[:notice] = "Successful Update wait" 
        #respond_to do |format|
=begin        
          format.html { 
            redirect_to(@translation, :notice => 'Translation was successfully updated.') 
          }
          format.json { 
            if params["editor"].nil? then
              #binding.pry
             respond_with_bip(@translation) 
            else
              #binding.pry
              #render
              render :json => {:result => "ok"}
            end
           }
=end           
           #format.js
         #end # do  
      else
        #binding.pry
        if not @translation.errors.empty?
          flash.now[:error] = @translation.errors.message 
        else 
          flash.now[:error] = "An error has occurred wihich prevented this translation from going further"  
        end
        puts "unsuccessful update"
        #respond_to do |format|
          #format.html { render :action => "edit" }
          #format.json { respond_with_bip(@translation) }
          #format.js
        #end # do
      end #if update else
      #binding.pry
      respond_to do |format|
        format.json { 
            if params["editor"].nil? then
              #binding.pry
             respond_with_bip(@translation) 
            else
              puts "Data error: params['editor'] is nil" 
            end
            }  
        format.js {}
      end #respond
      #render :js => ActiveSupport::JSON.encode("update.js")
  end #def update

  def index
    @translations = []
    # We do all our primary IO via activerecord/postgres and only publish to redis....
   
    # to work with best_in_place to edit in the index html table we need to work with eager loading 
    # so that we can reference @translations as an array @translations[1] etc in the erb page
    # Thus use to use will_paginate we eagerly load, giving an array by using .all 
    # The array will still paginate provided we have will_paginate/array
    # messy but it works!! 
    require 'will_paginate/array'
    possible_where_clauses = prepare_mode()
    search_info = prepare_search()
    #binding.pry
    if Translation.valid_criteria?(search_info) then
      
      @translations = Translation.search(current_user, search_info, nil, possible_where_clauses)
      @translations = @translations.each do |t|
        #This will prevent strings appearing in quotes in the user interface
        
        if JSON.is_json?(t.translation) then
          #if t.translation.start_with? '{', '['
           # binding.pry
            #decoded = t.translation
         # else
            decoded = ActiveSupport::JSON.decode(t.translation) #unless t.translation.start_with? '{', '['
          #end 
        elsif t.translation.nil?
          decoded = "" 
        else
          #binding.pry
          msg =  t.translation + " IS NOT JSON: bad data. Translation id = " + t.to_s
          puts msg
          Rails.logger.error( msg)
          decoded = t.translation
        end  
        if not (decoded.is_a? Array or decoded.is_a? Hash) then
          t.translation = decoded
        end
=begin         this didn't work for attribute 'en_translation'
        decoded = ActiveSupport::JSON.decode(t.attributes["en_translation"])
        if not (decoded.is_a? Array or decoded.is_a? Hash) then
          t.attributes["en_translation"] = decoded
        end
      binding.pry
=end
      end
    else  
      msg = 'Criteria: '
      flash_now= false
      search_info[:messages].each do |m|
        m.keys.each{ |k,v| 
          #binding.pry
          flash_now = true
          msg.concat( "#{m[k] + '. '}") 
        }
      end
      flash.now[:error] = msg if flash_now
      # in this case we make an ActivRecord Relation with 0 records so that we can redisplay
      @translations =  Translation.where{id == -1}
    end
    #binding.pry
    if @translations.count == 0 then
      flash[:warning] = "No translations found for the criteria give. Check your criteria."
    end
    @translations =@translations.paginate(:page => params[:page], :per_page => 30)
    # pass data directly to js
    #gon.criteriaHiddenText = t($FA +'show_something', :something=>t($SC))
    #gon.criteriaVisibleText = t($FA +'hide_something', :something=>t($SC))
    #gon.translation_count = @translations.size
    respond_to do |format|
      
      format.html # index.html.erb
      format.js  {}
    end
  end
=begin
  
  contains a table that is editable 
  #deprecated use index
=end  
  def editable_list   
     @translations = Translation.paginate(:page => params[:page], :per_page=>25) 
    #puts "@translations: " + @translations.first.dot_key_code
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @translations }
    end
  end
  
  def edit
  end

# Will be needed for developers
  def create
    
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @translation }
    end
  end
# needed for developers
  def destroy
    
    if @translation.calmapp_versions_translation_language.translation_language.iso_code == 'en' then 
      binding.pry
      begin
        @translation.destroy
        tflash('delete', :success, {:model=>@@model, :count=>1})
        respond_to do |format|
          
          format.html { redirect_to(translation_languages_path) }
          format.js {}
        end
      rescue StandardError => e
        puts e.backtrace.join("\n")
        @translation = nil
        flash[:error] = e.message
        respond_to do |format|
          format.js
        end
      end #rescue  
    end #if
  end
  
  def prepare_mode
    mode = params["selection_mode"]
    extra_where_clauses = []
    en_newer_where = "english.updated_at > translations.updated_at"
    untranslated_where = "translations.translation is null"
    if mode == "untranslated" then
      extra_where_clauses << untranslated_where
    elsif mode == "en_newer" then
      extra_where_clauses << en_newer_where
    elsif mode == 'both_untranslated_and_en_newer'  then
      extra_where_clauses << en_newer_where
      extra_where_clauses << untranslated_where
    else # all
      # do nothing    
    end
    return extra_where_clauses
  end
  
  
  def prepare_search
    if Translation.respond_to? :searchable_attr  
      searchable_attr = Translation.searchable_attr 
    else 
      searchable_attr = [] 
    end # respond_to

    if Translation.respond_to? :sortable_attr  
      sortable_attr = Translation.sortable_attr     
    else   
      sortable_attr = []   
    end
     return search_info = init_search(current_user, searchable_attr, sortable_attr)
    
  end
=begin  
  def search
    #binding.pry
    # We need to make a preliminary ar relation so that we can do the join. The selects are important so that we can get the region (for translation) 
    #activerecord_relation = Translation.all #, @language)
    #
    
    if Translation.respond_to? :searchable_attr  
      searchable_attr = Translation.searchable_attr 
    else 
      searchable_attr = Translation.sortable_attr 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    
    # Uses params to prepare the criteria and operators for the search  
    search_info = init_search(current_user, searchable_attr, sortable_attr)
    binding.pry
    activerecord_relation = Translation.single_lang_translations(search_info[:criteria].delete("iso_code"), search_info[:criteria].delete("cav_id"))
    search_info[:operators].delete("iso_code")
    search_info[:operators].delete("cav_id")
     #binding.pry
    # Does the search
    @translations = Translation.search(current_user, search_info, activerecord_relation)
    #binding.pry
  end
=end
  protected
    # This method called when the DB uniqueness constraint is violated
    def record_not_unique exception
      flash.now[:error] = exception.message
      tflash("all_rolledback", :warning, {:model=>@@model, :count=>10}, true )
      #flash.now[:warning] = t($MS + "all_rolledback")
      reload_dev_new_after_rollback()
      render "dev_new"
    end
    
    # This method called when the rails uniqueness validation is violated
    def record_invalid exception
      flash.now[:error] =exception.message
      tflash("all_rolledback", :warning, {:model=>@@model, :count=>10}, true )
      reload_dev_new_after_rollback()
      render "dev_new"
    end
    def reload_dev_new
      @developer_param = DeveloperParam.new
      @developer_param.model=params[:developer_param][:model]
      @translation= Translation.new
    end
    def reload_dev_new_after_rollback
      reload_dev_new()
      @translation.dot_key_code0=params[:translation][:dot_key_code0]
      @translation.dot_key_code1=params[:translation][:dot_key_code1]
      @translation.dot_key_code2=params[:translation][:dot_key_code2]
      
      @translation.translation0=params[:translation][:translation0]
      @translation.translation1=params[:translation][:translation1]
      @translation.translation2=params[:translation][:translation2]
      
      
      @developer_param.attribute=params[:developer_param][:attribute]
      @developer_param.key_helper=params[:developer_param][:key_helper]
      @rollbacked = true
    end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_translation
      @translation = Translation.find(params[:id])
    end

    
    # modify for developers
    def translation_params
        params.require(:translation).permit(:translation) 
    end  
   
end
