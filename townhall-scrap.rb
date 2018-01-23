require 'rubygems'
require 'nokogiri'   
require 'open-uri' 
require "google_drive"
require "googleauth"
require 'gmail'
require 'pry'
require 'dotenv'

Dotenv.load

SESSION = GoogleDrive::Session.from_config("config.json")
w = SESSION.spreadsheet_by_key("1TNYguHiSGvk6M5I6p-vSUDohIxqSR8ylXXCR3MhSegI").worksheets[0]

PAGE_URL = "http://www.annuaire-des-mairies.com/yvelines.html"



def get_spreadsheet
    sheets_session = GoogleDrive::Session.from_config("config.json")
    # sheet_key = "1TNYguHiSGvk6M5I6p-vSUDohIxqSR8ylXXCR3MhSegI" #officiel
    sheet_key = "1WHB8kTSsRwuAw-puZ7AQoNPXtRNjv5xLaOSgx5ZOQuM" #test
    sheets_session.spreadsheet_by_key(sheet_key).worksheets.first
end

w.reload

def get_the_email_of_a_townhal_from_its_webpage(url) # on récupère les pages URL sur la page principale des mairies
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
        relative_url = "http://annuaire-des-mairies.com" + city['href'][1..-1] #on récupère les url des mairies en changeant la fin de l'url
        hashing = Hash.new #on créé un nouveau hash qui nous permettra de stocker les données
        
        hashing["city_name"] = city.text #scrolle les noms des mairies
        hashing["city_email"] = get_the_email_of_a_townhal_from_its_webpage(relative_url) #scrolle les adresses mails des mairies à partir des mails 
        table << hashing #on complète la table de hashage
    end
    table
end

def fill_spreadsheet #remplis le spreadsheet sur le google drive
w = SESSION.spreadsheet_by_key("1TNYguHiSGvk6M5I6p-vSUDohIxqSR8ylXXCR3MhSegI").worksheets[0]

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

get_the_email_of_a_townhal_from_its_webpage(PAGE_URL)
table = get_all_the_urls_of_townhalls(PAGE_URL)
fill_spreadsheet


w.save

