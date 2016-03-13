namespace :update  do
  desc "Show data to be updated from v 0.9.0 to 0.9.9"
  desc "Version 0.9.9 only allows empty strings for a few dot_keys. Others must be null"
  task :find_empty_strings => [:environment] do
    permitted_keys = Translation.valid_empty_string_dot_key_code
    id_array = []
    #put json in here
    array = Translation.where{(translation == '') | (translation == "\"\"")}.where{dot_key_code << my{permitted_keys}}.to_a
    array.each{|t|
      puts "id : " + id.to_s
      puts "cavtl : " + t.calmapp_versions_translation_language.description
      puts "dot_key_code : " + t.dot_key_code
      #puts "translation : " + translation
      id_array << id
      }
      #rails_delete_statement = "Translation.delete(" + id_array.to_s + ")"
      if id_array.size > 0
        rails_update_statement ="Translation.where{ id >> my{" + id_array.to_s + "} }.update_all(translation : nil)"
        puts rails_update_statement
      else
        puts "nothing to update"
      end  
  end
  
  task :check_plurals => [:environment] do
    puts "begin check_plurals"
    plurals_json = Translation.where{translation =~ "{%"}.where{translation =~ "%}"}
    #binding.pry
    plurals = []
    not_plurals = []
    plurals_json.each do |p|
       plurals << ActiveSupport::JSON.decode(p.translation)
       keys = plurals.last.keys
       
       keys.each{|k|
         unless CldrType.PLURALS.include?(k)
           not_plurals << plurals.delete(p)
           puts "removed " + p.to_s 
           break
         end
       }
    end
    puts "plurals"
    Puts ''
    puts "These records rejected as plurals:" 
    puts not_plurals.to_s
  end
  task :check_booleans  => [:environment] do
    permitted_bool_dkcs = Translation.boolean_translations
    trans = Translation.where{dot_key_code >> my{permitted_bool_dkcs}}.to_a
    faults[]
    trans.each{|t|
      if t.translation  != "true"
        if t.translation != "false"
          faults << t
        end
      end 
    }
    bad_trans =  Translation.where{(translation == 't') | (translation == 'f' )}.to_a
    puts bad_trans.to_s
  end
  
  task :check_nils=> [:environment] do
    #binding.pry
    nulls = Translation.where{ translation == "null"}.to_a
    puts "bad nulls"
    puts nulls.to_s
    nils = Translation.where{ translation == "nil"}.to_a
    months = Translation.where{ dot_key_code =~ "%month_names"}.to_a 
    no_json_arr = []
    months.each{|m|
      no_json = ActiveSupport::JSON.decode(m.translation)
      unless no_json[0].nil?
        no_json_arr << m    
      end
    }
    puts "Bad months nils"
    puts no_json_arr.to_s
  end
end