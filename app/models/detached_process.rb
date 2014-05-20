class DetachedProcess < AbstractDetachedProcess
  
=begin
 
 operation can be "update", "create" or "copy" 
 dp.add_to_queue({"calmapp_version"=>{"id"=>1, "version"=>5}}, "update")
=end
  def add_to_queue payload,  operation
    #raise "invalid_exchange_name" if @exchanges[exchange_name].nil?
    #@queues[operation] = @channel.queue("", :durable=>true).bind(@exchanges[exchange_name], :routing_key=> operation) if @queues[operation].nil?
    @queues[operation] = @channel.queue(operation, :durable=>true).bind(@exchange, :routing_key=> operation) #if @queues[operation].nil?
    
    payload_json = JSON.generate(payload)
    @queues[operation].publish(payload_json)
    
    #connection = Bunny.new
    #connection.start
    #channel = connection.create_channel
    #queue = channel.queue "new_calmapp_version"
    #exchange = channel.default_exchange
  end
  
  def delete_queue(operation)
    @queues[operation].delete
    @queues[operation] = nil
  end
  
  def delete_exchange exchange_name
    @exchanges[exchange_name].delete
    @exchanges[exchange_name] = nil
  end
end