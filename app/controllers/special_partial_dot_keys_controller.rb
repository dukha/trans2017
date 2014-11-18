class SpecialPartialDotKeysController < ApplicationController
  # The line below only when fixed attr_accessible
   before_action :set_special_partial_dot_key, only: [:show, :edit, :update, :destroy]
=begin
 from latest version 

  # GET /special_partial_dot_keys
  #def index
    #@special_partial_dot_keys = SpecialPartialDotKey.all
  #end
=end
  # Comment out the next 2 lines if not using authentication and authorisation
  before_action :authenticate_user!
  filter_access_to :all

  @@model ="special_partial_dot_key"

  # GET /special_partial_dot_keys
  # GET /special_partial_dot_keys.xml
  def index

    if SpecialPartialDotKey.respond_to? :searchable_attr  
      searchable_attr = SpecialPartialDotKey.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if SpecialPartialDotKey.respond_to? :sortable_attr  
      sortable_attr = SpecialPartialDotKey.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @special_partial_dot_keys = SpecialPartialDotKey.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class SpecialPartialDotKey < ActiveRecord::Base
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

    end  # end class SpecialPartialDotKey  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.empty?
  @special_partial_dot_keys = SpecialPartialDotKey.paginate(:page => params[:page], :per_page=>15)
else
  search_info = init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@special_partial_dot_keys = SpecialPartialDotKey.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @special_partial_dot_keys = SpecialPartialDotKey.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
end


if @special_partial_dot_keys.count == 0 then
  tflash( "no_records_found", :warning)
end  
respond_to do |format|
  format.html # index.html.erb
  #format.json { render < %= key_value :json, "@#{plural_table_name}" %> }
  format.xml  { render :xml => @special_partial_dot_keys }
end
  end

  # GET /special_partial_dot_keys/1
  def show
  end

  # GET /special_partial_dot_keys/new
  def new
    @special_partial_dot_key = SpecialPartialDotKey.new
  end

  # GET /special_partial_dot_keys/1/edit
  def edit
  end

  # POST /special_partial_dot_keys
  def create
    @special_partial_dot_key = SpecialPartialDotKey.new(special_partial_dot_key_params)

    if @special_partial_dot_key.save
      tflash('create', :success, {:model=>@@model, :count=>1})  
      redirect_to( :action => "index",notice: 'Special partial dot key was successfully updated.')
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /special_partial_dot_keys/1
  def update
    if @special_partial_dot_key.update(special_partial_dot_key_params)
       tflash('update', :success, {:model=>@@model, :count=>1})
      redirect_to( :action => "index",notice: 'Special partial dot key was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE /special_partial_dot_keys/1
  def destroy
    @special_partial_dot_key.destroy
    
    redirect_to special_partial_dot_keys_url, notice: 'Special partial dot key was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_special_partial_dot_key
      @special_partial_dot_key = SpecialPartialDotKey.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def special_partial_dot_key_params
      params.require(:special_partial_dot_key).permit(:partial_dot_key, :sort, :cldr)
    end
end
