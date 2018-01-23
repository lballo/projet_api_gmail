require_relative 'townhall-scrap'

PAGE_URL = "http://www.annuaire-des-mairies.com/yvelines.html"

def go_through_all_the_lines
table = get_all_the_urls_of_townhalls(PAGE_URL)
gets_email =[]
	table.each do |element|
		gets_email<<element["city_email"]
	end
	gets_names = []
	table.each do |element|
		gets_names<<element["city_name"]
	end
	gets_email
	gets_names
end
puts table

go_through_all_the_lines

def send_mail_to_line(table)
	gets_email = go_through_all_the_lines()
	
	gets_email.each do |mail|
		username = ENV['USERNAME']
		password = ENV['PASSWORD']

		gmail = Gmail.new(username, password)
		gmail.deliver do
			to 'city_emails'
     		subject "The Hacking project: proposition de partenariat"
     	end
	    text_part do
        body "Text of plaintext message."
    end
end
end



