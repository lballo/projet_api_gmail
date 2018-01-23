require_relative 'townhall-scrap'

PAGE_URL = "http://www.annuaire-des-mairies.com/yvelines.html"
table = get_all_the_urls_of_townhalls(PAGE_URL)
gets_email =[]
table.each do |element|
	gets_email<<element["city_email"]
end
gets_names = []
table.each do |element|
	gets_names<<element["city_name"]
end
p gets_email
p gets_names

puts table

def send_mail_to_line(table)

end	


