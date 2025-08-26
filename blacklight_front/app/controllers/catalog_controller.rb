# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include BlacklightRangeLimit::ControllerOverride
  include Blacklight::Marc::Catalog


  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    config.advanced_search[:enabled] = true
    config.advanced_search[:form_solr_paramters] = {}
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    # default advanced config values
    # config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # # config.advanced_search[:qt] ||= 'advanced'
    # config.advanced_search[:url_key] ||= 'advanced'
    # config.advanced_search[:query_parser] ||= 'dismax'
    # config.advanced_search[:form_solr_parameters] ||= {}

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    #config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'item_title'
    config.index.partials = [:index_header, :thumbnail, :index]
    config.index.display_type_field = 'format'
    config.index.group = false
    #config.index.display_type_field = 'format'
    #config.index.thumbnail_field = 'thumbnail_path_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config. add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    #config.show.title_field = 'title_tsim'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)


    # Commenting Out


    config.add_facet_field 'partnerInstitution', label: 'Institution', sort: 'alpha', limit: 10
    config.add_facet_field 'source_collection_label', label: 'Collection', sort: 'alpha', limit: 10
    config.add_facet_field 'item_series_title', label: 'Series', sort: 'alpha', limit: 10 #latest
    config.add_facet_field 'City', label: 'Location', sort: 'alpha', limit: 10
    config.add_facet_field 'item_production_context', label: 'Production Context', sort: 'alpha', limit: 10
    config.add_facet_field 'item_genre', label: 'Genre', sort: 'alpha', limit: 10
    # config.add_facet_field 'collection_source_collection', label: 'Collection'
    config.add_facet_field 'Production_Date', label: 'Production Date',sort: 'index', limit: 10
    config.add_facet_field 'Publication_Date', label: 'Publication Date',sort: 'index', limit: 10
    config.add_facet_field 'Performance_Date', label: 'Performance Date',sort: 'index', limit: 10
    config.add_facet_field 'material_designations', label: 'Material Designation', sort: 'alpha', limit: 10
    # config.add_facet_field 'physical_composition', label: 'Physical Composition'
    config.add_facet_field 'recording_type', label: 'Recording Type', sort: 'alpha', limit: 10
    config.add_facet_field 'AV_type', label: 'AV Type', sort: 'alpha', limit: 10
    config.add_facet_field 'playback_mode', label: 'Playback Mode', sort: 'alpha', limit: 10
    config.add_facet_field 'creator_names', label: 'Creator Names', limit: 10
    config.add_facet_field 'contributors_names', label: 'Contributor Names', limit: 10


    # config.add_facet_field 'pub_date_ssim', label: 'Publication Year', single: true
    # config.add_facet_field 'subject_ssim', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'language_ssim', label: 'Language', limit: true
    # config.add_facet_field 'lc_1letter_ssim', label: 'Call Number'
    # config.add_facet_field 'subject_geo_ssim', label: 'Region'
    # config.add_facet_field 'subject_era_ssim', label: 'Era'
    #
    # config.add_facet_field 'example_pivot_field', label: 'Pivot Field', pivot: ['format', 'language_ssim'], collapsing: true
    #
    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 25 } TO *]" }
    # }
    #
    #
    # # Have BL send all facet field names to Solr, which has been the default
    # # previously. Simply remove these lines if you'd rather use Solr request
    # # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'source_collection_label', label: 'Collection'

    #config.add_show_field 'collection_source_collection_description', label: 'Collection Description'
    config.add_index_field 'collection_source_collection_description', label: 'Collection Description'

    config.add_index_field 'performer_name', label: 'Performers',link_to_facet: 'contributors_names'
    config.add_index_field 'creator_names', label: 'Creators',link_to_facet: 'creator_names'
    config.add_index_field 'contributors_names', label: 'Contributors',link_to_facet: 'contributors_names'
    config.add_index_field 'item_genre', label: 'Genre'
    config.add_index_field 'Production_Date', label: 'Production Date'
    config.add_index_field 'Publication_Date', label: 'Publication Date'
    config.add_index_field 'Performance_Date', label: 'Performance Date'
    config.add_index_field 'Address', label: 'Address'
    config.add_index_field 'Venue', label: 'Venue'
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # config.add_show_field 'partnerInstitution', label: 'Partner Institution'
    # config.add_show_field 'collection_source_collection', label: 'Collection'
    # config.add_show_field 'source_collection_label', label: 'Series'
    # config.add_show_field 'item_title_note', label: 'Title Note'
    # config.add_show_field 'item_title_source', label: 'Title Source'
    # config.add_show_field 'item_language', label: 'Language'
    # config.add_show_field 'item_production_context', label: 'Production Context'
    # config.add_show_field 'item_genre', label: 'Genre'
    # config.add_show_field 'performer_name', label: 'Performers',link_to_facet: 'contributors_names'
    #
    # config.add_show_field 'author_name', label: 'Authors',link_to_facet: 'contributors_names'
    # config.add_show_field 'Presenter_name', label: 'Presenters',link_to_facet: 'contributors_names'
    # config.add_show_field 'Interviewer_name', label: 'Interviewers',link_to_facet: 'contributors_names'
    #
    # config.add_show_field 'Producer_name', label: 'Producers',link_to_facet: 'contributors_names'
    # config.add_show_field 'Recordist_name', label: 'Recordists',link_to_facet: 'contributors_names'
    # config.add_show_field 'Series_organizer_name', label: 'Series organizers',link_to_facet: 'contributors_names'
    #
    # config.add_show_field 'Reader_name', label: 'Readers',link_to_facet: 'contributors_names'
    # config.add_show_field 'Speaker_name', label: 'Speakers',link_to_facet: 'contributors_names'
    # config.add_show_field 'Storyteller', label: 'Storytellers',link_to_facet: 'contributors_names'
    #
    # config.add_show_field 'Production_Date', label: 'Production Date', range:true
    # config.add_show_field 'Publication_Date', label: 'Publication Date',range:true
    # config.add_show_field 'Performance_Date', label: 'Performance Date',range:true
    # config.add_show_field 'contributors_names', label: 'Contributors',link_to_facet: 'contributors_names'
    # # config.add_show_field 'Related_works', label: 'Related Works', helper_method: related_works_helper
    # config.add_show_field 'content_notes', label: 'Content'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    # config.show_doc_actions "email", enabled: false
      # email: {
      #   enabled: false
      # },
      # cite: {
      #   enabled: false
      # }


    # config.add_search_field 'all_fields', label: 'All Fields'
    config.add_search_field('All Fields') do |field|
      all_fields = %w[AV_type Address City Dates Interviewer_name Location Note Performance_Date Presenter_name Producer_name Production_Date Publication_Date Reader_name Recordist_name Related_works Series_organizer_name Speaker_name Storyteller Venue _version_ access all_text_timv author_name cataloger_name collection_contributing_unit collection_source_collection collection_source_collection_description collection_source_collection_id content_notes contents contributors contributors_names contributors_names_search creator_names creator_names_search creators dates_overall digital_description format id insitution_collection_item_id item_genre item_identifiers item_language item_production_context item_series_title item_subseries_title item_title item_title_note item_title_source lat lng material_description material_designations partnerInstitution performer_name persistent_url physical_compositions playback_mode recording_type rights rights_license rights_notes source_collection_label timestamp]
      field.solr_parameters = {
        # 'spellcheck.dictionary': 'subject',
        qf: all_fields.join(' '),
        pf: all_fields.join(' ')
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.



    config.add_search_field('Contributor and Creator') do |field|
      field.solr_parameters = {
        # 'spellcheck.dictionary': 'subject',
        qf: 'contributors_names_search creator_names_search',
        pf: 'contributors_names_search creator_names_search'
      }
    end

    config.add_search_field('Contents') do |field|
      field.solr_parameters = {
        # 'spellcheck.dictionary': 'subject',
        qf: 'contents content_notes digital_description',
        pf: 'contents content_notes digital_description'
      }
    end

    config.add_search_field('Title') do |field|
      field.solr_parameters = {
        # 'spellcheck.dictionary': 'subject',
        qf: 'item_title',
        pf: 'item_title'
      }
    end
    config.add_search_field('Location') do |field|
      field.solr_parameters = {
        # 'spellcheck.dictionary': 'subject',
        qf: 'Location',
        pf: 'Location'
      }
    end
    config.add_search_field('Related Works') do |field|
      field.solr_parameters = {
        # 'spellcheck.dictionary': 'subject',
        qf: 'Related_works',
        pf: 'Related_works'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.qt = 'search'
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'subject',
    #     qf: '${subject_qf}',
    #     pf: '${subject_pf}'
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.

    #Comenting out
    # config.add_sort_field 'relevance', sort: 'score desc, pub_date_si desc, title_si asc', label: 'relevance'
    # config.add_sort_field 'year-desc', sort: 'pub_date_si desc, title_si asc', label: 'year'
    # config.add_sort_field 'author', sort: 'author_si asc, title_si asc', label: 'author'
    # config.add_sort_field 'title_si asc, pub_date_si desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggester
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'

  end



end
