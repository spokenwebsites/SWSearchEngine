# configuration_file.rb

require 'httpclient'
require_relative '../../app/lib/date_normalizer'

settings do

  # Where to find solr server to write to
  provide "solr.url", "http://spokenweb_solr:8983/solr/swallow2/"
  # default source type is binary, traject can't guess
  # you have to tell it.
  provide "marc_source.type", "xml"

  # various others...
  provide "solr_writer.commit_on_close", "true"
  provide "nokogiri.each_record_xpath", "//root/swallow-record"
  # The default writer is the Traject::SolrJsonWriter. In the default MARC mode,
  # the default reader in MARC mode is MarcReader (using ruby-marc).
  # In XML mode, it is the NokogiriReader.

end


# To uniquely identify a swallow record.
to_field 'id', extract_xpath("/swallow-record/swallow-id")


#Cataloguer information
to_field 'catalogure_name' do |record, accumulator, _c|
  cataloguer_name = record.xpath("/swallow-record/cataloguer/name").map(&:text).first
  cataloguer_name += ","
  cataloguer_name += record.xpath("/swallow-record/cataloguer/lastname").map(&:text).first
  accumulator.concat [cataloguer_name]
end
to_field 'catalogure_email', extract_xpath("/swallow-record/cataloguer/email")


# INSTITUTION AND COLLECTION
to_field "partnerInstitution" do |record, accumulator, _c|
  partnerInstitution = record.xpath("/swallow-record/classification/classification").map do |node|
    if node.xpath("class-name").map(&:text).include?("partner institution")
      node.xpath("label").text
    else
      nil
    end
  end
  accumulator.concat(partnerInstitution.compact)
end

to_field "collection_source_collection" do |record, accumulator, _c|
  collection_source_collection = record.xpath("/swallow-record/classification/classification").map do |node|
    if node.xpath("class-name").map(&:text).include?("collection")
      node.xpath("label").text
    else
      nil
    end
  end

  accumulator.concat(collection_source_collection.compact)
end

to_field "source_collection_label" do |record, accumulator, _c|
  source_collection_label = record.xpath("/swallow-record/classification/classification").map do |node|
    if node.xpath("class-name").map(&:text).include?("collection")
      node.xpath("label").text
    else
      nil
    end
  end

  accumulator.concat(source_collection_label.compact)
end

to_field 'collection_contributing_unit' do |record, accumulator, _c|
  collection_contributing_unit = record.xpath('/swallow-record/classification/classification/Contributing-Unit').map(&:text).first
  accumulator.concat [collection_contributing_unit]
end

to_field 'collection_source_collection_description' do |record, accumulator, _c|
  collection_source_collection_description = record.xpath('/swallow-record/classification/classification/Source-Collection-Description').map(&:text).first
  accumulator.concat [collection_source_collection_description]
end
to_field 'collection_source_collection_id' do |record, accumulator, _c|
  collection_source_collection_id = record.xpath('/swallow-record/classification/classification/Source-Collection-ID').map(&:text).first
  accumulator.concat [collection_source_collection_id]
end
to_field 'persistent_url' do |record, accumulator, _c|
  persistent_url = record.xpath('/swallow-record/classification/classification/Persistent-URL').map(&:text).first
  accumulator.concat [persistent_url]
end
to_field 'insitution_collection_item_id' do |record, accumulator, _c|
  insitution_collection_item_id = record.xpath('/swallow-record/classification/classification/Source-Item-ID').map(&:text).first
  accumulator.concat [insitution_collection_item_id]
end


#ITEM DESCRIPTION
to_field "item_title", extract_xpath("/swallow-record/Item-Description/title")
to_field "item_title_source", extract_xpath("/swallow-record/Item-Description/title-source")
to_field "item_title_note", extract_xpath("/swallow-record/Item-Description/title-note")
to_field "item_language", extract_xpath("/swallow-record/Item-Description/language")
to_field "item_production_context", extract_xpath("/swallow-record/Item-Description/production-context")
to_field "item_genre", extract_xpath("/swallow-record/Item-Description/genre/genre/value")
# to_field "item_genre" do |record, accumulator, _c|
#   item_genre = record.xpath("/swallow-record/Item-Description/genre/genre/value").map(&:text)
#   accumulator.concat(item_genre)
# end


to_field "item_series_title" do |record, accumulator, _c|
  item_series_title = record.xpath("/swallow-record/classification/classification").map do |node|
    if node.xpath("class-name").map(&:text).include?("series")
      node.xpath("label").text
    else
      nil
    end
  end
  accumulator.concat(item_series_title.compact)
end

