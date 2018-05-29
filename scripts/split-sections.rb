#!/usr/bin/env ruby

# This script processes an HTML file produced by pandoc has two outputs. The
# first is a JSON file that contains metadata about the structure of the book.
# Secondly, it creates an HTML file for each section in the original HTML file
# and writes those files to the directory specified. The name and hierarchy of
# a section determines the file name and path, as each sub-section is nested
# within its parent.
#
# Example usage:
#   ./scripts/split-sections.rb pandoc-output.html \
#     directory/to/place/html/section/files > data.json

require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'json'

def get_section_header_text(section_header)
  sh = section_header.dup
  sn = sh.css('.header-section-number')[0]
  sn.remove if sn
  sh.text.strip
end

def cleanup_section_id(section_id)
  section_id.to_s.gsub('sec:', '')
end

def get_toc_section_number_or_id(link)
  toc_sn = link.css('.toc-section-number')
  if toc_sn[0]
    return toc_sn[0].text
  else
    return cleanup_section_id(link.attribute('href').to_s.gsub('#', ''))
  end
end

def get_section_number_or_id(section)
  section_number_el = section.css('.header-section-number')[0]
  if section_number_el
    return section_number_el.text
  else
    return cleanup_section_id(section.attribute('id'))
  end
end

raise Exception.new("#{ARGV[1]} is not a directory") unless File.directory?(ARGV[1])
doc = File.open(ARGV[0]) { |f| Nokogiri::HTML(f) }

language = ENV['LANGUAGE'] || 'en'
toc = doc.css("#TOC")
toc_links = toc.css('li a:first-of-type')

url_to_section_number = {}
section_data = {}

# Extract sections from HTML document. Extract deepest nested sections first.
levels = [4, 3, 2, 1]
levels.each do |level|
  doc.css("section.level#{level}").each do |section|
    section_id = cleanup_section_id(section.attribute('id'))
    section_header = section.css('h1, h2, h3, h4, h5, h6')[0]
    only_section_header = section_header.text.strip == section.text.strip
    section_header_text = get_section_header_text(section_header)
    section_number = get_section_number_or_id(section)
    section_ancestors = section.ancestors('section')
    hierarchy = section_ancestors.map {|s| cleanup_section_id(s.attribute('id').to_s) }.reverse
    hierarchy_section_numbers = section_ancestors.map {|s| get_section_number_or_id(s) }.reverse


    path = File.join(ARGV[1], hierarchy)
    FileUtils.mkdir_p(path)
    File.write(File.join(path, "#{section_id}.#{language}.html.erb"), section.to_s)

    next_page = prev_page = nil
    toc_links.each_with_index do |link, i|
      if get_toc_section_number_or_id(link) == section_number
        prev_page = get_toc_section_number_or_id(toc_links[i-1]) if i > 0
        if i + 1 < toc_links.length
          next_page = get_toc_section_number_or_id(toc_links[i+1])
        end
      end
    end

    url_path = File.join(hierarchy + [section_id])
    url_to_section_number[url_path] = section_number

    section_data[section_number] = {
      path: url_path,
      header: section_header_text,
      full_header_text: section_header.text.strip,
      next_page: next_page,
      prev_page: prev_page,
      only_section_header: only_section_header,
      hierarchy: hierarchy_section_numbers,
    }

    # Remove section so that it won't be included with its parent sections.
    section.remove
  end
end
data = {
  url_to_section_number: url_to_section_number,
  section_data: section_data,
}
print data.to_json
