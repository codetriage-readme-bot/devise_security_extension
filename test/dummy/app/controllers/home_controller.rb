class HomeController < ApplicationController
  before_action :authenticate_user!, only: :secret_data

  def index; end

  def secret_data; end
end
