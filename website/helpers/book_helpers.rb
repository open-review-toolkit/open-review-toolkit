module BookHelpers
  def current_page_key
    key = current_page.url
    if current_page.options[:locale]
      key.sub!("#{config[:http_prefix].chomp('/')}/#{current_page.options[:locale]}/", '')
    end
    edition = current_page_edition
    if edition
      key.sub!("#{edition}", '')
    end
    r = Regexp.new(/^#{config[:http_prefix]}/)
    key.sub(r, '').chomp('/')
  end

  def current_page_prefix
    [current_page.options[:locale] || config[:human_translations].first, current_page_edition || default_edition].compact.join("/")
  end

  def default_edition
    config[:editions].first
  end

  def current_page_edition
    url_paths = current_page.url.split('/')
    url_paths[2] if config[:editions].include? url_paths[2]
  end

  def auto_lang
    edition = current_page_edition
    if edition
      d = data[edition]
    else
      d = data[default_edition]
    end

    if current_page.options[:locale] and data["auto_#{current_page.options[:locale]}"]
      return d["auto_#{current_page.options[:locale]}"]
    else
      return d["auto_en"]
    end
  end

  def current_page_section_number
    auto_lang.url_to_section_number[current_page_key]
  end

  def current_page_data
    auto_lang.section_data[current_page_section_number]
  end

  def next_page
    next_p = auto_lang.section_data[current_page_data.try(:next_page)]
    if next_p.try(:only_section_header)
      next_p = auto_lang.section_data[next_p.try(:next_page)]
    end
    return next_p
  end

  def prev_page
    prev_p = auto_lang.section_data[current_page_data.try(:prev_page)]
    if prev_p.try(:only_section_header)
      prev_p = auto_lang.section_data[prev_p.try(:prev_page)]
    end
    return prev_p
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
