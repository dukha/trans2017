#only trans
module JSON
  def self.is_json?(foo)
    begin
      return false unless foo.is_a?(String)
      # We use ActiveSupport::JSON.decode here rather than JSON.parse as it seems to work with Strings 
      # and things like "%{attribute} %{value}"
      foo2 = ActiveSupport::JSON.decode(foo)
      return true
    rescue JSON::ParserError => pe
      return false
    rescue Exception => e
      return false
    end 
  end
end