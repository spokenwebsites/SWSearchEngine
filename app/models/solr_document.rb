# frozen_string_literal: true

# Represent a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
  def swallow_id
    self['id'][0]
  end

  def partnerInstitution
    self['partnerInstitution'][0]
  end
  def source_collection_label
    source_collection_label = self['source_collection_label']
    if source_collection_label&.length.to_i > 0  # check if the array exists and has at least one element

      source_collection_label[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_series_title
    item_series_title = self['item_series_title']
    if item_series_title&.length.to_i > 0  # check if the array exists and has at least one element

      item_series_title[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_subseries_title
    item_subseries_title = self['source_collection_label']
    if item_subseries_title&.length.to_i > 0  # check if the array exists and has at least one element

      item_subseries_title[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end


  #Item Description
  def item_title
    item_title = self['item_title']
    if item_title&.length.to_i > 0  # check if the array exists and has at least one element

      item_title[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_title_source
    item_title_source = self['item_title_source']
    if item_title_source&.length.to_i > 0  # check if the array exists and has at least one element

      item_title_source[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_title_note
    item_title_note = self['item_title_note']
    if item_title_note&.length.to_i > 0  # check if the array exists and has at least one element

      item_title_note[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_language
    item_language = self['item_language']
    if item_language&.length.to_i > 0  # check if the array exists and has at least one element
      item_language[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_production_context
    item_production_context = self['item_production_context']
    if item_production_context&.length.to_i > 0  # check if the array exists and has at least one element
      item_production_context[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_genre
    item_genre = self['item_genre']
    if item_genre&.length.to_i > 0  # check if the array exists and has at least one element
      item_genre[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end


  def persistent_url
    persistent_url = self['persistent_url']
    if persistent_url&.length.to_i > 0  # check if the array exists and has at least one element
      persistent_url[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def item_identifiers
    item_identifiers = self['item_identifiers']
    if item_identifiers&.length.to_i > 0  # check if the array exists and has at least one element
      item_identifiers[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  #Rights
  def rights
    rights = self['rights']
    if rights&.length.to_i > 0  # check if the array exists and has at least one element
      rights[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def rights_license
    rights_license = self['rights_license']
    if rights_license&.length.to_i > 0  # check if the array exists and has at least one element
      rights_license[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def rights_notes
    rights_notes = self['rights_notes']
    if rights_notes&.length.to_i > 0  # check if the array exists and has at least one element
      rights_notes[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  #creators
  def creators
    creators = self['creators']
    if creators&.length.to_i > 0  # check if the array exists and has at least one element
      creators[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  #Contributors
  def contributors
    contributors = self['contributors']
    if contributors&.length.to_i > 0  # check if the array exists and has at least one element
      contributors[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def related_works
     self['Related_works'][0]
  end
  def material_description
    self['material_description'][0]
  end

  def location
    self['Location'][0]
  end

  def digital_description
    digital_description = self['digital_description']
    if digital_description&.length.to_i > 0  # check if the array exists and has at least one element
      digital_description[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end


  #dates
  def dates
    dates = self['Dates']
    if dates&.length.to_i > 0  # check if the array exists and has at least one element
      dates[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  #location
  def location
    location = self['Location']
    if location&.length.to_i > 0  # check if the array exists and has at least one element
      location[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end


  #Content and Content Notes
  def contents
    contents = self['contents']
    if contents&.length.to_i > 0  # check if the array exists and has at least one element
      contents[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  def content_notes
    content_notes = self['content_notes']
    if content_notes&.length.to_i > 0  # check if the array exists and has at least one element
      content_notes[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end


  #notes
  def notes
    notes = self['Note']
    if notes&.length.to_i > 0  # check if the array exists and has at least one element
      notes[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end

  #Related_works
  def related_works
    related_works = self['Related_works']
    if related_works&.length.to_i > 0  # check if the array exists and has at least one element
      related_works[0]  # return the first element
    else
      nil  # return nil if the array is nil or empty
    end
  end
end
