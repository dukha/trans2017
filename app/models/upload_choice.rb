class UploadChoice
  attr_accessor :name, :id
=begin
  choices = {t($FL + "overwrite")=> "overwrite", 
            t($FL + "skip") =>"skip", 
            t($FL + "cancel_operation")=>"cancel"
            }
=end
  def initialize parms = {}
    @name=parms[:name]
    @id = parms[:id]
  end
  def self.all
      [
      UploadChoice.new(name: I18n.t($FL + "overwrite"), id: "overwrite") , 
      UploadChoice.new(name: I18n.t($FL + "skip"), id: "skip") , 
      UploadChoice.new(name: I18n.t($FL + "cancel_operation"), id: "cancel") 
=begin
       [t($FL + "overwrite"), "overwrite"],
       [t($FL + "skip"),"skip" ],
       [t($FL + "cancel_operation"), "cancel"]
=end       
      ]
  end
  
 
end