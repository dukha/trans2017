class TranslationEditorParamsController < ApplicationController
  # The line below only when fixed attr_accessible
  # before_action :set_translation_editor_param, only: [:show, :edit, :update, :destroy]
=begin
 from latest version 

  # GET /translation_editor_params
  #def index
    #@translation_editor_params = TranslationEditorParam.all
  #end
=end
  # Comment out the next 2 lines if not using authentication and authorisation
  before_filter :authenticate_user!
  #filter_access_to :all

  @@model ="translation_editor_param"

  # GET /translation_editor_params
  # GET /translation_editor_params.xml
  def index

    if TranslationEditorParam.respond_to? :searchable_attr  
      searchable_attr = TranslationEditorParam.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if TranslationEditorParam.respond_to? :sortable_attr  
      sortable_attr = TranslationEditorParam.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @translation_editor_params = TranslationEditorParam.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class TranslationEditorParam < ActiveRecord::Base
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

    end  # end class TranslationEditorParam  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.empty?
  @translation_editor_params = TranslationEditorParam.paginate(:page => params[:page], :per_page=>15)
else
  search_info = init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@translation_editor_params = TranslationEditorParam.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @translation_editor_params = TranslationEditorParam.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
end


if @translation_editor_params.count == 0 then
  tflash( "no_records_found", :warning)
end  
respond_to do |format|
  format.html # index.html.erb
  #format.json { render < %= key_value :json, "@#{plural_table_name}" %> }
  format.xml  { render :xml => @translation_editor_params }
end
  end

  # GET /translation_editor_params/1
  def show
  end

  # GET /translation_editor_params/new
  def new
    @translation_editor_param = TranslationEditorParam.new
  end

  # GET /translation_editor_params/1/edit
  def edit
  end

  # POST /translation_editor_params
  def create
    @translation_editor_param = TranslationEditorParam.new(translation_editor_param_params)

    if @translation_editor_param.save
      tflash('create', :success, {:model=>@@model, :count=>1})  
      redirect_to @translation_editor_param, notice: ' translation editor param was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /translation_editor_params/1
  def update
    if @translation_editor_param.update(translation_editor_param_params)
       tflash('update', :success, {:model=>@@model, :count=>1})
      redirect_to @translation_editor_param, notice: ' translation editor param was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /translation_editor_params/1
  def destroy
    @translation_editor_param.destroy
    
    redirect_to translation_editor_params_url, notice: ' translation editor param was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_translation_editor_param
      @translation_editor_param = TranslationEditorParam.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def translation_editor_param_params
      params.require(:translation_editor_param).permit(:dot_key_code, :param_name, :param_order, :param_default)
    end
end
