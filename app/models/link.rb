# A Link represents a shortcut to a provided destination_url from an automatically generated
# source URL, identified by the public_identifier.
class Link < ApplicationRecord

  ### VALIDATIONS ###

  validates :destination_url, presence: true, uniqueness: true
  validates :user_id, uniqueness: { scope: :destination_url }

  validate :destination_is_a_valid_url

  ### ASSOCIATIONS ###
 
  belongs_to :user

  ### LIFECYCLE ###

  before_validation :generate_public_identifier, on: :create

  ### INSTANCE METHODS ###

  private

  # Generate an alpha numeric public identifier that is 8 chars long.
  #
  # NOTE: This does not provide for a graceful handling of non-unique values. Collisions will be caught
  # by the DB unique index, which will result in a RecordNotUnique exception. Could use a uniqueness validation,
  # but collisions should be rare and this avoids an extra query.
  def generate_public_identifier()
    self.public_identifier = SecureRandom.base58(8).upcase if public_identifier.blank?
  end

  # Ensure that the destination_url is a valid URL.
  def destination_is_a_valid_url
    if destination_url.present?
      begin
        url = URI.parse(destination_url)
      rescue
        errors.add(:destination_url, "is not valid")
        return
      end
      if !url.kind_of?(URI::HTTP) && !url.kind_of?(URI::HTTPS)
        errors.add(:destination_url, "is missing http or https")
      end
    end
  end

end
