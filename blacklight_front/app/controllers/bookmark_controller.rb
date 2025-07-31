class BookmarkController < ApplicationController
  def download_json
    ids = params[:format].split("/")
    solr_query = ids.map { |id| "id:\"#{id}\"" }.join(' OR ')
    solr_url = Blacklight.default_configuration.connection_config[:url]
    solr = RSolr.connect(url: solr_url)
    solr_params = { fq: solr_query,rows: ids.size}
    response = solr.get('select', params: solr_params)
    if response && response["response"]["docs"]
      json_data = JSON.generate(response["response"]["docs"])
      send_data json_data, filename: "bookmark_json", type: 'application/json'
    end
  rescue StandardError => ex
    Rails.logger.warn "Error fetching recently added feed: #{ex.message}."
    []
  end


  def download_text
    bookmarks = BookmarkModel.all # Modify this to fetch bookmarks based on your logic
    plain_text_data = "Bookmarks:\n\n"

    bookmarks.each do |bookmark|
      plain_text_data += "Title: #{bookmark.title}\nContent: #{bookmark.content}\n\n"
    end
    send_data plain_text_data, filename: "bookmarks.txt", type: 'text/plain'
  end
end
