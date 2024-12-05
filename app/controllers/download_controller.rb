class DownloadController < ApplicationController
  respond_to :json # Specify that this controller responds to JSON requests

  def download_search_field_json

  end


  def download_search_json
    permitted_params = download_search_json_download_params
    param_hash = {}
    search_params = permitted_params[:q]

    f_params = permitted_params[:f]
    range_params = permitted_params[:range]
    Rails.logger.info "Permitted Params: #{permitted_params}"

    # Rails.logger.info "f_params Params: #{f_params}"
    # Rails.logger. info "Range Param∂s: #{range_params}"
    Rails.logger.info "search_params Params: #{search_params}"

    unless f_params.nil?
      f_params.each do |param_name, param_values|
      param_value = param_values.first # Get the first value from the array
      param_hash[param_name] = param_value
      end
    end

    Rails.logger.info "ParamHassh: #{param_hash}"

    range_queries = {}

    # Iterate over the range_params hash

    unless range_params.nil?
      range_params.each do |field_name, field_values|
        # Check if the field_values are present and include both "begin" and "end" values
        if field_values.present? && field_values.key?('begin') && field_values.key?('end')
          # Extract "begin" and "end" values from the hash
          begin_value = field_values['begin']
          end_value = field_values['end']

          # Create a range query for Solr
          range_query = "#{field_name}:[#{begin_value} TO #{end_value}]"

          # Add the range query to the hash
          range_queries[field_name] = range_query
        end
      end
    end

    # solr_query = param_hash.map do |attr_name, attr_value|
    #   "#{attr_name}:\"#{attr_value}\""
    # end.join(' AND ')

    query_components = []

    # Add the range queries to the query components
    unless range_params.nil?
      range_queries.each do |field_name, range_query|
        query_components << range_query
      end
    end

    # Iterate over the f_params hash and add them to the query components
    unless param_hash.nil?
      param_hash.each do |field_name, field_value|
      query_components << "#{field_name}:\"#{field_value}\""
      end
    end

    # Join all query components using 'AND' to create the final Solr query
    solr_query = query_components.join(' AND ')



    # Rails.logger.info "range_queries: #{range_queries}"
    Rails.logger.info "Solr Query12: #{solr_query}"

    solr_url = Blacklight.default_configuration.connection_config[:url]
    solr = RSolr.connect(url: solr_url)
    solr_params = { q: solr_query,rows: 1000000, wt: 'json' }
    response = solr.get('select', params: solr_params)



    if response && response['response'] && response['response']['docs']
      # records = response['response']['docs']
      # render json: records
      json_data = JSON.generate(response["response"]["docs"])
      send_data json_data, filename: "download_json", type: 'application/json'

    else
      render json: { error: 'No records found' }, status: :not_found
    end
  end

  private
  def download_search_json_download_params

    params.permit(f:{}, range: {},q: {} ) # Permit the array parameter
  end
end
