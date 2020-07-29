require './config/environment'
require 'nokogiri'
require 'open-uri'
require 'resolv-replace'
require 'resolv' # Resolv::DNS
require 'resolver_replace' # ResolverReplace
require 'pry'

class Scraper

	def self.scrape_medications_info(index_letter)
		doc = Nokogiri::HTML(open("https://www.rxlist.com/drugs/alpha_#{index_letter}.htm"))
		indexes = doc.css("div.AZ_results ul li")
		
		medications_info = []
		indexes.each do |i|
			if i.css("span.azSource")[0].text.gsub("- ", "") == "FDA"

				medications_info << {
					:name => i.css("a").text,
					:source => i.css("span.azSource")[0].text.gsub("- ", ""),
					:url => i.css("a").attribute("href").value
					}
			end
		end
		medications_info
	end

	def	self.side_effects_url(med_url)
		doc = Nokogiri::HTML(open(med_url))

		url = doc.css("div.tab a.sideEffect").attribute("href").value
		side_effects_url = "https://www.rxlist.com#{url}"
	end

	def self.individual_med_side_effects(side_effects_url)
		doc = Nokogiri::HTML(open(side_effects_url))

		start_xpath = "//section[@class='pageSection'][1]/div[contains(@id,'apPage') and @class='sideeffectheader apPage']/div[@class='wrapper']/div[@class='pgContent']"
		xpath_one = "/ul[1]"
		xpath_two = "/ul[2]"
		xpath_three = "/p"

		se_1 =  doc.xpath("#{start_xpath}#{xpath_one}").text.gsub(/\b,\b/, ", ").lines.map {|x| x.strip }.map {|x| x.gsub(/[^[:ascii:]]/, "") }.map {|x| x.gsub(/(,\z)/, "") }.delete_if {|x| x == ""}.join(", ").gsub("and,", "and").gsub("or,", "or").gsub("nfections", "infections").gsub("iinfections", "infections")

		se_2 = se_1 == "" ? "Empty" : se_1

		se_3 = !(se_2.include? "and some") ? se_2 : doc.xpath("#{start_xpath}#{xpath_two}").text.gsub(/\b,\b/, ", ").lines.map {|x| x.strip }.map {|x| x.gsub(/[^[:ascii:]]/, "") }.map {|x| x.gsub(/(,\z)/, "") }.delete_if {|x| x == ""}.join(", ").gsub("and,", "and").gsub("or,", "or").gsub("nfections", "infections").gsub("iinfections", "infections")

		se_4 = !(se_3 == "Empty") ? se_3 : doc.xpath("#{start_xpath}#{xpath_three}").text.split(".").select {|phrase| ["Common", "common side effect", "side effects", "Side effects"].any?{ |word| phrase.include? word }}.select {|x| x.include? "include"}.join.partition("include").map {|x| x.strip }.last

		se_5 = !(se_4.start_with?(":")) ? se_4 : doc.xpath("#{start_xpath}").text.split(".").select {|phrase| ["Common", "common side effect", "side effects", "Side effects"].any?{ |word| phrase.include? word }}.select {|x| x.include? "include"}.join.partition("include:").last.lines.map {|x| x.strip }.delete_if {|x| x == ""}.map {|x| x.gsub(/(,\z)/, "") }.join(", ").split(/(?=[A-Z])/).delete_if {|string| string.start_with?(/(?=[A-Z])/) }.join.gsub("and,", "and").gsub("or,", "or").strip

		s6 = se_5 == "" ? "Empty" : se_5

		side_effects = s6.delete_suffix(".")
	end

	def self.individual_med_description(side_effects_url)
		doctwo = Nokogiri::HTML(open(side_effects_url))
		start_xpath = "//section[@class='pageSection'][1]/div[contains(@id,'apPage') and @class='sideeffectheader apPage']/div[@class='wrapper']/div[@class='pgContent']"

		xpath_one = "/ul[1]/preceding-sibling::p"
		xpath_two = "/ul/preceding-sibling::p"
		xpath_three = "/following::ul[1]"
		xpath_four = "/p[3]"
		xpath_five = "/p[4]"

		des_page = doctwo.xpath("#{start_xpath}#{xpath_one}").text.strip.gsub("\r\n", "")

		#  part_of_des1
		des_page2 = doctwo.xpath("#{start_xpath}#{xpath_one}#{xpath_three}").text.strip.gsub("\r\n", "").gsub("\t","")

		possible_d1 = des_page == "" ? "empty" : des_page.split(".").delete_if {|phrase| ["Common", "common side effect", "side effects", "Side effects"].any?{ |word| phrase.include? word }}.join(".").insert(-1, '.') 

		possible_d2 = doctwo.xpath("#{start_xpath}#{xpath_four}").text.strip.split(".").delete_if {|phrase| ["Common", "common side effect", "side effects", "Side effects"].any?{ |word| phrase.include? word }}.join(".").insert(-1, '.')

		possible_d3 = possible_d1 == "empty" ? possible_d2 : possible_d1

		possible_d4 = possible_d3.split(".").any?(/(treat:|treating:)/) ? "#{des_page} #{des_page2.gsub(".", "")}".insert(-1, '.') : possible_d3

		possible_d5 = possible_d4 == "." ? doctwo.xpath("#{start_xpath}#{xpath_five}").text.strip.gsub("\r\n", "").split(".").delete_if {|phrase| ["Common", "common side effect", "side effects", "Side effects"].any?{ |word| phrase.include? word }}.join(".").insert(-1, '.')  : possible_d4

		possible_d6 = possible_d5 == "." ? doctwo.xpath("#{start_xpath}/h4[2]/preceding-sibling::p").text.strip : possible_d5

		possible_d7 = ((possible_d6.split(".").any?(/(treat:|treating:)/) == false) && (possible_d6.split(".").any?(/\A\s[A-Z]/) == false)) ? possible_d6.split(".").delete_if {|string| string.start_with?(/\A\s[a-z]/) }.join.insert(-1, '.') : possible_d6

		possible_d8 = possible_d5 == "\u00A0." ? doctwo.xpath("#{start_xpath}/descendant::text()").text.lines.map {|x| x.strip }.delete_if {|x| x == ""}[3].split(".").delete_if {|phrase| ["Common", "common side effect", "side effects", "Side effects"].any?{ |word| phrase.include? word }}.join(".").insert(-1, '.') : possible_d7

		possible_d9 = possible_d8.split(".").delete_if {|string| string.end_with?("include:") }.join(".").insert(-1, '.')

		description = possible_d9 == "." ? possible_d6.split(".").delete_if {|string| string.end_with?("include:") }.join(".").insert(-1, '.') : possible_d9
	end

	def self.info_hash(url)
		med_url = url
		side_effects_url = self.side_effects_url(url)
		side_effects = self.individual_med_side_effects(self.side_effects_url(url))
		description = self.individual_med_description(self.side_effects_url(url))

		info = {
			:description => description,
			:side_effects => side_effects,
			:url => med_url,
			:side_effects_url => side_effects_url
		}
		# info.inject({:name=>"A-Methapred (methylprednisolone sodium succinate)"}){ |hash,(key,value)| hash[key]=value; hash }
	end

	def self.controller(index)
		array = []
		self.scrape_medications_info(index).take(5).each do |hash|
			info_one = self.info_hash(hash.fetch(:url))
			combined_info = info_one.inject({:name=>hash.fetch(:name), :source=>hash.fetch(:source)}){ |hash,(key,value)| hash[key]=value; hash }
			array << combined_info
		end
		array
	end

end

