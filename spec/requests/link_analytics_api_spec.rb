require "rails_helper"

RSpec.describe "Link Analytics API", :type => :request do

  # TODO: Move these header helpers into a shared module, as they are used elsewhere as well.

  def create_auth_header(username, password)
    { "Authorization": ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end
  
  let(:password) { "password" }
  let(:user) { create(:user, password: password) }
  let(:content_headers) do
    {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  end

  let(:req_headers) do
    content_headers.merge(create_auth_header(user.email, password))
  end

  let(:referrer) { "http://google.com" }
  let!(:link) { create(:link, user: user) }
  let!(:now) { Time.zone.now }

  describe("GET /links/:public_identifier/analytics") do

    def generate_path(public_identifier)
      "/api/v1/links/#{public_identifier}/analytics"
    end

    it("returns 404 for an unknown link") do
      # Rails converts this exception to 404 in production.
      expect { get(generate_path("foobar"), headers: req_headers) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it("without any redirects returns an empty array") do
      get(generate_path(link.public_identifier), headers: req_headers)
      expect(response.status).to eq(200)
      expect(MultiJson.load(response.body)).to eq([])
    end

    it("defaults start and end query parameters to the current time and date") do
      LinkRedirect.insert(link, referrer: referrer)
      LinkRedirect.insert(link, occurred_at: now - 2.days)
      get(generate_path(link.public_identifier), headers: req_headers)
      body = MultiJson.load(response.body)
      expect(response.status).to eq(200)
      expect(body.first["redirects"]).to eq(1)
      expect(body.first["referrer"]).to eq(referrer)
    end

    it("honors provided start and end query parameters when aggregating redirects") do
      past = now - 2.days
      LinkRedirect.insert(link)
      LinkRedirect.insert(link, occurred_at: past, referrer: referrer)
      get("#{generate_path(link.public_identifier)}?start_time=#{past.iso8601}&end_time=#{past.iso8601}", headers: req_headers)
      body = MultiJson.load(response.body)
      expect(response.status).to eq(200)
      expect(body.first["redirects"]).to eq(1)
      expect(body.first["referrer"]).to eq(referrer)
    end

    it("returns an error message and 400 status when query param timestmap is invalid") do
      get("#{generate_path(link.public_identifier)}?start_time=foobar", headers: req_headers)
      body = MultiJson.load(response.body)
      expect(response.status).to eq(400)
      expect(body["errors"].first).to match(/invalid/i) 
    end

  end

end
