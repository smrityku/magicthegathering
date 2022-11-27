#!/usr/bin/env ruby

require 'optparse'
require 'net/http'
require 'uri'
require 'json'
require 'rack'
require 'fileutils'

options = {}

parser = OptionParser.new do |parser|
  parser.on("-l", "--load-data", "Call magicthegathering and load data into data.json file")
  parser.on("-f", "--first-query", "Returns a list of **Cards** grouped by **`set`**")
  parser.on("-s", "--second-query", "Returns a list of **Cards** grouped by **`set`** and within each **`set`** grouped by **`rarity`**")
  parser.on("-t", "--third-query", "Returns a list of cards from the  **Khans of Tarkir (KTK)** set that ONLY have the colours `red` **AND** `blue`")

  parser.on("-h", "--help", "Prints this help") do
    puts parser
    exit
  end
end

# parse parameter options
parser.parse!(into: options)

def next_url(response)
  links = {}

  response.each_header&.to_h['link'].split(',').each do |link|
    link.strip!

    parts = link.match(/<(.+)>; *rel="(.+)"/)
    links[parts[2]] = parts[1]
  end
  links['next']
end

def getCards(url, cards)
  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  parsed_response = JSON.parse(response.body)

  cards = cards + parsed_response['cards']

  nextUrl = next_url(response)
  puts "Card fetched: #{cards.count}"
  puts "Next URL: #{nextUrl}"
  if nextUrl
    getCards(nextUrl, cards)
  else
    cards
  end
rescue => ex
  puts "Error while fetching cards: #{ex.message}"
  puts url
  getCards(url, cards)
end

file_name = "data.json"
FileUtils.touch(file_name) unless File.exist?(file_name)

unless options[:'load-data'].nil?
  cards = [];
  cards = getCards('https://api.magicthegathering.io/v1/cards', cards)

  File.open(file_name, "w") do |f|
    f.write({cards: cards}.to_json)
  end
  puts "Total cards imported: #{cards.count}"
end

file = File.open file_name
data = JSON.load file
cards = data['cards']
puts "Total cards: #{cards.count}"

result = {}

unless options[:'first-query'].nil?
  result = cards.group_by { |x| x['set'] }
end

unless options[:'second-query'].nil?
  result = cards.group_by { |x| x['set'] }
  result = result.map {|set, list|
    [set, list.group_by { |g|
      g['rarity']
    }
    ]
  }.to_h
end

unless options[:'third-query'].nil?
  cards = cards.select do |value| value['set'] == 'KTK' && (value['colorIdentity'] & %w(R U) == %w(R U)) end
  result = {cards: cards}
end

file_name = 'output.log'
FileUtils.touch(file_name) unless File.exist?(file_name)
File.open(file_name, "w") do |f|
  f.write(JSON.pretty_generate(result))
end

puts 'Output saved in output.log'