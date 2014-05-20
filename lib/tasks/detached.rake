namespace :version do
  task :create => :environment do
    binding.pry
    calmapp_version = CalmappVersion.new(ENV["params"])
    
    calmapp_version.save
  end
end    