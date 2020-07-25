class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def index_routes url=nil
    eval(url || "#{self.controller_name.chomp("Controller").pluralize.underscore}_path")
  end
end
