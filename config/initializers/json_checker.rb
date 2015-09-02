#only trans
module JSON
  def self.is_json?(foo)
    #binding.pry
    puts foo.class.name 
    begin
      return false unless foo.is_a?(String)
      # We use ActiveSupport::JSON.decode here rather than JSON.parse as it seems to work with Strings 
      # and things like "%{attribute} %{value}"
      foo2 = ActiveSupport::JSON.decode(foo)
      #puts foo2.to_s
      return true
    rescue JSON::ParserError => pe
     # binding.pry
      #puts pe.to_s
      return false
    rescue Exception => e
      #binding.pry
      #puts e.to_s
      return false
    end 
  end
end