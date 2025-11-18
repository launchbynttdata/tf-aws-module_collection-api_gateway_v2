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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "lambda_function" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/lambda_function/aws"
  version = "~> 1.0"

  for_each = var.lambda_function

  name = module.resource_names[each.key].minimal_random_suffix

  create         = each.value.create
  create_package = each.value.create_package
  source_path    = each.value.source_path
  runtime        = each.value.runtime
  handler        = each.value.handler

  create_lambda_function_url = false

  tags = var.tags
}

resource "aws_lambda_permission" "allow_apigw_invoke" {
  for_each = module.lambda_function

  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region_name}:${local.account_id}:${module.api_gateway_v2.api_gateway_id}/*/*/{proxy+}"
}

module "api_gateway_v2" {
  source = "../.."

  name = module.resource_names["api_gateway"].minimal_random_suffix

  routes       = var.routes
  integrations = local.transformed_integrations
  stages       = var.stages

  tags = local.tags
}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", local.region_name))
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
}
