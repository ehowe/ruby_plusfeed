class SiteController < ApplicationController
  caches_page :index, :expires_in => 4.hours
  def index
    
  end
end
