module SearchModel
  
  def build_lazy_loader ar_relation, criteria ={},  operators= {}
    criteria.each { |k,v|
       attr= 'squeel.' + k
      if operators[k]== 'eq'  then
        ar_relation= ar_relation.where{|squeel| eval(attr) == v }
      elsif operators[k] == 'not_eq'  then       
        ar_relation= ar_relation.where{|squeel| eval(attr) != v }
      elsif operators[k]== 'eq_str'  then
        # Note that we use the matches operator (without wildcards) here so that we get a case insensitive equals
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ v }
      elsif operators[k] == 'not_eq_str'  then 
        # Note that we use the does_not_match operator (without wildcards) here so that we get a case insensitive not equals      
        ar_relation= ar_relation.where{|squeel| eval(attr) !~ v }  
      elsif operators[k]  == 'lte_date' || operators[k]  == 'lte' then
        ar_relation= ar_relation.where{|squeel| eval(attr) <=  v }
      elsif operators[k]  == 'gte_date' || operators[k]  == 'gte' then
        ar_relation= ar_relation.where{|squeel| eval(attr) >=  v }
      elsif operators[k]  == 'lt' then
        ar_relation= ar_relation.where{|squeel| eval(attr) <  v }
      elsif operators[k]  == 'gt' then
        ar_relation= ar_relation.where{|squeel| eval(attr) >  v }
      elsif operators[k]  == 'matches' then
        # squeel generates ilike query for postgres with =~
        # in general does what it needs to get a case insensitive search for your db
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ '%' + v + '%' } 
      elsif operators[k]  == 'does_not_match' then
        ar_relation= ar_relation.where{|squeel| eval(attr) !~ '%' + v + '%' }
      elsif operators[k] == 'starts_with'  then   
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ v + '%' }
      elsif operators[k] == 'ends_with'  then 
        ar_relation= ar_relation.where{|squeel| eval(attr) =~ '%' + v }
      elsif operators[k] == 'empty_string'  then 
        ar_relation= ar_relation.where{|squeel| eval(attr) ==  '' }
      elsif operators[k] == 'is_null'  then        
        ar_relation = ar_relation.where{ |squeel| eval(attr) == nil}
      elsif operators[k] == 'not_null'  then        
        ar_relation = ar_relation.where{ |squeel| eval(attr) != nil}
      elsif operators[k] == 'in'  then 
        ar_relation = ar_relation.where{ |squeel| eval(attr) >> v}
      elsif operators[k] == 'not_in'  then 
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
  
  def search(current_user, criteria, operators, sorting)
           # Make a default activerecord_relation
           lazy_loader = order("id asc")
           lazy_loader = build_lazy_loader(lazy_loader, criteria, operators)
           lazy_loader =  build_lazy_loading_sorter(lazy_loader, sorting)
           return lazy_loader
  end
end