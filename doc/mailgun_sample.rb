def send_simple_message
	RestClient.post "https://api:key-47120298e8c9c31b076e5245655e62c7"\
			"@api.mailgun.net/v3/sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org/messages",
			:from => "Mailgun Sandbox <postmaster@sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org>",
			:to => "Mark Lennon <mplennon@gmail.com>",
			:subject => "Hello Mark Lennon",
			:text => "Congratulations Mark Lennon, you just sent an email with Mailgun!  You are truly awesome!  You can see a record of this email in your logs: https://mailgun.com/cp/log .  You can send up to 300 emails/day from this sandbox server.  Next, you should add your own domain so you can send 10,000 emails/month for free."
end


sandbox server
sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org

api_key
key-47120298e8c9c31b076e5245655e62c7

mg_client = Mailgun::Client.new "key-47120298e8c9c31b076e5245655e62c7"

message_params = {:from    => 'bob@sending_domain.com',
                  :to => "mplennon@gmail.com",  
                  :subject => 'The Ruby SDK is awesome!', 
                  :text    => 'It is really easy to send a message!'}

mg_client.send_message "sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org", message_params


Now via smtp

smtp user = postmaster@sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org
smtp pw = 61fdfb39f65575cf4be5f0e325b637a8
code

require 'mail'

Mail.defaults do
	delivery_method :smtp, {
		:port      => 587,
		:address   => "smtp.mailgun.org",
		:user_name => "postmaster@sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org",
		:password  => "61fdfb39f65575cf4be5f0e325b637a8",
		}
end

mail = Mail.deliver do
	to      'mplennon@gmail.com'
	from    'foo@sandboxa89c6db3f73e4ad6b3377c7bb91dbeb1.mailgun.org'
	subject 'Hello smtp'
	
	text_part do
		body 'Testing some Mailgun awesomness vai smtp'
	end
end