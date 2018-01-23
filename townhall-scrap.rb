require 'rubygems'
require 'nokogiri'   
require 'open-uri' 
require "google_drive"
require "googleauth"
require 'gmail'
require 'pry'
require 'dotenv'

Dotenv.load


 
=begin credentials = Google::Auth::UserRefreshCredentials.new(
  client_id: "YOUR CLIENT ID",
  client_secret: "YOUR CLIENT SECRET",
  scope: [
    "https://www.googleapis.com/auth/drive",
    "https://spreadsheets.google.com/feeds/",
  ],
  redirect_uri: "http://example.com/redirect")
auth_url = credentials.authorization_uri
=end

SESSION = GoogleDrive::Session.from_config("config.json")

# wk = "1TNYguHiSGvk6M5I6p-vSUDohIxqSR8ylXXCR3MhSegI" #officiel
wk = "1WHB8kTSsRwuAw-puZ7AQoNPXtRNjv5xLaOSgx5ZOQuM" #test

w = SESSION.spreadsheet_by_key(wk).worksheets[0]

w.reload

#PAGE_URL = "http://www.annuaire-des-mairies.com/yvelines.html"
def get_the_email_of_a_townhal_from_its_webpage(url) #récupère les pages URL sur la page principale des mairies
    page = Nokogiri::HTML(open(url))
    table_catch = page.xpath('//html/body/table/tr[3]/td/table/tr[1]/td[1]/table[4]/tr[2]/td/table/tr[4]/td[2]/p')
    table_catch.each do |elem|
        return elem.text
    end
end
def get_all_the_urls_of_townhalls(url) #récupère les mails pour chaque mairie
    page = Nokogiri::HTML(open(url))
    table= []
    url_catch = page.css("td p a").css(".lientxt")
    url_catch.each  do |city|
        relative_url = "http://annuaire-des-mairies.com" + city['href'][1..-1]
        hashing = Hash.new
        
        hashing["city_name"] = city.text
        hashing["city_email"] = get_the_email_of_a_townhal_from_its_webpage(relative_url)
        table << hashing
        # puts hashing
        # puts table
    end
    table     
end


#table = get_all_the_urls_of_townhalls(PAGE_URL)

def fill_spreadsheet #remplis le spreadsheet sur le google drive

  w[1,1] = "Nom des villes"
  w[1,2] = "email des mairies"

  i = 2
  table.each do |element|
  	w[i,1] = element["city_name"]
  	w[i,2] = element["city_email"]
  	i += 1
  end

  (1..w.num_rows).each do |row|
    (1..w.num_cols).each do |col|
      p w[row, col]
    end
  end
end


def go_through_all_the_lines # récupère les mail et nom des mairies dans le spreadsheet
  w = SESSION.spreadsheet_by_key("1WHB8kTSsRwuAw-puZ7AQoNPXtRNjv5xLaOSgx5ZOQuM").worksheets[0]
  # i = 2
data = []

   w.rows.each do |row|
  #   city_email = row[i, 2]
  #   city_name = row[i, 1]
    # city_names<<row[0]
    # city_emails<<row[1]
    # i+=1
    data << row[1]
    binding.pry
    end

  return data
end


def send_mail_to_line #envoie un mail à chacune des mairies
  
# username = ENV['USERNAME']
# password = ENV['PASSWORD']

# gmail = Gmail.new(username, password)
# go_through_all_the_lines.each do | |
  
# end
#   gmail.deliver do
#     to 'city_emails'
#     subject "The Hacking project: proposition de partenariat"
#   end
#     text_part do
#       body "Text of plaintext message."
#   end
# end

#send_mail_to_line

#def get_the_email__html


#w.save

