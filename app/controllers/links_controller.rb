class LinksController < ApplicationController
  before_action :authenticate_user!

  def index
    @links = current_user.links
  end

  def create
    link_params = params.require(:link).permit(:destination_url)
    @link = current_user.create_link(link_params)
    unless @link.persisted?
      render status: 400
    end
  end

end
