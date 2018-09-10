#!/usr/bin/env ruby
#
# This script removes the styles from image attributes.
#
# Input the HTML document via STDIN and output will be via STDOUT.

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'json'

html = ARGF.read
html_doc = Nokogiri::HTML(html)

html_doc.css('img').each do |img|
  img.attributes['style'].remove
end

print html_doc.to_html
