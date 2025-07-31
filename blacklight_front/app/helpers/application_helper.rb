module ApplicationHelper

  def related_works_helper(field_value)
    parsed_values = []
    JSON.parse(field_value).each do |dict|
      parsed_values << dict.symbolize_keys
    end
    parsed_values
  end
  def subdirectory_for_links
  (Rails.application.config.assets.prefix.split("/") - ["assets"]).join("/")
  end
  def search_link(value, field)
    "#{subdirectory_for_links}/?f[#{field}][]=#{CGI.escape(value)}&q=&search_field=all_fields"
  end
  def render_field_row_search_link(value, field, show_always = false)
    return if value.blank?
    css_class = show_always ? "" : "toggable-row hidden-row"
    html = <<-HTML
    
    <a class="card source_collection" href="#{link_to(value, search_link(value, field))}"/>
    HTML
    html.html_safe
  end


end
