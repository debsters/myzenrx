require_relative '../scraper'
require 'resolv-replace'
require 'resolv' # Resolv::DNS
require 'resolver_replace' # ResolverReplace




def scrape_medications_and_indexes(range_letters)
	(range_letters).to_a.each do |index_letter|
		new_index_hash = {letter: "#{index_letter}"}
		new_index = Index.create(new_index_hash)
		Scraper.controller("#{index_letter.downcase}").each do |hash|
			hash[:index] = new_index
			Medication.create(hash)
		end
	end
end	

scrape_medications_and_indexes('A'..'Z')

# def scrape_medications_and_index_per_one_index(one_letter)
# 	new_index_hash = {letter: "#{one_letter}"}
# 	new_index = Index.create(new_index_hash)
# 	Scraper.controller("#{one_letter.downcase}").each do |hash|
# 		hash[:index] = new_index
# 		Medication.create(hash)
# 	end
# end	

# scrape_medications_and_index_per_one_index('A')