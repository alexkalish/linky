require 'rails_helper'

RSpec.describe Link, type: :model do

  describe("factories") do
    it('builds a valid link') do
      expect(build(:link)).to be_valid
    end

    it('successfully creates and saves a link') do
      expect(create(:link)).not_to be_new_record
    end
  end

  describe("validations") do

    it { is_expected.to validate_presence_of(:destination_url) }

    describe("uniquness") do
      subject { create(:link) }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:destination_url) }
    end

    describe("#destination_is_a_valid_url") do

      ["http://foobar.com", "https://foobar.com/path/to/somewhere"].each do |url|
        it("is true when destination_url equals #{url}") do
          expect(build(:link, destination_url: url)).to be_valid
        end
      end

      ["foobar.com", "foobar", "ftp://foobar.com"].each do |url|
        it("is false when destination_url equals #{url}") do
          expect(build(:link, destination_url: url)).to_not be_valid
        end
      end

    end

  end

  describe("associations") do
    it { is_expected.to belong_to(:user) }
  end

  describe("#generate_public_identifier") do

    it("generates an identifier on create") do
      link = build(:link)
      expect(link.public_identifier).to be_nil
      link.save!
      expect(link.public_identifier).to be_present
    end

    it("does not modify an existing public_identifier on save") do
      link = create(:link)
      public_identifier = link.public_identifier
      link.user = create(:user)
      link.save!
      expect(link.public_identifier).to eq(public_identifier)
    end

    it("doesn't modify a provided public_identifier on create") do
      link = build(:link)
      link.public_identifier = "foobar"
      link.save!
      expect(link.public_identifier).to eq("foobar")
    end

  end

end
