class HomeHelper
  def self.get_facets
    # Fetch unique collection labels from Solr
    solr_url = Blacklight.default_configuration.connection_config[:url]
    solr = RSolr.connect(url: solr_url)
    solr_params = {
      q: '*:*',
      wt: 'json',
      facet: true,
      'facet.field': 'collection_source_collection',
      'facet.limit': -1,
      'facet.mincount': 1
    }
    response = solr.get('select', params: solr_params)
    if response && response['facet_counts'] && response['facet_counts']['facet_fields']
      collection_labels = response['facet_counts']['facet_fields']['collection_source_collection']
      collection_labels
    end
  rescue StandardError => ex
    Rails.logger.warn "Error fetching recently added feed: #{ex.message}."
    []
  end
end