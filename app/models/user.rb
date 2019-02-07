# A User supports authenticated API requests via the Devise gem.  Also, all Links are scoped to a specific User.
class User < ApplicationRecord

  MAX_PUBLIC_IDENTIFIER_RETRIES = 3
  PUBLIC_IDENTIFIER_GENERATION_ERROR = "internal server error"

  ### DEVISE ###

  # Include default devise modules. Others available are:
  # :recoverable, :rememberable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable, :registerable, :validatable

  ### ASSOCIATIONS ###

  has_many :links

  ### INSTANCE METHODS ###

  # Create a new link with the provided link parameters hash.
  #
  # NOTE: Unlike the builtin self.links.create method, this method
  # supports retrying if a non-unique public_identifier is generated, which
  # would trip the DB unique index.
  def create_link(link_params)
    link = nil
    retries = 0
    begin
      link = self.links.create(link_params)
    rescue ActiveRecord::RecordNotUnique
      retries += 1
      retry unless retries > MAX_PUBLIC_IDENTIFIER_RETRIES
      # Chances of reaching this point are very low, but just in case, return a duck-typed
      # link object with a vague error message.
      link = Hashie::Mash.new() do |m|
        m.errors = ActiveModel::Errors.new(self.links.build(link_params))
        m.errors.add(:base, PUBLIC_IDENTIFIER_GENERATION_ERROR)
        m.valid = false
        m.persisted = false
      end
    end

    link
  end

end
