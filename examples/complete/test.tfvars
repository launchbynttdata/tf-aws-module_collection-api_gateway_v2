routes = {
  example_function = {
    route_key = "GET /lambda/{proxy+}"
  },
  http = {
    route_key = "GET /http/{proxy+}"
  }
}

stages = {
  default = {
    name        = "$default"
    auto_deploy = true
  }
}

integrations = {
  example_function = {
    integration_type       = "AWS_PROXY"
    connection_type        = "INTERNET"
    description            = "Lambda function example"
    integration_method     = "POST"
    payload_format_version = "2.0"
  },
  http = {
    integration_type       = "HTTP_PROXY"
    connection_type        = "INTERNET"
    description            = "HTTP proxying example"
    integration_method     = "GET"
    integration_uri        = "https://example.com"
    payload_format_version = "1.0"
  }
}

lambda_function = {
  example_function = {
    source_path = "lambda_function"
  }
}
