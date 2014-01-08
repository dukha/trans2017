class TranslationsUploadsController < ApplicationController
  # place this file in your current railties gem in the correct folder e.g.
  # For using ruby 1.9.2 p180 and rails 3.0.7 place controller.rb in
  # /home/mark/.rvm/gems/ruby-1.9.2-p180/gems/railties-3.0.7/lib/rails/generators/rails/scaffold_controller/templates/
  # delete these comments after generation

  # Comment out the next 2 lines if not using authentication and authorisation
  before_action :authenticate_user!
  filter_access_to :all

  @@model ="translations_upload"

  # GET /translations_uploads
  # GET /translations_uploads.xml
  def index

    if TranslationsUpload.respond_to? :searchable_attr  
      searchable_attr = TranslationsUpload.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if TranslationsUpload.respond_to? :sortable_attr  
      sortable_attr = TranslationsUpload.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @translations_uploads = TranslationsUpload.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class TranslationsUpload < ActiveRecord::Base
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

    end  # end class TranslationsUpload  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.empty?
  @translations_uploads = TranslationsUpload.paginate(:page => params[:page], :per_page=>15)
else
  search_info = init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@translations_uploads = TranslationsUpload.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @translations_uploads = TranslationsUpload.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
end


if @translations_uploads.count == 0 then
  tflash( "no_records_found", :warning)
end 

respond_to do |format|
  format.html # index.html.erb
  format.json { render json: @translations_uploads }
  format.xml  { render :xml => @translations_uploads }
end
  end

  # GET /translations_uploads/1
  # GET /translations_uploads/1.xml
  def show
    @translations_upload = TranslationsUpload.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @translations_upload }
      format.json { render json: @translations_upload }
    end
  end

  # GET /translations_uploads/new
  # GET /translations_uploads/new.xml
  def new
    @translations_upload = TranslationsUpload.new 

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @translations_upload }
      format.json { render json: @translations_upload }
    end
  end

  # GET /translations_uploads/1/edit
  def edit
    @translations_upload = TranslationsUpload.find(params[:id])
  end

  # POST /translations_uploads
  # POST /translations_uploads.xml
  def create
    binding.pry
    @translations_upload = TranslationsUpload.new(params[:translations_upload])
    
    respond_to do |format|
      if @translations_upload.save
        tflash('create', :success, {:model=>@@model, :count=>1})         
        format.html { redirect_to( :action => "index")} 
        format.xml  { render :xml => @translations_upload, :status => :created, :location => @translations_upload }
        format.json { render json: @translations_upload, status: :created, location: @translations_upload }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @translations_upload.errors, :status => :unprocessable_entity }
        format.json { render json: @translations_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /translations_uploads/1
  # PUT /translations_uploads/1.xml
  def update
    @translations_upload = TranslationsUpload.find(params[:id])

    respond_to do |format|
      if @translations_upload.update_attributes(params[:translations_upload])
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( :action => "index")} 
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @translations_upload.errors, :status => :unprocessable_entity }
        format.json { render json: @translations_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /translations_uploads/1
  # DELETE /translations_uploads/1.xml
  def destroy
    @translations_upload = TranslationsUpload.find(params[:id])
    @translations_upload.destroy
    tflash('delete', :success, {:model=>@@model, :count=>1})
    respond_to do |format|
      format.html { redirect_to(translations_uploads_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
