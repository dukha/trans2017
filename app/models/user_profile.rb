class UserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :profile
  
  validates :user_id, :uniqueness => {:scope=> :profile_id}
  
  after_commit :add_cavs_tls, :on => :create#, :if => Proc.new {|user_profile|  user_profile.profile.name == $SYSADMIN }
  
  
  def add_cavs_tls
    #binding.pry
    if profile.name == $SYSADMIN then
      user.application_administrator = true
      user.administrator_cavs_tls << CalmappVersionsTranslationLanguage.all
      user.administrator_cavs_tls.uniq!
      user.save!
    end
  end
  
  
end
