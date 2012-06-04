class <%= controller_class_name %>Controller < ApplicationController
  # place this file in your current railties gem in the correct folder e.g.
  # For using ruby 1.9.2 p180 and rails 3.0.7 place controller.rb in
  # /home/mark/.rvm/gems/ruby-1.9.2-p180/gems/railties-3.0.7/lib/rails/generators/rails/scaffold_controller/templates/
  # delete these comments after generation
  
  # Comment out the next 2 lines if not using authentication and authorisation
  before_filter :authenticate_user!
  filter_access_to :all

  @@model ="<%= singular_table_name %>"
  
  # GET <%= route_url %>
  # GET <%= route_url %>.xml
  def index
    
    searchable_attr = <%=class_name%>.searchable_attr
    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)
    
    sortable_attr=<%=class_name%>.sortable_attr
    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @<%= plural_table_name %> = <%=class_name%>.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class <%=class_name%> < ActiveRecord::Base
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
      
    end  # end class <%=class_name%>  
=end   
    # Now change the line with paginate below to the commented out line that uses the search method the search method
    # Any dates that you wish to search on will have to be converted 
    # Fix your model accordingly or delete all the searh stuff
    #@<%= plural_table_name %> = <%=class_name%>.paginate(:page => params[:page], :per_page=>15)
    @<%= plural_table_name %> = <%=class_name%>.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)  
    if @<%= plural_table_name %>.count == 0 then
      tflash( "no_records_found", :warning)
    end  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render <%= key_value :json, "@#{plural_table_name}" %> }
      format.xml  { render :xml => @<%= plural_table_name %> }
    end
  end

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.xml
  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= singular_table_name %> }
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
    end
  end

  # GET <%= route_url %>/new
  # GET <%= route_url %>/new.xml
  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %> 

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= singular_table_name %> }
      format.json { render <%= key_value :json, "@#{singular_table_name}" %> }
    end
  end

   # GET <%= route_url %>/1/edit
  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
  end

  # POST <%= route_url %>
  # POST <%= route_url %>.xml
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        tflash('create', :success, {:model=>@@model, :count=>1})         
        format.html { redirect_to( :action => "index")} 
        format.xml  { render :xml => @<%= singular_table_name %>, :status => :created, :location => @<%= singular_table_name %> }
        format.json { render <%= key_value :json, "@#{singular_table_name}" %>, <%= key_value :status, ':created' %>, <%= key_value :location, "@#{singular_table_name}" %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= orm_instance.errors %>, :status => :unprocessable_entity }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
      end
    end
  end

  # PUT <%= route_url %>/1
  # PUT <%= route_url %>/1.xml
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        tflash('update', :success, {:model=>@@model, :count=>1})
        format.html { redirect_to( :action => "index")} 
        format.xml  { head :ok }
         format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= orm_instance.errors %>, :status => :unprocessable_entity }
        format.json { render <%= key_value :json, "@#{orm_instance.errors}" %>, <%= key_value :status, ':unprocessable_entity' %> }
      end
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.xml
  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    @<%= orm_instance.destroy %>
    tflash('delete', :success, {:model=>@@model, :count=>1})
    respond_to do |format|
      format.html { redirect_to(<%= index_helper %>_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