to_field "item_subseries_title" do |record, accumulator, _c|
  item_subseries_title = record.xpath("/swallow-record/classification/classification").map do |node|
    if node.xpath("class-name").map(&:text).include?("subseries")
      node.xpath("label").text
    else
      nil
    end
  end
  accumulator.concat(item_subseries_title.compact)
end


to_field 'item_identifiers' do |record, accumulator, _c|
  item_identifiers = record.xpath("/swallow-record/Item-Description/identifiers/identifier/value").map(&:text)
  accumulator << item_identifiers

end


#RIGHTS
to_field "rights", extract_xpath("/swallow-record/Rights/rights")
to_field "rights_license", extract_xpath("/swallow-record/Rights/license")
to_field "rights_notes", extract_xpath("/swallow-record/Rights/notes")
to_field "access", extract_xpath("/swallow-record/Rights/access")


#Creators
# Creators list only names of creators
to_field 'creator_names' do |record, accumulator, _c|
  # item_identifiers = record.xpath("/swallow-record/Creators/Creator/name").map(&:text)
  item_identifiers = record.xpath("/swallow-record/Creators/Creator/name").map{|node| node.text.strip}
  accumulator.concat(item_identifiers)
end

# Creators associated to each event there respective data
to_field "creators" do |record, accumulator, _c|
  creator_node = record.xpath("/swallow-record/Creators/Creator").map do |node|
    {
      url: node.xpath("url").text,
      name: node.xpath("name").text,
      dates: node.xpath("dates").text,
      notes: node.xpath("notes").text,
      nation:node.xpath("nation/nation/value").map(&:text),
      role: node.xpath("role/role/value").map(&:text)
    }
  end
  accumulator.concat [creator_node.to_json.to_s]
end


#Contributors
# Contributors list only names of contributors
to_field 'contributors_names' do |record, accumulator, _c|
  contributors_names = record.xpath("/swallow-record/Contributors/Contributor/name").map{|node| node.text.strip}
  accumulator.concat(contributors_names)
end

# Contributors associated to each event and there respective data
to_field "contributors" do |record, accumulator, _c|
  contributors = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    {
      url: node.xpath("url").text,
      name: node.xpath("name").text,
      dates: node.xpath("dates").text,
      notes: node.xpath("notes").text,
      nation:node.xpath("nation/nation/value").map(&:text),
      role: node.xpath("role/role/value").map(&:text)
    }
  end
  accumulator.concat [contributors.to_json.to_s]
end

#ALL THE PERFORMERS FOR A PARTICULAR EVENT
to_field "performer_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Performer")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "author_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Author")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Presenter_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Presenter")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Interviewer_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Interviewer")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Producer_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Producer")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end


to_field "Recordist_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Recordist")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Series_organizer_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Series organizer")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Reader_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Reader")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end


to_field "Speaker_name" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Speaker")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Storyteller" do |record, accumulator, _c|
  performers = record.xpath("/swallow-record/Contributors/Contributor").map do |node|
    if node.xpath("role/role/value").map(&:text).include?("Storyteller")
      node.xpath("name").text
    else
      nil
    end
  end
  accumulator.concat(performers.compact)
end

to_field "Publication_Date" do |record, accumulator, context|
  # performance_date = record.xpath("/swallow-record/Dates/Date").map do |node|
  Publication_Date = record.xpath("/swallow-record/Dates/Date").map do |node|
    if node.xpath("type").map(&:text).include?("Publication Date")
      node.xpath("date").text
    end
  end
  accumulator.concat [DateNormalizer.years_from_dates(Publication_Date).first]
end

to_field "Production_Date" do |record, accumulator, context|
  production_date = record.xpath("/swallow-record/Dates/Date").map do |node|
    if node.xpath("type").map(&:text).include?("Production Date")
      node.xpath("date").text
    end
  end
  accumulator.concat [DateNormalizer.years_from_dates(production_date).first]
end


to_field "Performance_Date" do |record, accumulator, context|
  performance_date = record.xpath("/swallow-record/Dates/Date").map do |node|
    if node.xpath("type").map(&:text).include?("Performance Date")
      node.xpath("date").text
    end
  end
  accumulator.concat [DateNormalizer.years_from_dates(performance_date).first]
end


