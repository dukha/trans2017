class ContactsController < ApplicationController
  # The line below only when fixed attr_accessible
  # before_action :set_contact, only: [:show, :edit, :update, :destroy]
=begin
 from latest version 

  # GET /contacts
  #def index
    #@contacts = Contact.all
  #end
=end
  # Comment out the next 2 lines if not using authentication and authorisation
  before_filter :authenticate_user!
  before_action :set_contact, only: [ :edit, :update, :destroy, :show]
  filter_access_to :all

  @@model ="contact"

  # GET /contacts
  # GET /contacts.xml
  def index

    if Contact.respond_to? :searchable_attr  
      searchable_attr = Contact.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if Contact.respond_to? :sortable_attr  
      sortable_attr = Contact.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @contacts = Contact.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class Contact < ActiveRecord::Base
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

    end  # end class Contact  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.nil? || searchable_attr.empty?  
  @contacts = Contact.paginate(:page => params[:page], :per_page=>15)
else
  search_info = init_search(current_user, searchable_attr, sortable_attr)#init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@contacts = Contact.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @contacts = Contact.search(current_user, search_info).paginate(:page => params[:page], :per_page=>15)
end


if @contacts.count == 0 then
  tflash( "no_records_found", :warning)
end  
respond_to do |format|
  format.html # index.html.erb
  #format.json { render < %= key_value :json, "@#{plural_table_name}" %> }
  format.xml  { render :xml => @contacts }
end
  end

  # GET /contacts/1
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  def create
    @contact = Contact.new(contact_params)
    @contact.user_id = current_user.id if @contact.user_id.blank?

    if @contact.save
      tflash('create', :success, {:model=>@@model, :count=>1})  
      redirect_to( :controller => 'whiteboards',:action => "index")
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /contacts/1
  def update
    if @contact.update(contact_params)
       tflash('update', :success, {:model=>@@model, :count=>1})
       redirect_to( :action => "index")
    else
      render action: 'edit'
    end
  end

  # DELETE /contacts/1
  def destroy
    begin
      @contact.destroy
      respond_to do |format|
        tflash('delete', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to(contacts_path) }
        format.js {}
      end 
    rescue StandardError => e
      @contact = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

  
    def contact_params
      params.require(:contact).permit(:problem_area, :screen_name, :last_menu_choice, :description, :user_id)
    end
end
