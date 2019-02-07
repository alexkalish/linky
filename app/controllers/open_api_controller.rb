class OpenApiController < ApplicationController

  # Generate the OAS doc.
  def spec
  end

  # Redirect to the Swagger UI, pointed to the OAS doc.
  def ui
    redirect_to "/vendor/dist/index.html?url=#{open_api_spec_path}"
  end

end
