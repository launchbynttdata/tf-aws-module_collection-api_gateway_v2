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

variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "routes" {
  description = "Map of routes to create in the API Gateway."
  type = map(object({
    route_key = string
    target    = string
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
    access_log_format        = optional(string, null)
  }))
}

variable "tags" {
  description = "Map of tags to assign to the API."
  type        = map(string)
  default     = null
}
