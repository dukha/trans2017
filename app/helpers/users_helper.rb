module UsersHelper

  def unlock_link aUser
    if aUser.access_locked?
      tlink_to 'unlock', unlock_user_path(aUser) , :method => :put, data: {confirm: t($MSDS)}
    else
      ""
    end
  end
end

