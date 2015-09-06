
namespace :trans do
  require Rails.root + 'app/models/demo.rb'
=begin
  desc "Sets the database up for a demo or developer use with some data. Seeds and then adds new data for demo."
  task :load_demo => [:environment, 'db:seed'] do
    Demo.demo()
  end
  task :demo=>[:environment] do
    Demo.demo()
  end
  desc "Migrates, seeds and loads the demo but no applications. Loads 2 letter templates and variables for world organisation"
  task :load_seeds_demo => [:environment, 'db:migrate', :load_demo, 'standard_letter_templates:auto_create'] 
  
  desc "Migrates, seeds, adds demo data, adds forms via rabbitMQ. Receive must be last because it has to be stopped by ctrl+C"
  task :complete_demo => [:environment,  'load_seeds_demo', 'pform_app:students_to_courses', 'pform_queue:receive']
  
  desc "Drops the db and then loads everything again for a demo"
  #task :start_again => [:environment, 'db:drop', 'db:create', :complete_demo]
  task :start_again => [:environment, 'db:drop', 'db:create', 'db:migrate', 'db:seed', 'demo', 'standard_letter_templates:auto_create' , 'pform_app:students_to_courses','pform_queue:receive']
=end 
  task :load_dotenv =>[:environment ] do
    # config/application.rb
    Bundler.require(*Rails.groups)
    Dotenv::Railtie.load
  end
  task :full_seed => [:environment, 'trans:load_dotenv', 'db:setup'] do#'db:migrate:reset', 'db:seed'] do
    puts "Seeded"
  end
  
  task :mini_demo => [:full_seed] do
    Demo.mini_demo
  end
  desc "db:migrate:reset runs drop, create, migrate"
  task :start_again => [:environment, 'db:migrate:reset', 'db:seed', "trans:demo"] do
    
    FileUtils::remove_dir "public/system/translation_uploads/yaml_uploads", true
  end
  task :demo => [:environment] do
    Demo.demo
  end
  
  task :marks_big_demo => ["trans:start_again"] do
    Demo.marks_big_demo
  end
  
  task :integ_big_demo => ["trans:start_again"] do
    Demo.integ_big_demo
  end
  task :translation_demo => ["trans:marks_big_demo"] do
    Demo.translation_demo
  end
=begin  
  task :start_again_demo => [:environment, 'demo', 'standard_letter_templates:auto_create' ,  'pform_app:students_to_courses','pform_queue:receive']

  desc "after start_again_seed use this to add test user albert as sysadmin and set up the AT table whic is mandatory for organisations"
  task :start_again_minimal => [:environment] do
    Demo.minimal()
  end
=end
end
=begin
namespace :calm35 do
  # A work in progress: don't use yet
   desc "Setup a calm35 minimal install of the type that will be used for a new server. Includes latest AT's, Includes calm3 remote servers and a calm35 server. sysadmin user albert, Latest Assistant teachers"
   task :start_again_seed =>[:environment, "db:migrate:reset"] do  #, 'calm:start_again_seed','calm:start_again_minimal'] do
     Seeds35.seed35() 
     Demo.add_albert
            
   end
   # create sysdmin world called albert
   desc "Adds 4 areas under calm35 server. Adds users: world_sisi with profile c35 admin, world_guest with profile guest "
   desc "c35_sysadmin user can continue and add test remote host, instances and venues in the demo"
   task :sysadmin_demo=> [:environment, "calm35:start_again_seed"] do
     Demo.demo35
     user =  {:password => '123456',:password_confirmation => '123456',:username => 'world_sisi35', :email =>  'world_sisi35@hisplace.net'}
     userx = User.create! user
     userx.add_permission location: Location.where{name =~ 'world'}.first, profile: Profile.where{name =~ 'c35_sysadmin'}.first, make_current: true
     
     Demo.add_world_guest 
   end
   
   desc "Adds test remote host, and instances for Dhamma Rasmi and Dhamma Bhumi Trusts. Adds user rasmi_addi as c35_admin on rasmi"
   task :admin_demo=> [:environment, "calm35:sysadmin_demo"] do
     Demo.add_test_remote_host_demo35
     Demo.add_test_au_instances_demo35
     user =  {:password => '123456',:password_confirmation => '123456',:username => 'rasmi_addi35', :email =>  'rasmi_addi35@hisplace.net'}
     userx = User.create! user
     userx.add_permission location: Organisation.where{name =~ '%rasmi trust%'}.first, profile: Profile.where{name =~ 'c35_sysadmin'}.first, make_current: true
     
   end
   
   desc "creates the admin demo but then imports the venues from calm 3. Creates Brisbane and Dhamma Rasmi venues for calm 3.5"
   task :admin_with_venues_demo => [:environment, "calm35:admin_demo"] do
     Demo.add_test_rasmi_venues_demo35
     rasmi_org = Organisation.where{name =~ 'calm 3.5 dhamma rasmi trust'}.first
     rasmi_venue = Venue.new(:name => 'Dhamma Rasmi', :c30_venue=> C30Venue.find_by_name('[RASMI]'), :parent=>rasmi_org, :timezone =>  Timezone.where{zone=='Brisbane'}.first)
     rasmi_venue.save!
     puts 'created Dhamma Rasmi Venue'
     bris_venue = Venue.new(:name => 'Brisbane', :c30_venue=> C30Venue.find_by_name('[BRISBA]'), :parent=>rasmi_org, :timezone =>  Timezone.where{zone=='Brisbane'}.first)
     bris_venue.save!
     puts 'created Brisbane Venue'
     rasmi_org.organisation_default_venue_id = rasmi_venue.id
     save!
     puts "set rasmi as default venue"    
   end

end
=end
  
