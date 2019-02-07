json.openapi "3.0.2"

json.info do
  json.title "Linky URL Shortener"
  json.description <<-DESC
  Welcome to Linky!  This is a RESTful HTTP API driven web service that provides the simple ability to shorten URLs into more easily sharable links.  In order to start shortening URLs, you must first create account.

  There are three easy ways to use Linky:
  1. Use the Swagger UI (can be found [here](#{root_url}), if you aren't looking at it already). 
  2. Use the wonderful [Postman app](https://www.getpostman.com/) by importing this Open API Spec as a new collection. Directions found [here](https://learning.getpostman.com/docs/postman/collections/data_formats/#importing-swagger).
  3. Send requests using the HTTP client of your choice!
  DESC
  json.version "1.0.0"
end

json.servers do
  json.child! do
    json.url root_url
    json.description "Local development server"
  end
end

json.components do

  json.schemas do
    json.user do
      json.type "object"
      json.required ["email"]
      json.properties do
        json.email { json.type "string" }
      end
    end
    json.link do
      json.type "object"
      json.required ["destination_url", "redirect_url", "public_identifier"]
      json.properties do
        json.destination_url { json.type "string" }
        json.public_identifier { json.type "string" }
        json.redirect_url { json.type "string" }
      end
    end
    json.link_analytics do
      json.type "object"
      json.required ["redirects", "occurred_on"]
      json.properties do
        json.redirects { json.type "integer" }
        json.occurred_on { json.type "string" }
        json.referrer { json.type "string" }
      end
    end
  end

  json.securitySchemes do
    json.basic_auth do
      json.type "http"
      json.scheme "basic"
    end
  end

end

json.security do
  json.child! do
    json.basic_auth []
  end
end

json.paths do

  json.set! "/api/v1/users" do

    json.post do
      json.tags ["Users"]
      json.summary "Create a new user"
      json.security []
      json.requestBody do
        json.required true
        json.content do
          json.set! "application/json" do
            json.schema do
              json.type "object"
              json.required ["email", "password"]
              json.properties do
                json.email { json.type "string" }
                json.password { json.type "string" }
              end
            end
          end
        end
      end
      json.responses do
        json.set! "200" do
          json.description "Successful response returns the new user"
          json.content do
            json.set! "application/json" do
              json.schema do
                json.set! "$ref", "#/components/schemas/user"
              end
            end
          end
        end
      end
    end

  end

  json.set! "/api/v1/links" do

    json.get do
      json.tags ["Links"]
      json.summary "List links"
      json.description "Return a list of links for the current user"
      json.responses do
        json.set! "200" do
          json.description "Successful response returns a list of links"
          json.content do
            json.set! "application/json" do
              json.schema do
                json.type "array"
                json.items do
                  json.set! "$ref", "#/components/schemas/link"
                end
              end
            end
          end
        end
      end
    end

    json.post do
      json.tags ["Links"]
      json.summary "Create a new link"
      json.description "Create and return a new link for the current user"
      json.requestBody do
        json.required true
        json.content do
          json.set! "application/json" do
            json.schema do
              json.type "object"
              json.required ["destination_url"]
              json.properties do
                json.destination_url { json.type "string" }
              end
            end
          end
        end
      end
      json.responses do
        json.set! "200" do
          json.description "Successful response returns the newly created link"
          json.content do
            json.set! "application/json" do
              json.schema do
                json.set! "$ref", "#/components/schemas/link"
              end
            end
          end
        end
      end
    end

  end

  json.set! "/api/v1/links/{public_identifier}/analytics" do
    json.get do
      json.tags ["Links"]
      json.summary "Get Link Analytics"
      json.description "Get current link usage for the optionally provided timeframe.  Currently, reports are always aggregated by day and referrer"
      json.parameters do
        json.child! do
          json.name "public_identifier"
          json.description "Analytics will be returned for this link public_identifier"
          json.in "path"
          json.required true
          json.schema { json.type "string" }
        end
        json.child! do
          json.name "start_time"
          json.description "Start time for returned analytics.  Defaults to current time."
          json.in "query"
          json.schema { json.type "string" }
        end
        json.child! do
          json.name "end_time"
          json.description "End time for returned analytics.  Defaults to current time."
          json.in "query"
          json.schema { json.type "string" }
        end
      end
      json.responses do
        json.set! "200" do
          json.description "Successful response returns array of usage objects"
          json.content do
            json.set! "application/json" do
              json.schema do
                json.type "array"
                json.items do
                  json.set! "$ref", "#/components/schemas/link_analytics"
                end
              end
            end
          end
        end
      end
    end
  end

end
