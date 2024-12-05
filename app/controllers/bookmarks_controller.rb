# frozen_string_literal: true
class BookmarksController < CatalogController
    include Blacklight::Bookmarks
  
    def index
      # Call the original Blacklight index method
      super
      # Access cookie value
      userCookie =  cookies.encrypted[:_my_new_blacklightapp_session]
      userEmail = userCookie["guest_user_id"]
      user = User.find_by(email: userEmail)
      bookmarks = user.bookmarks
      document_ids = bookmarks.map(&:document_id)
      joined_ids = document_ids.join('/')
      @escaped_ids = document_ids.join('/')
  
  
  
  
      # You can now render the view, passing your custom variable
      render 'bookmarks/index'
    end
  end