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
  source  = "d2lqlh14iel5k2.cloudfront.net/module_primitive/api_gateway_v2/aws"
  version = "~> 1.0"

  name = var.name

  tags = local.tags
}

module "api_gateway_route" {
  source   = "d2lqlh14iel5k2.cloudfront.net/module_primitive/api_gateway_v2_route/aws"
  version  = "~> 1.0"
  for_each = local.transformed_routes

  api_id    = module.api_gateway.api_gateway_id
  route_key = each.value.route_key
  target    = each.value.target
}

module "api_gateway_integration" {
  source   = "d2lqlh14iel5k2.cloudfront.net/module_primitive/api_gateway_v2_integration/aws"
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
  source   = "d2lqlh14iel5k2.cloudfront.net/module_collection/api_gateway_v2_stage/aws"
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

# resource "aws_apigatewayv2_api" "api_gateway" {
#   name          = module.resource_names["api_gateway"].standard
#   protocol_type = "HTTP"
#   tags          = local.tags
# }


# # Pass in a list of maps of integration variables?
# resource "aws_apigatewayv2_integration" "lambda_integration" {
#   api_id           = aws_apigatewayv2_api.api_gateway.id
#   integration_type = "AWS_PROXY"

#   connection_type        = "INTERNET"
#   description            = "Lambda function"
#   integration_method     = "POST"
#   integration_uri        = module.lambda_function.lambda_function_invoke_arn
#   payload_format_version = "2.0"
# }

# resource "aws_apigatewayv2_route" "lambda_route" {
#   api_id    = aws_apigatewayv2_api.api_gateway.id
#   route_key = "GET /{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
# }

# resource "aws_apigatewayv2_stage" "lambda_stage" {
#   api_id = aws_apigatewayv2_api.api_gateway.id
#   name   = "$default"

#   auto_deploy = true
#   tags        = local.tags

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.log_group.arn
#     format          = "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
#   }
# }


# # tf-aws-module-cloudwatch_log_group -> wrapper for cloudwatch_logs
# resource "aws_cloudwatch_log_group" "log_group" {
#   name              = module.resource_names["log_group"].standard
#   retention_in_days = 30
#   tags              = local.tags
#   skip_destroy      = false
# }

# ////////////////////////////////////////


# resource "aws_wafv2_web_acl" "waf_acl" {
#   provider = aws.global

#   name  = module.resource_names["waf_acl"].standard
#   scope = "CLOUDFRONT"


#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = module.resource_names["waf_acl"].standard
#     sampled_requests_enabled   = false
#   }

#   default_action {
#     allow {}
#   }

#   dynamic "rule" {
#     for_each = var.managed_waf_rules

#     content {
#       name     = rule.key
#       priority = rule.value.priority

#       statement {
#         managed_rule_group_statement {
#           name        = rule.key
#           vendor_name = rule.value.vendor_name
#         }
#       }

#       override_action {
#         none {}
#       }

#       visibility_config {
#         cloudwatch_metrics_enabled = rule.value.metrics_enabled
#         metric_name                = rule.value.metric_name == null ? rule.key : rule.value.metric_name
#         sampled_requests_enabled   = rule.value.sampled_requests_enabled
#       }
#     }
#   }
# }

# ///////////////////////////

# data "aws_cloudfront_cache_policy" "cache_policy_optimized" {
#   name = "Managed-CachingOptimized"
# }

# data "aws_cloudfront_origin_request_policy" "all_viewer" {
#   name = "Managed-AllViewerExceptHostHeader"
# }

# resource "aws_cloudfront_distribution" "apigw_distribution" {

#   enabled    = true
#   aliases    = var.aliases
#   web_acl_id = aws_wafv2_web_acl.waf_acl.arn

#   origin {
#     domain_name = replace(aws_apigatewayv2_api.api_gateway.api_endpoint, "https://", "")
#     origin_id   = module.resource_names["api_gateway"].standard
#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "https-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
#   }

#   default_cache_behavior {
#     cache_policy_id          = data.aws_cloudfront_cache_policy.cache_policy_optimized.id
#     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id

#     allowed_methods        = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id       = module.resource_names["api_gateway"].standard
#     cached_methods         = ["GET", "HEAD"]
#     compress               = true
#     min_ttl                = 0
#     default_ttl            = 60
#     max_ttl                = 604800
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#       locations        = []
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = var.acm_certificate_arn == null ? true : false
#     acm_certificate_arn            = var.acm_certificate_arn
#     ssl_support_method             = var.ssl_support_method
#     minimum_protocol_version       = var.minimum_protocol_version
#   }
# }
