require "rails_helper"

RSpec.describe "Redirect Endpoint", :type => :request do

  let!(:link) { create(:link) }

  describe("GET /go/:public_identifier") do
    let(:base_path) { "/go" }

    it("redirects for a known link") do
      get("#{base_path}/#{link.public_identifier}")
      expect(response).to have_http_status(302)
    end

    it("returns 404 for an unknown link") do
      get("#{base_path}/foobar")
      expect(response).to have_http_status(404)
    end

  end

end
