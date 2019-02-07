class LinkAnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_link

  def show
    if timestamps_valid?
      @analytics = LinkRedirect.count_by_referrer(@link, @start_time, @end_time)
    else
      # TODO: Provide better error messages.
      @errors = ["start_time and/or end_time invalid"]
      render status: 400
    end
  end

  private

  # Locate the link associated with this request based on public_identifier and current_user.
  def find_link
    public_identifier = params.permit(:link_public_identifier)[:link_public_identifier]
    @link = Link.find_by!(public_identifier: public_identifier, user_id: current_user.id)
  end

  # Validate the incoming query param timestamps.  Return false if either one is present but invaild.
  def timestamps_valid?
    @start_time = parse_timestamp(params.permit(:start_time)[:start_time])
    @end_time = parse_timestamp(params.permit(:end_time)[:end_time])

    @start_time.present? && @end_time.present?
  end

  # Parse and return the provided timestmap string.  Or, if the string is blank, return current timestamp.
  def parse_timestamp(timestamp)
    timestamp.blank? ? Time.zone.now : Time.zone.parse(timestamp).try(:utc)
  end

end
