class DotKeyCodeTranslationEditorsController < ApplicationController
  # The line below only when fixed attr_accessible
   before_action :set_dot_key_code_translation_editor, only: [:show, :edit, :update, :destroy]
=begin
 from latest version 

  # GET /dot_key_code_translation_editors
  #def index
    #@dot_key_code_translation_editors = DotKeyCodeTranslationEditor.all
  #end
=end
  # Comment out the next 2 lines if not using authentication and authorisation
  before_filter :authenticate_user!
  filter_access_to :all

  @@model ="dot_key_code_translation_editor"

  # GET /dot_key_code_translation_editors
  # GET /dot_key_code_translation_editors.xml
  def index

    if DotKeyCodeTranslationEditor.respond_to? :searchable_attr  
      searchable_attr = DotKeyCodeTranslationEditor.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if DotKeyCodeTranslationEditor.respond_to? :sortable_attr  
      sortable_attr = DotKeyCodeTranslationEditor.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @dot_key_code_translation_editors = DotKeyCodeTranslationEditor.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class DotKeyCodeTranslationEditor < ActiveRecord::Base
      extend SearchModel
      # add attributes in the array. (This default is still ok, but no search in the index.)
      # This minimal method below is required for the index page to work
      def self.searchable_attr 
        return %w[]
      end
       # add attributes in the array. (This default is still ok, but no sorting in the index.)
        # This minimal method below is required for the index page to work
      def self.sortable_attr 
        return %w[]
      end  

    end  # end class DotKeyCodeTranslationEditor  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.empty?
  @dot_key_code_translation_editors = DotKeyCodeTranslationEditor.paginate(:page => params[:page], :per_page=>15)
else
  search_info =init_search(current_user, searchable_attr, sortable_attr)#init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@dot_key_code_translation_editors = DotKeyCodeTranslationEditor.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @dot_key_code_translation_editors = DotKeyCodeTranslationEditor.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
end


if @dot_key_code_translation_editors.count == 0 then
  tflash( "no_records_found", :warning)
end  
respond_to do |format|
  format.html # index.html.erb
  #format.json { render < %= key_value :json, "@#{plural_table_name}" %> }
  format.xml  { render :xml => @dot_key_code_translation_editors }
end
  end

  # GET /dot_key_code_translation_editors/1
  def show
  end

  # GET /dot_key_code_translation_editors/new
  def new
    @dot_key_code_translation_editor = DotKeyCodeTranslationEditor.new
  end

  # GET /dot_key_code_translation_editors/1/edit
  def edit
  end

  # POST /dot_key_code_translation_editors
  def create
    @dot_key_code_translation_editor = DotKeyCodeTranslationEditor.new(dot_key_code_translation_editors)

    if @dot_key_code_translation_editor.save
      tflash('create', :success, {:model=>@@model, :count=>1})  
      redirect_to @dot_key_code_translation_editor, notice: ' translation editor param was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /dot_key_code_translation_editors/1
  def update
    if @dot_key_code_translation_editor.update(dot_key_code_translation_editors)
       tflash('update', :success, {:model=>@@model, :count=>1})
      redirect_to @dot_key_code_translation_editor, notice: ' translation editor param was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /dot_key_code_translation_editors/1
  def destroy
    @dot_key_code_translation_editor.destroy
    
    respond_to{ |format|
      format.html {redirect_to dot_key_code_translation_editors_url, notice: ' translation editor param was successfully destroyed.'}
      format.js {}
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dot_key_code_translation_editor
      @dot_key_code_translation_editor = DotKeyCodeTranslationEditor.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dot_key_code_translation_editors
      params.require(:dot_key_code_translation_editor).permit(:dot_key_code, :param_name, :param_order, :param_default)
    end
end
