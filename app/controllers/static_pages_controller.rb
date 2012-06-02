class StaticPagesController < ApplicationController
  before_filter :authenticate_user!
  def home
    @title="Home"
  end

  def about
    @title="About"
  end

  def help
    @title="Help"
  end
  def textile_help
    @title="Letter formatting help"
  end
  def contact
    @title="Contact"
  end
  def inbox_tba
    @title="inbox_tba"
  end
  def by_course_tba
    @title="by_course_tba"
  end
  def check_referral_tba
    @title="check_referral_tba"
  end
  def letter_config_tba
    @title="letter_config_tba"
  end
  def newsletter_tba
    @title="newsletter_tba"
  end
  def referral_config_tba
    @title="referral_config_tba"
  end
  #def schedules_tba
  #  @title="schedules_tba"
  #end
  def search_application_tba
    @title="search_application_tba"
  end
  def search_old_students_tba
    @title="search_old_students_tba"
  end
  def users_config_tba
    @title="users_config_tba"
  end
end
