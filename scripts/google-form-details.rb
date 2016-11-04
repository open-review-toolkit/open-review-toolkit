#!/usr/bin/env ruby

# This script accesses a Google Form public URL and the form and field data,
# which is useful for building custom forms that submit to the Google Form.
#
# Example usage:
#   ./scripts/google-form-details.rb https://docs.google.com/forms/d/e/1FAIpQLScAuhOh6GNsRDJN4wcY8uJrn-B_CABdmtHe5vWff9PQkhLKRw/viewform

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'

url = ARGV[0]
if !url
  print "Enter public Google Form URL: "
  url = gets.strip
end

raise Exception.new("#{url.inspect} is not a URL") unless url.match(/^https?:/)

doc = Nokogiri::HTML(open(url))
form = doc.css('form').first
action = form["action"]

print "\nForm action: #{action}\n\n"
form.css('input, textarea').each do |el|
  label = el['aria-label']
  name = el['name']
  puts "#{label}: #{name}" if label and name
end
print "\n"
