cavtl = CalmappVersionsTranslationLanguage.find(4)
pth = "/home/mark/.rvm/gems/ruby-2.0.0-p247/gems/rails-i18n-4.0.1/rails/locale/"
dir.each{ |file|
   f = File.new(pth + file)  
   puts file  
   if not File.directory? f.to_path then
       upload = TranslationsUpload.new cavs_translation_language_id: cavtl.id, description: file, yaml_upload: pth + file
       upload.save
       upload.write_file_to_db
   end
   
}


key_value_pairs= { "af.date.abbr_day_names2" => "[\"Son\", \"Maan\", \"Dins\", \"Woe\", \"Don\", \"Vry\", \"Sat\"]","af.date.order2"=> "[:year, :month, :day]" }

#Translation.transaction do
#	TranslationsUpload.translations_to_db key_value_pairs
# end
begin
	key_value_pairs= { "af.date.abbr_day_names2" => "[\"Son\", \"Maan\", \"Dins\", \"Woe\", \"Don\", \"Vryvry\", \"Sat\"]","af.date.order3"=> "[:year, :month, :day]" }
	ret_val= 'ok'
	Translation.transaction do
		t = TranslationsUpload.translations_to_db(key_value_pairs, TranslationsUpload.Overwrite[:all])
		if not t.valid? then
			ret_val = t
			raise ActiveRecord::Rollback
		end
	end
	#binding.pry
	if ret_val.is_a? ActiveRecord::Base then
		ret_val.errors.messages.each{ |k,m| puts k.to_s + m[0]}
		
	else
		puts ret_val.to_s
	end	
	#return ret_val
end


begin
	key_value_pairs= { "af.date.abbr_day_names4" => "[\"Son\", \"Maan\", \"Dins\", \"Woe\", \"Don\", \"Vryvry\", \"Sat\"]","af.date.order5"=> "[:year, :month, :day]" }
	ret_val= 'ok'
	Translation.transaction do
		t = TranslationsUpload.translations_to_db(key_value_pairs, TranslationsUpload.Overwrite[:all])
		if not t.valid? then
			ret_val = t
			raise ActiveRecord::Rollback
		end
	end
	#binding.pry
	if ret_val.is_a? ActiveRecord::Base then
		ret_val.errors.messages.each{ |k,m| puts k.to_s + m[0]}
		
	else
		puts ret_val.to_s
	end	
	#return ret_val
end
=begin
	ret_val = true
Translation.transaction do
	if not TranslationsUpload.translations_to_db(key_value_pairs).valid? then
		ret_val = false
		raise ActiveRecord::Rollback
	end
	puts ret_val
end


puts "RV " + ret_val.to_s

end

=end

split_hash = {:language=> 'af', :dot_key_code=>'date.abbr_day_names2'}
Translation.where{(dot_key_code == split_hash[:dot_key_code]) & (language== split_hash[:language])}