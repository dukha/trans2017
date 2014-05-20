class AbstractDetachedProcess
  
  attr_accessor :session, :channel, :queues, :exchange
  # only need 1 exchange per instance
  def initialize exchange_name #, conn = nil 
    @session =  Bunny.new
    @session.start 
    @channel = @session.create_channel
    #@queue = @channel.queue queue_name, :durable=>true #:auto_delete=>true
    @exchange = @channel.direct(exchange_name)
    #@exchanges = {}
    #@exchanges[exchange_name] = @channel.direct(exchange_name) if @exchanges[exchange_name].nil?#.default_exchange 
    @queues = {}
  end
end