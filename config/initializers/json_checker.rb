#only trans
module JSON
  def self.is_json?(foo)
    begin
      return false unless foo.is_a?(String)
      # We use ActiveSupport::JSON.decode here rather than JSON.parse as it seems to work with Strings 
      # and things like "%{attribute} %{value}"
      ActiveSupport::JSON.decode(foo)
    rescue JSON::ParserError
      return false
    end 
  end
end