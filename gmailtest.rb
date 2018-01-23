require 'gmail'
require 'pry'
require 'dotenv'

Dotenv.load

#    If you pass a block, the session will be passed into the block,
#    and the session will be logged out after the block is executed.

#session = GoogleDrive::Session.from_config("config.json")

username = ENV['USERNAME']
password = ENV['PASSWORD']


gmail = Gmail.new(username, password)

=begin email = gmail.compose do
  to "laura.thehackingproject@gmail.com"
  subject "hello Laura!"
  body "Spent the day on the road..."
end
email.deliver!
=end 

gmail.deliver do
  to "laura.thehackingproject@gmail.com"
  subject "Having fun in Puerto Rico!"
  text_part do
    body "Text of plaintext message."
  end
  html_part do
    content_type 'text/html; charset=UTF-8'
    body "<p>Text of <em>html</em> message.</p>"
  end
end

