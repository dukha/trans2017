class DetachedProcessSubscriber < AbstractDetachedProcess
=begin  
  attr_accessor :connection, :channel, :queue, :exchange
  def initialize exchange_name, conn = nil
    @connection = conn || Bunny.new
    @connection.start 
    @channel = @connection.create_channel
    @queue = @channel.queue queue_name, :durable=>true #:auto_delete=>true
    @exchange = @channel.direct("version") #.default_exchange
  end
  
  dps.subscribe("update")
=end  
  def subscribe  operation
    @queues[operation] = @channel.queue(operation, :durable=>true).bind(@exchange, :routing_key=> operation) #if @queues[operation].nil?
    #while true
      @queues[operation].subscribe do |delivery_info, metadata, payload|
        payload_hash = JSON.load(payload)
        puts payload_hash.to_s
        puts payload.class.name
      end # do
    #end # while
  end # subscribe
end # class