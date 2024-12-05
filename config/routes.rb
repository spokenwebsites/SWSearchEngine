Rails.application.routes.draw do
 # concern :range_searchableBlacklightRangeLimit::Routes::RangeSearchable.new
#BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
 #   concerns :range_searchable

  end
  devise_for :users

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end
  resources :bookmark, only: [] do
    collection do
      get 'download_json', to: 'bookmark#download_json', as: :download_json
      get 'download_text', to: 'bookmark#download_text', as: :download_text

    end
  end
  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end


 resources :download do
    collection do
      get 'download_search_json', to: 'download#download_search_json', as: :download_search_json
    end
  end




  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
