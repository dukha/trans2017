namespace :version do
  task :create => :environment do
    calmapp_version = CalmappVersion.new(ENV["params"])
    
    calmapp_version.save
  end
end    