#Material Description
to_field "material_description" do |record, accumulator, _c|
  material_description = record.xpath("/swallow-record/Material-Description/Material-Description").map do |node|
    {
      side: node.xpath("side").text,
      image: node.xpath("image").text,
      other: node.xpath("other").text,
      extent: node.xpath("extent").text,
      AV_types: node.xpath("AV-type").text,
      tape_brand: node.xpath("tape-brand").text,
      generations: node.xpath("generations").text,
      Conservation: node.xpath("Conservation").text,
      equalization: node.xpath("equalization").text,
      playback_mode: node.xpath("playback-mode").text,
      playing_speed: node.xpath("playing-speed").text,
      sound_quality: node.xpath("sound-quality").text,
      recording_type: node.xpath("recording-type").text,
      storage_capacity: node.xpath("storage-capacity").text,
      physical_condition: node.xpath("physical-condition").text,
      track_configuration: node.xpath("track-configuration").text,
      material_designation: node.xpath("material-designation").text,
      physical_composition: node.xpath("physical-composition").text,
      accompanying_material: node.xpath("accompanying-material").text,
      other_physical_description: node.xpath("other-physical-description").text,
    }

  end
  accumulator.concat [material_description.to_json.to_s]
end

# Index Material designation inside material Description
to_field 'material_designations' do |record, accumulator, _c|
  material_designation = record.xpath("/swallow-record/Material-Description/Material-Description/material-designation").map(&:text)
  accumulator.concat(material_designation)
end

# Index physical_composition inside material Description
to_field 'physical_compositions' do |record, accumulator, _c|
  physical_composition = record.xpath("/swallow-record/Material-Description/Material-Description/physical-composition").map(&:text)
  accumulator.concat(physical_composition)
end

# Index recording-type inside material Description
to_field 'recording_type' do |record, accumulator, _c|
  recording_type = record.xpath("/swallow-record/Material-Description/Material-Description/recording-type").map(&:text)
  accumulator.concat(recording_type)
end

# Index AV_type inside material Description
to_field 'AV_type' do |record, accumulator, _c|
  AV_type_s = record.xpath("/swallow-record/Material-Description/Material-Description/AV-type").map(&:text)
  accumulator.concat(AV_type_s)
end

# Index playback_mode inside material Description
to_field 'playback_mode' do |record, accumulator, _c|
  playback_mode = record.xpath("/swallow-record/Material-Description/Material-Description/playback-mode").map(&:text)
  accumulator.concat(playback_mode)
end

#Digital file description
to_field "digital_description" do |record, accumulator, _c|
  digital_description = record.xpath("/swallow-record/Digital-File-Description/Digital-File-Description").map do |node|
    {

      file_url: node.xpath("file-url").text,
      file_path: node.xpath("file-path").text,
      filename: node.xpath("filename").text,
      channel_field: node.xpath("channel-field").text,
      sample_rate: node.xpath("sample-rate").text,
      duration: node.xpath("duration").text,
      precision: node.xpath("precision").text,
      size: node.xpath("size").text,
      bitrate: node.xpath("bitrate").text,
      encoding: node.xpath("encoding").text,
      contents: node.xpath("contents").text,
      notes: node.xpath("notes").text,
      title: node.xpath("title").text,
      credit: node.xpath("credit").text,
      caption: node.xpath("caption").text,
      content_type: node.xpath("content-type").text,
      featured: node.xpath("featured").text,
    }

  end
  accumulator.concat [digital_description.to_json.to_s]
end


#Dates
to_field "Dates" do |record, accumulator, _c|
  dates = record.xpath("/swallow-record/Dates/Date").map do |node|


    {
      date: node.xpath("date").text,
      type: node.xpath("type").text,
      notes: node.xpath("notes").text,
      source: node.xpath("source").text,
    }
  end
  accumulator.concat [dates.to_json.to_s]
end
#INDEX ALL THE DATES IN THE APP
# to_field "dates_overall" do |record, accumulator, _context|
#   dates = record.xpath("/swallow-record/Dates/Date/date").map(&:text)
#   accumulator.concat DateNormalizer.format_array_for_display(DateNormalizer.strict_date(dates))
# end


#Location
to_field "Location" do |record, accumulator, _c|
  location = record.xpath("/swallow-record/Location/Location").map do |node|
    {
      url: node.xpath("url").text,
      venue: node.xpath("venue").text,
      notes: node.xpath("notes").text,
      address: node.xpath("address").text,
      latitude: node.xpath("latitude").text,
      longitude: node.xpath("longitude").text,
    }
  end
  accumulator.concat [location.to_json.to_s]
end
to_field "Address" do |record, accumulator, _c|
  address = record.xpath("/swallow-record/Location/Location/address").map(&:text)
  accumulator.concat(address)
end

to_field "Venue" do |record, accumulator, _c|
  venue = record.xpath("/swallow-record/Location/Location/venue").map(&:text)
  accumulator.concat(venue)
end


