# this task is used to setup all the XX ranslations to be eq to their dot_key_codes
# note that we have to treat the activerecord plurals specially.
# RAILS_ENV=production bundle exec rake xx:put_keys_in_values --trace
namespace :xx do
  desc "copy the keys into the values sections for all translations for xx that do not have any existing value"
  task :put_keys_in_values => :environment do
    xx = TranslationLanguage.find_by(iso_code: 'xx')
    cavs_trans_langs = xx.calmapp_versions_translation_language
    if cavs_trans_langs.any?
      puts "Please select the Calm App Version to do this for:"
      dict = {}
      menu = {}
      cavs_trans_langs.each do |x|
        menu[x.id.to_s] = "#{x.calmapp_version_tl.calmapp.name} Version #{x.calmapp_version_tl.version}"
        dict[x.id.to_s] = x
      end
      menu.each do |k,v|
        puts "#{v} : #{k}"
      end
      selected_version_id = $stdin.gets.chomp
      selected_version = dict[selected_version_id]
      if selected_version.present?
        dry_run = false
        puts "Do you want to do a dry run first to see what will be updated without actually doing the updates? (Y|y/N|n)"
        answer = $stdin.gets.chomp
        while !answer.in?(["Y", "y", "N", "n"])
          puts "incorrect response. Do you want to do a dry run first to see what will be updated without actually doing the updates? (Y|y/N|n)"
          answer = $stdin.gets.chomp
        end
        dry_run = true if answer.in?(["Y", 'y'])
        trans_to_adjust = selected_version.translations.where(translation:"\"\"") # all empty translations
        lang = selected_version.translation_language.iso_code
        trans_to_adjust.each do |t|
          new_translation = "\"#{t.dot_key_code}\""
          if dry_run
            puts "Traslation #{t.dot_key_code} for #{lang} would be updated to #{new_translation}"
          else
            t.update_attribute(:translation, new_translation ) # for some reason all entries are surrounded by \" chars
          end
        end
        plurals_to_adjust = selected_version.translations.where(translation:"{\"one\":\"\",\"other\":\"\"}")
        plurals_to_adjust.each do |p|
          new_translation = p.translation.gsub("one\":\"\"", "one\":\"#{p.dot_key_code}.one\"")
          new_translation = new_translation.gsub("other\":\"\"", "other\":\"#{p.dot_key_code}.other\"")
          if dry_run
            puts "Traslations #{p.dot_key_code} for #{lang} would be updated to #{new_translation}"
          else
            p.update_attribute(:translation, new_translation ) # for some reason all entries are surrounded by \" chars
          end
        end
      else
        puts "That is not one of the options, please enter the id of the version next time"
      end
    end
  end
end
