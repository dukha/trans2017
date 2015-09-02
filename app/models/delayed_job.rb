class DelayedJob < ActiveRecord::Base
  extend SearchModel
  include SearchModel

  def self.searchable_attr 
     %w(id  run_at attempts failed_aat  )
  end
  def self.sortable_attr
      DelayedJob.searchable_attr
  end
  
end
