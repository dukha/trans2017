module SearchModel
=begin
  $Operators = {
    "equal" =>"eq",
    "not_equal" => "not_eq",
    "equal_case_insenstive" => "eq_str",
    "not_equal_case_insensitive" => "not_eq_str",
    "less_than_or_equal_to_date" => "lte_date",
    "greater_than_or_equal_to_date" => "gte_date",
    "less_than" => "lt",
    "greater_than" => "gt",
    "contains" => 'matches',
    "does_not_contain" => "does_not_match",
    "matches" => 'matches',
    "does_not_match" => "does_not_match",
    "starts_with" =>  "starts_with",
    "begins_with" => "starts_with",
    "ends_with" => "ends_with",
    "empty_string" => "empty_string",
    "blank_string" => "empty_string",
    "is_null" => "is_null",
    "is_nil" => "is_null",
    "is_empty" => "is_null",
    'not_null' => "not_null",
    'is_not_null' => "not_null",
    "in" => "in",
    "not_in" => "not_in",
    "contained_in" =>"in",
    "not_contained_in" => "not_in"
  }
=end
  
  class Operators
    attr_reader :equal, :equals, :not_equal, :equal_case_insenstive,  :not_equal_case_insensitive  , :less_than_or_equal_to_date,
    :greater_than_or_equal_to_date  , :less_than  , :greater_than  , :contains, :does_not_contain, :matches  , :does_not_match  ,  :starts_with  ,
     :like  , :not_like  , :is_like  ,  :is_not_like  , :starts_with , :begins_with  , :empty_str  , :ends_with  ,  :empty_str  , :is_empty_str,
     :blank_str  , :is_blank_str  ,  :is_null  , :is_nil , :is_empty  , :not_null  , :is_not_null  ,  :in  , :not_in  ,
     :is_not_in , :is_in  , :contained_in  , :is_contained_in  ,  :not_contained_in  , :is_equal_to, :equal_to, :not_equal_to, :is_not_equal_to
     
     def initialize
        @equal = "eq" 
        @not_equal =  "not_eq" 
        @equals = @equal
        @equal_to =  @equal
        @is_equal_to = @not_equal
        @is_not_equal_to = @not_equal
        @not_equal_to  = @not_equal
        
        
        @equal_case_insenstive =  "eq_str" 
        @not_equal_case_insensitive =  "not_eq_str" 
        @less_than_or_equal_to_date =  "lte_date" 
        @greater_than_or_equal_to_date =  "gte_date" 
        @less_than =  "lt" 
        @greater_than =  "gt" 
        @contains =  'matches' 
        @does_not_contain =  "does_not_match" 
        @is_like = @contains
        @is_not_like = @does_not_contain
        @matches =  @contains 
        @like = @contains
        @not_like = @does_not_contain
        @does_not_match =  @does_not_contain 
        @starts_with =   "starts_with" 
        @begins_with =  @starts_with 
        @ends_with =  "ends_with" 
        @empty_str =  "empty_string" 
        @blank_str =  @empty_str
        @is_empty_str = @empty_str
        @is_blank_str =  @empty_str
        @is_null =  "is_null" 
        @is_nil =  @is_null 
        @is_empty =  @is_null 
        @not_null =  "not_null" 
        @is_not_null =  @not_null 
        @in =  "in" 
        @not_in =  "not_in" 
        @is_not_in = @not_in
        @is_in = @in
        @is_contained_in = @in
        @is_not_contained_in = @not_in
        @contained_in = @in 
        @not_contained_in =  @not_in
     end
  end
    
  
  def build_lazy_loader ar_relation, criteria ={},  operators= {}
    ops = Operators.new
    criteria.each { |k,v|
   
       attr= 'squeel.' + k.to_s
      if operators[k]== ops.equal  then
        ar_relation= ar_relation.where{|squeel| eval(attr) == v }
      elsif operators[k] == ops.not_equal then       
        ar_relation= ar_relation.where{|squeel| eval(attr) != v }
      elsif operators[k]== ops.equal_case_insenstive  then
        # Note that we use the matches operator (without wildcards) here so that we get a case insensitive equals
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ v }
      elsif operators[k] == ops.not_equal_case_insensitive  then 
        # Note that we use the does_not_match operator (without wildcards) here so that we get a case insensitive not equals      
        ar_relation= ar_relation.where{|squeel| eval(attr) !~ v }  
      elsif operators[k]  == ops.less_than_or_equal_to_date || operators[k]  == 'lte' then
        ar_relation= ar_relation.where{|squeel| eval(attr) <=  v }
      elsif operators[k]  == ops.greater_than_or_equal_to_date || operators[k]  == 'gte' then
        ar_relation= ar_relation.where{|squeel| eval(attr) >=  v }
      elsif operators[k]  == ops.less_than then
        ar_relation= ar_relation.where{|squeel| eval(attr) <  v }
      elsif operators[k]  == ops.greater_than then
        ar_relation= ar_relation.where{|squeel| eval(attr) >  v }
      elsif operators[k]  == ops.matches then
        # squeel generates ilike query for postgres with =~
        # in general does what it needs to get a case insensitive search for your db
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ '%' + v + '%' } 
      elsif operators[k]  == ops.does_not_match then
        ar_relation= ar_relation.where{|squeel| eval(attr) !~ '%' + v + '%' }
      elsif operators[k] == ops.starts_with  then   
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ v + '%' }
      elsif operators[k] == ops.ends_with  then 
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ '%' + v }
      elsif operators[k] == ops.empty_str  then 
        ar_relation= ar_relation.where{|squeel| eval(attr) ==  '' }
      elsif operators[k] == ops.is_null  then        
        ar_relation = ar_relation.where{ |squeel| eval(attr) == nil}
      elsif operators[k] == ops.not_null  then        
        ar_relation = ar_relation.where{ |squeel| eval(attr) != nil}
      elsif operators[k] == ops.in  then 
        ar_relation = ar_relation.where{ |squeel| eval(attr) >> v}
      elsif operators[k] == ops.not_in  then 
        ar_relation = ar_relation.where{ |squeel| eval(attr) << v}        
      end
    }
    return ar_relation
  end
  
  def build_lazy_loading_sorter ar_relation, sorting= {}

    if ! (sorting[:sort].nil? || sorting[:direction].nil?) then
         # We reorder here rather than order because sortable columns wouldn't work with multiple sorts
         ar_relation = ar_relation.reorder(sorting[:sort] + ' ' + sorting[:direction])
       end
     return ar_relation
  end
  
  # param current_user
  # param search_info is a hash with the 3 keys :criteria, :operators, :sorting
  # search_info is usually obtained from init_search(...) in the search_controller)
  # param activerecord_relation is a preliminary instance of ActiveRecordRelation. 
  # Only necessary for special criteria not implementable via this method 
  def search(current_user, search_info={}, activerecord_relation=nil)
     if activerecord_relation == nil then
       # Make a default activerecord_relation
       lazy_loader = order("id asc")
     else
       lazy_loader = activerecord_relation  
     end
 
     lazy_loader = build_lazy_loader(lazy_loader, search_info[:criteria], search_info[:operators])
     lazy_loader =  build_lazy_loading_sorter(lazy_loader, search_info[:sorting])
     return lazy_loader
  end
end