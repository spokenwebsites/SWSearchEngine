# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]

  self.default_processor_chain += [:add_creator_names_qf, :restrict_id_field, :add_production_date_query]
# Define the custom processor method to add 'creator_names' to the qf parameter if it's present in the request
def add_creator_names_qf(solr_parameters)
  solr_parameters[:qf] = 'creator_names' if blacklight_params[:creator_names].present?
end


def restrict_id_field(solr_parameters)
  if blacklight_params[:q] && blacklight_params[:q].start_with?('id:')
    solr_parameters[:q] = "id:#{blacklight_params[:q].split(':', 2).last}"
    solr_parameters[:qf] = 'id'
    solr_parameters[:defType] = 'lucene'
  end
end

# Add a query for Production_Date

private

# Add a query for Production_Date based on the incoming query parameters
def add_production_date_query(solr_params)
  # Only run this if the incoming query parameter is present
  if solr_params[:q].present? && solr_params[:q].match?(/Production_Date:\[(\d{4}) TO (\d{4})\]/)
    # Use the existing Production_Date query if found
    existing_query = solr_params[:q]
  else
    # If no specific Production_Date is found, do nothing or set a default if necessary
    return
  end

  # Set the final query back to solr_params
  solr_params[:q] = existing_query
  solr_params[:defType] = 'lucene' # Specify the query type if needed
end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
