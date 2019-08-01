class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include MainHelper
  
  def sql(str)
    @connection = ActiveRecord::Base.connection
    @connection.exec_query(str)
  end
=begin  
  before_action :set_cache_headers

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  

  after_action  :expire_for_development

  protected

  def expire_for_development
    expires_now if Rails.env.development?
  end  
=end  
end
