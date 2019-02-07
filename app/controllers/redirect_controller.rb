class RedirectController < ApplicationController

  def show
    link = Link.find_by(public_identifier: params[:public_identifier])
    if link.nil?
      head 404
    else
      LinkRedirect.insert(link, referrer: request.headers["Referrer"])
      redirect_to link.destination_url
    end
  end

end
