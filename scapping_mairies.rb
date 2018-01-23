require 'rubygems'
require 'nokogiri'   
require 'open-uri' 
require 'google_drive'
require 'googleauth'
require 'gmail'
require 'pry'
require 'dotenv'


def get_townhall_email(url)
    page = Nokogiri::HTML(open(url))
    xpath_str = '//html/body/table/tr[3]/td/table/tr[1]/td[1]/table[4]/tr[2]/td/table/tr[4]/td[2]/p'
    page.xpath(xpath_str).first
end


def get_all_townhalls(url)
    page = Nokogiri::HTML(open(url))
    cities = page.css("td p a").css(".lientxt")
    cities.map do |city|
        relative_url = "http://annuaire-des-mairies.com" + city['href'][1..-1]
        return {
          'name': city.text,
          'email': get_townhall_email(relative_url)
        }
    end
end

def get_spreadsheet
    sheets_session = GoogleDrive::Session.from_config("config.json")
    # sheet_key = "1TNYguHiSGvk6M5I6p-vSUDohIxqSR8ylXXCR3MhSegI" #officiel
    sheet_key = "1WHB8kTSsRwuAw-puZ7AQoNPXtRNjv5xLaOSgx5ZOQuM" #test
    sheets_session.spreadsheet_by_key(sheet_key).worksheets.first
end


def fill_spreadsheet(url)
    sheet = get_spreadsheet

    sheet[1,1] = "Name"
    sheet[1,2] = "Email"

    get_all_townhalls(url).each_with_index do |townhall, i|
        sheet[i+1, 1] = townhall["name"]
        sheet[i+1, 2] = townhall["email"]
    end

    w.save
end


def send_email(email, subject, body_text, body_html)
    Dotenv.load
    username = ENV['USERNAME']
    password = ENV['PASSWORD']

    gmail = Gmail.new(username, password)

    gmail.deliver do
      to email
      subject subject
      text_part do
        body body_text
      end
      html_part do
        content_type 'text/html; charset=UTF-8'
        body body_html
      end
    end
end 


def send_all_emails
    sheet = get_spreadsheet
    sheet.rows.each do |town|
        town_name = town[0]
        town_email = town[1]
        subject = 'Proposition de partenariat'
        body_text = "Nous aimerions beaucoup que la ville de #{town_name} fasse partie de The hacking project !"
        body_html = "<h1>Nous aimerions beaucoup que la ville de #{town_name} fasse partie de The hacking project !</h1>"
        send_email(town_email, subject, body_text, body_html)
    end
end


url = 'http://www.annuaire-des-mairies.com/yvelines.html'
fill_spreadsheet(url)
#send_all_emails