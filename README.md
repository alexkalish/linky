# Linky

Linky is a link shortening web application written in Ruby on Rails.  Users interact with the app via a RESTFful HTTP API.  The app provides an [Open API Specification](https://github.com/OAI/OpenAPI-Specification) that describes the API, allowing users to easily send requests via the included Swagger UI, the native [Postman app](https://www.getpostman.com/) or [generate their own API client](https://swagger.io/tools/swagger-codegen/).

## Containerized Development (Recommended)

### Requirements

* [Docker](https://www.docker.com/products/docker-desktop)

### Setup

1. Clone this repo from Github and `cd` into it.
2. `docker-compose up -d` 
3. `docker-compose --rm web bin/rails db:setup`

### Usage

When the Rails container is launched via `docker-compose`, the app is automatically started and exposed on port `3000`.

## Local Development

### Requirements

* [Ruby](https://www.ruby-lang.org/en/) v2.6.1
* [Bundler](https://bundler.io/)
* [Postgres](https://www.postgresql.org/) v11 (earlier versions not supported)

### Setup

1. Clone this repo from Github and `cd` into it.
2. `bundle install`
3. `bin/rails db:setup`

### Usage

#### Running the App

Just execute `bin/rails server` to start the application at `http://localhost:300`.  The root URL is set as a redirect to the Swagger UI loaded with the app's Open API Specification.  The spec document itself can be viewed directly via `/open_api/spec.json` path.

#### Running the Tests

Just execute `bin/rspec `.
