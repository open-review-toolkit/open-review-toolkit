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

html_doc.css('.TOCHeading').each do |sec|
  sec.remove
end

toc = html_doc.css("#TOC")
toc_links = toc.css('li a:first-of-type')
toc_links.each do |link|
  if link.inner_html == '' or ['#table-of-contents', '#notes'].include? link['href']
    link.remove
  end
end

print html_doc.to_html