def extract_province_city(address)
  province_patterns = {
    'Alberta' => /\bAB\b|\bAlberta\b/i,
    'British Columbia' => /\bBC\b|\bBritish\sColumbia\b|\bB\.?C\.?/i,
    'Manitoba' => /\bMB\b|\bManitoba\b/i,
    'New Brunswick' => /\bNB\b|\bNew\sBrunswick\b/i,
    'Newfoundland' => /\bNL\b|\bNewfoundland\b/i,
    'Northwest Territories' => /\bNT\b|\bNorthwest\sTerritories\b/i,
    'Nova Scotia' => /\bNS\b|\bNova\sScotia\b/i,
    'Nunavut' => /\bNU\b|\bNunavut\b/i,
    'Ontario' => /\bON\b|\bOntario\b/i,
    'Prince Edward Island' => /\bPE\b|\bPrince\sEdward\sIsland\b/i,
    'Quebec' => /\bQC\b|\bQuebec\b/i,
    'Saskatchewan' => /\bSK\b|\bSaskatchewan\b/i,
    'Yukon' => /\bYT\b|\bYukon\b/i,
    'United Kingdom' =>  /\bUK\b|\bUnited\sKingdom\b/i,
    'California' => /\bCA\b|\bCalifornia\b/i,
    'New York' => /\bNew\sYork\b|\bNY\b/i,
    'New Mexico' =>  /\bNew\sMexico\b/i,
  }

  city_patterns = {
    'Calgary' => /\bCalgary\b/i,
    'Edmonton' => /\bEdmonton\b/i,
    'Halifax' => /\bHalifax\b/i,
    'Hamilton' => /\bHamilton\b/i,
    'Kingston' => /\bKingston\b/i,
    'London' => /\bLondon\b/i,
    'Montreal' =>  /\bMontreal\b|\bMontréal\b/i,
    'Ottawa' => /\bOttawa\b/i,
    'Quebec City' => /\bQuebec\b|\bQuebec City\b|\bQuébec\b/i,
    'Regina' => /\bRegina\b/i,
    'Saskatoon' => /\bSaskatoon\b/i,
    'Toronto' => /\bToronto\b/i,
    'Vancouver' => /\bVancouver\b/i,
    'Victoria' => /\bVictoria\b/i,
    'Winnipeg' => /\bWinnipeg\b/i,
    'Sherbrooke' => /\bSherbrooke\b/i,
    'Banff' => /\bBanff\b/i,
    'Castlegar' => /\bCastlegar\b/i,
    'Berkeley' => /\bBerkeley\b/i,
    'Durham' => /\bDurham\b/i,
    'Buffalo' => /\bBuffalo\b/i,
    'Paradise Valley' => /\bParadise\sValley\b/i,
    'South Slocan' => /\bSouth\sSlocan\b/i,
    'Nanaimo' => /\bNanaimo\b/i,
    'Burnaby' => /\bBurnaby\b/i,
    'Albuquerque' => /\bAlbuquerque\b/i,
  }

  province = nil
  city = nil

  province_patterns.each do |prov, pattern|
    if address =~ pattern
      province = prov
      break
    end
  end

  city_patterns.each do |cit, pattern|
    if address =~ pattern
      city = cit
      break
    end
  end

  [province, city]
end


# if address empty than do other

to_field "City" do |record, accumulator, _c|
  cities_with_state = []
  helloid = record.xpath("/swallow-record/swallow-id").text
  locations = record.xpath("/swallow-record/Location/Location")
  # address = record.xpath("/swallow-record/Location/Location/address").text
  locations.each do |location|
    address = location.xpath("address").text
    province, city = extract_province_city(address)
    city_with_state = "#{city}, #{province}" if city && province
    # city_with_state = "#{city}, #{province}"
    cities_with_state << city_with_state


  end


  if cities_with_state.empty?
    cities_with_state << "Other"
  end

  accumulator.concat(cities_with_state)
end


# #CONTENT
to_field "content_notes", extract_xpath("/swallow-record/Content/notes")
to_field "contents", extract_xpath("/swallow-record/Content/contents")


#Notes
to_field "Note" do |record, accumulator, _c|
  notes = record.xpath("/swallow-record/Notes/Note").map do |node|
    {
      note: node.xpath("note").text,
      type: node.xpath("type").text

    }
  end
  accumulator.concat [notes.to_json.to_s]
end


#RELATED WORKS
to_field "Related_works" do |record, accumulator, _c|
  related_works = record.xpath("/swallow-record/Related-Works/Related-Work").map do |node|
    {
      url: node.xpath("URL").text,
      citation: node.xpath("citation").text

    }
  end
  accumulator.concat [related_works.to_json.to_s]
end


















