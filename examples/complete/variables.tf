// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
  }))

  default = {
    api_gateway = {
      name       = "apigw"
      max_length = 80
    }
    api_gateway_stage = {
      name       = "stage"
      max_length = 80
    }
    example_function = {
      name       = "fn"
      max_length = 80
    }
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "Instance number should be between 0 to 999."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "Instance number should be between 0 to 100."
  }
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "apigw"
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example. dev, qa, uat"
  nullable    = false
  default     = "demo"

  validation {
    condition     = length(regexall("\\b \\b", var.class_env)) == 0
    error_message = "Spaces between the words are not allowed."
  }
}

variable "lambda_function" {
  description = "Object mapping an alias to Lambda Function variables"
  type = map(object({
    create         = optional(bool, true)
    create_package = optional(bool, true)
    source_path    = string
    runtime        = optional(string, "python3.11")
    handler        = optional(string, "index.lambda_handler")
  }))
}



variable "routes" {
  description = "Map of routes to create in the API Gateway."
  type = map(object({
    route_key = string
    target    = optional(string, null)
  }))
}

variable "integrations" {
  description = "Map of integrations to create in the API Gateway."
  type = map(object({
    integration_type          = string
    connection_id             = optional(string, null)
    connection_type           = optional(string, null)
    content_handling_strategy = optional(string, null)
    credentials_arn           = optional(string, null)
    description               = optional(string, null)
    integration_method        = optional(string, null)
    integration_subtype       = optional(string, null)
    integration_uri           = optional(string, null)
    passthrough_behavior      = optional(string, "WHEN_NO_MATCH")
    payload_format_version    = optional(string, "2.0")
    request_parameters        = optional(map(string), {})
    request_templates         = optional(map(string), {})
    response_parameters = optional(list(object({
      status_code = number
      mappings    = map(string)
    })), [])
    template_selection_expression = optional(string, null)
    timeout_milliseconds          = optional(number, null)
    server_name_to_verify         = optional(string, null)
  }))
}

variable "stages" {
  description = "Map of stages to create in the API Gateway"
  type = map(object({
    name                     = optional(string, null)
    description              = optional(string, null)
    deployment_id            = optional(string, null)
    auto_deploy              = optional(bool, null)
    log_group_arn            = optional(string, null)
    log_group_retention_days = optional(number, 30)
    log_group_skip_destroy   = optional(bool, false)
    access_log_format        = optional(string, "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }")
  }))
}

variable "tags" {
  description = "Map of tags to assign to the API."
  type        = map(string)
  default     = null
}
