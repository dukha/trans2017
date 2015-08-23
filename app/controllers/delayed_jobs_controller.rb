class DelayedJobsController < ApplicationController
  # The line below only when fixed attr_accessible
  # before_action :set_delayed_job, only: [:show, :edit, :update, :destroy]
=begin
 from latest version 

  # GET /delayed_jobs
  #def index
    #@delayed_jobs = Delayedjob.all
  #end
=end
  # Comment out the next 2 lines if not using authentication and authorisation
  before_action :set_delayed_job, only: [ :edit, :update, :destroy, :show]
  before_filter :authenticate_user!
  filter_access_to :all

  @@model ="delayed_job"

  # GET /delayed_jobs
  # GET /delayed_jobs.xml
  def index

    if DelayedJob.respond_to? :searchable_attr  
      searchable_attr = DelayedJob.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if DelayedJob.respond_to? :sortable_attr  
      sortable_attr = DelayedJob.sortable_attr     
    else   
      sortable_attr = []   
    end

    sorting=sort_list(sortable_attr)
    #For this above sorting and searching to work, to work you will need to be able to call
    # @delayed_jobs = DelayedJob.search(current_user, criteria, operators, sorting).paginate(:page => params[:page], :per_page=>15)
    # e.g. Course.search(current_user, criteria, operators, sorting)
    # Your model should also look like this.
    # Just copy the code after class....
    # and before ...end # end class 
    # into your model
=begin
    class DelayedJob < ActiveRecord::Base
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

    end  # end class DelayedJob  
=end   
# Now change the line with paginate below to the commented out line that uses the search method the search method
# Any dates that you wish to search on will have to be converted 
# Fix your model accordingly or delete all the searh stuff

if searchable_attr.nil? || searchable_attr.empty?  
  @delayed_jobs = DelayedJob.paginate(:page => params[:page], :per_page=>5)
else
  search_info = init_search(current_user, searchable_attr, sortable_attr)#init_search(criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr))
  #@delayed_jobs = DelayedJob.search(current_user, criterion_list(searchable_attr), operator_list( searchable_attr, criterion_list(searchable_attr)),sort_list(sortable_attr)).paginate(:page => params[:page], :per_page=>15)
  @delayed_jobs = DelayedJob.search(current_user, search_info).paginate(:page => params[:page], :per_page=>5)
end


if @delayed_jobs.count == 0 then
  tflash( "no_records_found", :warning)
end  
respond_to do |format|
  format.html # index.html.erb
  #format.json { render < %= key_value :json, "@#{plural_table_name}" %> }
  format.xml  { render :xml => @delayed_jobs }
end
  end

  # GET /delayed_jobs/1
  def show
  end

  # GET /delayed_jobs/new
  def new
    @delayed_job = DelayedJob.new
  end

  # GET /delayed_jobs/1/edit
  def edit
  end

  # POST /delayed_jobs
  def create
    @delayed_job = DelayedJob.new(delayed_job_params)

    if @delayed_job.save
      tflash('create', :success, {:model=>@@model, :count=>1})  
      redirect_to @delayed_jobs, notice: 'Delayed job was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /delayed_jobs/1
  def update
    if @delayed_job.update(delayed_job_params)
       tflash('update', :success, {:model=>@@model, :count=>1})
      redirect_to @delayed_jobs, notice: 'Delayed job was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /delayed_jobs/1
  def destroy
    #@delayed_job.destroy
    
    #redirect_to delayed_jobs_url, notice: 'Delayed job was successfully destroyed.'
    begin
        
      @delayed_job.destroy
      tflash('delete', :success, {:model=>@@model, :count=>1})
      respond_to do |format|
    
        format.html { redirect_to(delayed_jobs_url) }
        format.js {}
      end
    rescue StandardError => e
  
      @delayed_job = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end  
  end

  def start
    system("bin/delay_job start")
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delayed_job
      @delayed_job = DelayedJob.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def delayed_job_params
      params.require(:delayed_job).permit(:priority,:handler, :locked_at,:last_error, :attempts, :failed_at, :run_at)
    end
end
