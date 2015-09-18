class TranslationHintsController < ApplicationController
  respond_to :html
  before_action :authenticate_user!
  before_action :set_translation_hint, only: [:show, :edit, :update, :destroy]

  def index
     if TranslationHint.respond_to? :searchable_attr  
      searchable_attr = TranslationHint.searchable_attr 
    else 
      searchable_attr = [] 
    end

    criteria=criterion_list(searchable_attr)
    operators=operator_list( searchable_attr, criteria)

    if TranslationHint.respond_to? :sortable_attr  
      sortable_attr = TranslationHint.sortable_attr     
    else   
      sortable_attr = []   
    end

    #sorting=sort_list(sortable_attr)
    search_info = init_search(current_user, searchable_attr, sortable_attr)
    # Does the search
    activerecord_relation = TranslationHint.all
    @translation_hints = TranslationHint.search(current_user, search_info, activerecord_relation).paginate(:page => params[:page], :per_page=>15)
    #@translation_hints = TranslationHint.paginate(:page => params[:page], :per_page=>15)#TranslationHint.all
    respond_with(@translation_hints)
  end

  def show
    respond_with(@translation_hint)
  end

  def new
    @translation_hint = TranslationHint.new
    respond_with(@translation_hint)
  end

  def edit
  end

  def create
    @translation_hint = TranslationHint.new(translation_hint_params)
    @translation_hint.save
    respond_with(@translation_hints, location: translation_hints_path)
  end

  def update
    @translation_hint.update(translation_hint_params)
    #respond_with(@translation_hint, :location=> translation_hints_path)
    redirect_to(translation_hints_path)
  end

  def destroy
    begin
      @translation_hint.destroy
    rescue StandardError => e
      @calmapp_version = nil
      flash[:error] = e.message
      respond_to do |format|
        format.js
      end
    end #rescue  
  end

  private
    def set_translation_hint
      @translation_hint = TranslationHint.find(params[:id])
    end

    def translation_hint_params
      params.require(:translation_hint).permit(:heading, :example, :description, :dot_key_code)
    end
end
