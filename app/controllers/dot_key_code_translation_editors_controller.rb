class DotKeycodeTranslationEditorsController < ApplicationController
  # The line below only when fixed attr_accessible
  # before_action :set_translation_editor, only: [:show, :edit, :update, :destroy]
=begin
 from latest version 

  # GET /translation_editors
  #def index
    #@translation_editors = TranslationEditor.all
  #end
=end
  # Comment out the next 2 lines if not using authentication and authorisation
  before_filter :authenticate_user!
  filter_access_to :all

  @@model ="translation_editor"

  # GET /translation_editors
  # GET /translation_editors.xml
  def index

    if TranslationEditor.respond_to? :searchable_attr  
      searchable_attr = TranslationEditor.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if TranslationEditor.respond_to? :sortable_attr  
      sortable_attr = TranslationEditor.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @translation_editors = TranslationEditor.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class TranslationEditor < ActiveRecord::Base
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

    end  # end class TranslationEditor  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.empty?
  @translation_editors = TranslationEditor.paginate(:page => params[:page], :per_page=>15)
else
  search_info = init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@translation_editors = TranslationEditor.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @translation_editors = TranslationEditor.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
end


if @translation_editors.count == 0 then
  tflash( "no_records_found", :warning)
end  
respond_to do |format|
  format.html # index.html.erb
  #format.json { render < %= key_value :json, "@#{plural_table_name}" %> }
  format.xml  { render :xml => @translation_editors }
end
  end

  # GET /translation_editors/1
  def show
  end

  # GET /translation_editors/new
  def new
    @translation_editor = TranslationEditor.new
  end

  # GET /translation_editors/1/edit
  def edit
  end

  # POST /translation_editors
  def create
    @translation_editor = TranslationEditor.new(translation_editors)

    if @translation_editor.save
      tflash('create', :success, {:model=>@@model, :count=>1})  
      redirect_to @translation_editor, notice: ' translation editor param was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /translation_editors/1
  def update
    if @translation_editor.update(translation_editors)
       tflash('update', :success, {:model=>@@model, :count=>1})
      redirect_to @translation_editor, notice: ' translation editor param was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /translation_editors/1
  def destroy
    @translation_editor.destroy
    
    redirect_to translation_editors_url, notice: ' translation editor param was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_translation_editor
      @translation_editor = TranslationEditor.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def translation_editors
      params.require(:translation_editor).permit(:dot_key_code, :param_name, :param_order, :param_default)
    end
end
