require "rails_helper"

RSpec.describe "Links API", :type => :request do

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

  describe("GET /links") do
    let(:path) { "/api/v1/links" }
    let!(:link1) { create(:link, user: user) }
    let!(:link2) { create(:link, user: user) }

    it("returns a collection of links") do
      get(path, headers: req_headers)
      expect(response).to have_http_status(200)
      body = MultiJson.load(response.body)
      expect(body.length).to eq(2)
      expect(body.first["destination_url"]).to eq(link1.destination_url)
      expect(body.first["public_identifier"]).to eq(link1.public_identifier)
      expect(body.first["redirect_url"]).to match(link1.public_identifier)
      expect(body.second["destination_url"]).to eq(link2.destination_url)
      expect(body.second["public_identifier"]).to eq(link2.public_identifier)
      expect(body.second["redirect_url"]).to match(link2.public_identifier)
    end

    it("returns 401 if the basic auth credentials are missing") do
      get(path, headers: content_headers)
      expect(response).to have_http_status(401)
      expect(MultiJson.load(response.body)).to eq({ "error" => "You need to sign in or sign up before continuing." })
    end

    it("returns 401 if the basic auth credentials are invalid") do
      get(path, headers: content_headers.merge(create_auth_header("foobar", "password")))
      expect(response).to have_http_status(401)
      expect(MultiJson.load(response.body)).to eq({ "error" => "Invalid Email or password." })
    end

  end

  describe("POST /links") do
    let(:path) { "/api/v1/links" }
    let(:destination_url) { "http://foobar.com" }
    let(:invalid_destination_url) { "foobar" }

    it("creates and returns a link with correct parameters") do
      post(path, params: { destination_url: destination_url }.to_json, headers: req_headers)
      expect(response).to have_http_status(200)
      body = MultiJson.load(response.body)
      expect(body["destination_url"]).to eq(destination_url)
      expect(body["public_identifier"]).to be_present
      expect(body["redirect_url"]).to be_present
    end

    it("fails to create link and returns error when destination_url is invalid") do
      post(path, params: { destination_url: invalid_destination_url }.to_json, headers: req_headers)
      expect(response).to have_http_status(400)
      expect(MultiJson.load(response.body)).to eq({ "errors" => { "destination_url" => ["is missing http or https"] } })
    end

  end

end
