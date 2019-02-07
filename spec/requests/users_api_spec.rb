require "rails_helper"

RSpec.describe "Users API", :type => :request do
  
  let(:req_headers) do
    {
      "Content-Type": "application/json",
      "Accept": "application/json"
    }
  end

  describe("POST /users") do
    let(:path) { "/api/v1/users" }
    let(:email) { "daffyduck@magickingdom.com" }
    let(:password) { "horse-feathers" }

    it("creates and returns a user with correct parameters") do
      post(path, params: { email: email, password: password }.to_json, headers: req_headers)
      expect(response).to have_http_status(200)
      expect(MultiJson.load(response.body)).to eq({ "email" => email })
    end

    it("fails to create user and returns error when password is not provided") do
      post(path, params: { email: email }.to_json, headers: req_headers)
      expect(response).to have_http_status(400)
      expect(MultiJson.load(response.body)).to eq({ "errors" => { "password" => ["can't be blank"] } })
    end

  end

end
