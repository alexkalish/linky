require 'rails_helper'

RSpec.describe User, type: :model do

  describe('factories') do
    it('builds a valid user') do
      expect(build(:user)).to be_valid
    end

    it('successfully creates and saves a user') do
      expect(create(:user)).not_to be_new_record
    end
  end

  describe("validations") do
    it { is_expected.to validate_presence_of(:email) }
    describe("uniqueness") do
      subject { create(:user) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end
    it { is_expected.to validate_presence_of(:password) }
  end

  describe("associations") do
    it { is_expected.to have_many(:links) }
  end

  describe("#create_link") do
    let(:user) { create(:user) }
    let(:valid_destination_url) { "http://google.com" }
    let(:invalid_destination_url) { "google" }
    let!(:new_public_identifier) { SecureRandom.base58(8).upcase }

    it("successfully creates a link with a valid destination_url") do
      link = user.create_link(destination_url: valid_destination_url)
      expect(link).to be_persisted
      expect(link).to be_valid
      expect(link.destination_url).to eq(valid_destination_url)
    end

    it("does not create a link with a invalid destination_url") do
      link = user.create_link(destination_url: invalid_destination_url)
      expect(link).to_not be_persisted
      expect(link).to_not be_valid
      expect(link.errors).to be_present
    end

    it("does create a link after a single public_identifier collision") do
      existing_link = create(:link)
      existing_public_identifier = existing_link.public_identifier
      allow(SecureRandom).to receive(:base58).and_return(existing_public_identifier, new_public_identifier)
      new_link = user.create_link(destination_url: valid_destination_url)
      expect(new_link).to be_persisted
      expect(new_link.public_identifier).to eq(new_public_identifier)
    end

    it("doesn't create a link and returns nil after max public_identifier collisions") do
      existing_link = create(:link)
      existing_public_identifier = existing_link.public_identifier
      allow(SecureRandom).to receive(:base58).and_return(existing_public_identifier)
      new_link = user.create_link(destination_url: valid_destination_url)
      expect(new_link.errors).to_not be_nil
      expect(new_link).to_not be_valid
    end

  end

end
