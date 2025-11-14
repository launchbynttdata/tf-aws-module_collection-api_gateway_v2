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

module "api_gateway" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/api_gateway_v2/aws"
  version = "~> 1.0"

  name = var.name

  tags = local.tags
}

module "api_gateway_route" {
  source   = "terraform.registry.launch.nttdata.com/module_primitive/api_gateway_v2_route/aws"
  version  = "~> 1.0"
  for_each = local.transformed_routes

  api_id    = module.api_gateway.api_gateway_id
  route_key = each.value.route_key
  target    = each.value.target
}

module "api_gateway_integration" {
  source   = "terraform.registry.launch.nttdata.com/module_primitive/api_gateway_v2_integration/aws"
  version  = "~> 1.0"
  for_each = var.integrations

  api_id = module.api_gateway.api_gateway_id

  integration_type              = each.value.integration_type
  connection_id                 = each.value.connection_id
  connection_type               = each.value.connection_type
  content_handling_strategy     = each.value.content_handling_strategy
  credentials_arn               = each.value.credentials_arn
  description                   = each.value.description
  integration_method            = each.value.integration_method
  integration_subtype           = each.value.integration_subtype
  integration_uri               = each.value.integration_uri
  passthrough_behavior          = each.value.passthrough_behavior
  payload_format_version        = each.value.payload_format_version
  request_parameters            = each.value.request_parameters
  request_templates             = each.value.request_templates
  response_parameters           = each.value.response_parameters
  template_selection_expression = each.value.template_selection_expression
  timeout_milliseconds          = each.value.timeout_milliseconds
  server_name_to_verify         = each.value.server_name_to_verify
}

module "api_gateway_stage" {
  source   = "terraform.registry.launch.nttdata.com/module_collection/api_gateway_v2_stage/aws"
  version  = "~> 1.0"
  for_each = var.stages

  api_id = module.api_gateway.api_gateway_id

  name                     = each.value.name
  description              = each.value.description
  deployment_id            = each.value.deployment_id
  auto_deploy              = each.value.auto_deploy
  log_group_arn            = each.value.log_group_arn
  log_group_retention_days = each.value.log_group_retention_days
  log_group_skip_destroy   = each.value.log_group_skip_destroy
  access_log_format        = each.value.access_log_format

  tags = local.tags
}
