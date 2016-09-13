module BookHelpers
  def current_page_key
    key = current_page.url
    if current_page.options[:locale]
      key.sub!("/#{current_page.options[:locale]}/", '')
    end
    key.sub(/^\//, '').chomp('/')
  end

  def auto_lang
    if current_page.options[:locale] and data["auto_#{current_page.options[:locale]}"]
      return data["auto_#{current_page.options[:locale]}"]
    else
      return data["auto_en"]
    end
  end

  def current_page_section_number
    auto_lang.url_to_section_number[current_page_key]
  end

  def current_page_data
    auto_lang.section_data[current_page_section_number]
  end

  def next_page
    auto_lang.section_data[current_page_data.try(:next_page)]
  end

  def prev_page
    auto_lang.section_data[current_page_data.try(:prev_page)]
  end

  def first_section
    auto_lang.section_data.each do |i, section|
      return {i => section} unless section.prev_page
    end
  end

  def sections_in_hierarchy
    previous_sections_indices = {}
    sections_to_delete = []
    sections = sections_in_order
    sections.each_with_index do |s_hash, index|
      section_key = s_hash.keys.first
      section = s_hash.values.first
      sections[index][section_key][:children] = []
      previous_sections_indices[section_key] = index
      if section.hierarchy.length > 0
        parent = section.hierarchy.last
        sections[previous_sections_indices[parent]][parent][:children] << s_hash
        sections_to_delete << index
      end
    end
    sections_to_delete.reverse.each do |index|
      sections.delete_at(index)
    end
    return sections
  end

  def sections_in_order
    sections = [first_section]
    while next_page = sections.last.values.first.next_page
      sections << {next_page => auto_lang.section_data[next_page]}
    end
    return sections
  end
end
