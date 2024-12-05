class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  before_action :set_facets_with_range_filter

  private

  def set_facets_with_range_filter
    #these are blacklight facet labels not the solr fields
    @facets_with_range_filter = ['Production Date', 'Publication Date', 'Performance Date']
    #raise "Debugging range: #{@facets_with_range_filter.inspect}"
  end

end
