class SpecialPartialDotKey < ActiveRecord::Base
include TranslationsHelper
  def self.cldr_keys
    return SpecialPartialDotKey.select(:partial_dot_key).where{cldr == true}
  end
  def self.seed
    SpecialPartialDotKey.create(:partial_dot_key=> $ARM + '%', :sort=> "model", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $ARA + '%', :sort=> "attribute", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $FA + '%', :sort=> "action", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $FH + '%', :sort=> "hint", :cldr=>false)
    
    SpecialPartialDotKey.create(:partial_dot_key=> $FL + '%', :sort=> "attribute/label", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> "roles." + '%', :sort=> "role", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $M + '%', :sort=> "menu", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> "tabs." + '%', :sort=> "tab", :cldr=>false)
    
    SpecialPartialDotKey.create(:partial_dot_key=> "headings." + '%', :sort=> "heading", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $LU + '%', :sort=> "lookup", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $C + '%', :sort=> "common", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $S + '%', :sort=> "search", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> "error." + '%', :sort=> "error", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> "problem." + '%', :sort=> "problem", :cldr=>true)
    
    #SpecialPartialDotKey.create(:partial_dot_key=> $MS + '%', :sort=> "messages", :cldr=>false)
    #SpecialPartialDotKey.create(:partial_dot_key=> $EM  + '%', :sort=> "errors messages", :cldr=>false)
    #SpecialPartialDotKey.create(:partial_dot_key=> $EM  + '%', :sort=> "errors messages", :cldr=>false)
    SpecialPartialDotKey.create(:partial_dot_key=> $EM  + "too_long." + '%', :sort=> "errors messages", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $EM  + "too_short." + '%', :sort=> "errors messages", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $EM  + "wrong_length." + '%', :sort=> "errors messages", :cldr=>true)
    
    SpecialPartialDotKey.create(:partial_dot_key=> $AR + $EM  + "too_long." + '%', :sort=> "errors messages", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $AR + $EM  + "too_short." + '%', :sort=> "errors messages", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $AR + $EM  + "wrong_length." + '%', :sort=> "errors messages", :cldr=>true)
    
    SpecialPartialDotKey.create(:partial_dot_key=> $AM + $EM  + "too_long." + '%', :sort=> "errors messages", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $AM + $EM  + "too_short." + '%', :sort=> "errors messages", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> $AM + $EM  + "wrong_length." + '%', :sort=> "errors messages", :cldr=>true)
    
    SpecialPartialDotKey.create(:partial_dot_key=>$AR +"errors.template.header." + '%', :sort=> "errors",:cldr=>true)
    
    SpecialPartialDotKey.create(:partial_dot_key=>$AM +"errors.template.header." + '%', :sort=> "errors",:cldr=>true)
    
    SpecialPartialDotKey.create(:partial_dot_key=>"errors.template.header." + '%', :sort=> "errors",:cldr=>true)
    
    dt_distance = $DT + "distance_in_words."
    SpecialPartialDotKey.create(:partial_dot_key=> dt_distance + 'about'+ '%', :sort=> "date distance in words", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> dt_distance + 'less'+ '%', :sort=> "date  distance in words", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> dt_distance + 'over'+ '%', :sort=> "date  distance in words", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> dt_distance + 'x_'+ '%', :sort=> "date  distance in words", :cldr=>true)
    SpecialPartialDotKey.create(:partial_dot_key=> dt_distance + 'almost'+ '%', :sort=> "date  distance in words", :cldr=>true)
    
  end
end
