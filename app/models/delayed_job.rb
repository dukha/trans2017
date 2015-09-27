class DelayedJob < ActiveRecord::Base
  extend SearchModel
  include SearchModel

  def self.searchable_attr 
     %w(id  run_at attempts failed_at )
  end
  def self.sortable_attr
      %w(id  run_at attempts failed_at )
  end
  
end
