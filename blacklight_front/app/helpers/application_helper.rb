module ApplicationHelper
  include Blacklight::UrlHelperBehavior

  # Parse related works JSON into symbolized hashes
  def related_works_helper(field_value)
    return [] if field_value.blank?

    JSON.parse(field_value).map(&:symbolize_keys)
  rescue JSON::ParserError => e
    Rails.logger.error "Error parsing related works: #{e.message}"
    []
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
    link_to value, search_link(value, field), class: "card source_collection #{css_class}"
  end

  # Shared formatter (Blacklight 8)
  def format_people_with_roles(value:, document:, source_field:, facet_field:, **)
    fallback = Array(value).join(', ')
    return fallback unless document.present?

    raw = document[source_field]
    return fallback unless raw.present?

    json = raw.is_a?(Array) ? raw.first : raw
    return fallback if json.blank? || json == '[]'

    people = JSON.parse(json)
    return fallback unless people.is_a?(Array)

    grouped = Hash.new { |h, k| h[k] = [] }

    people.each do |person|
      name = person['name']
      next unless name.present?

      roles = Array(person['role']).reject(&:blank?)
      grouped[name] |= roles
    end

    grouped.map do |name, roles|
      link = link_to(
        name,
        search_catalog_path(f: { facet_field => [name] })
      )

      roles.any? ? "#{link} (#{roles.join(', ')})" : link
    end.join(', ').html_safe

  rescue JSON::ParserError => e
    Rails.logger.error "Error formatting #{source_field}: #{e.message}"
    fallback
  end

  # Creators
  def format_creators_with_roles(**args)
    format_people_with_roles(
      **args,
      source_field: 'creators',
      facet_field: :creator_names
    )
  end

  # Contributors
  def format_contributors_with_roles(**args)
    format_people_with_roles(
      **args,
      source_field: 'contributors',
      facet_field: :contributors_names
    )
  end
end
