# complete

Provides a full API Gateway setup consisting of:

- API Gateway
- Default Stage
- Route
- Integration
- Lambda Function configured as an Integration to respond on the Route

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform.registry.launch.nttdata.com/module_primitive/lambda_function/aws | ~> 1.0 |
| <a name="module_api_gateway_v2"></a> [api\_gateway\_v2](#module\_api\_gateway\_v2) | ../.. | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_permission.allow_apigw_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br/>    name       = string<br/>    max_length = optional(number, 60)<br/>  }))</pre> | <pre>{<br/>  "api_gateway": {<br/>    "max_length": 80,<br/>    "name": "apigw"<br/>  },<br/>  "api_gateway_stage": {<br/>    "max_length": 80,<br/>    "name": "stage"<br/>  },<br/>  "example_function": {<br/>    "max_length": 80,<br/>    "name": "fn"<br/>  }<br/>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br/>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br/>    For example, backend, frontend, middleware etc. | `string` | `"apigw"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example. dev, qa, uat | `string` | `"demo"` | no |
| <a name="input_lambda_function"></a> [lambda\_function](#input\_lambda\_function) | Object mapping an alias to Lambda Function variables | <pre>map(object({<br/>    create         = optional(bool, true)<br/>    create_package = optional(bool, true)<br/>    source_path    = string<br/>    runtime        = optional(string, "python3.11")<br/>    handler        = optional(string, "index.lambda_handler")<br/>  }))</pre> | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of routes to create in the API Gateway. | <pre>map(object({<br/>    route_key = string<br/>    target    = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | Map of integrations to create in the API Gateway. | <pre>map(object({<br/>    integration_type          = string<br/>    connection_id             = optional(string, null)<br/>    connection_type           = optional(string, null)<br/>    content_handling_strategy = optional(string, null)<br/>    credentials_arn           = optional(string, null)<br/>    description               = optional(string, null)<br/>    integration_method        = optional(string, null)<br/>    integration_subtype       = optional(string, null)<br/>    integration_uri           = optional(string, null)<br/>    passthrough_behavior      = optional(string, "WHEN_NO_MATCH")<br/>    payload_format_version    = optional(string, "2.0")<br/>    request_parameters        = optional(map(string), {})<br/>    request_templates         = optional(map(string), {})<br/>    response_parameters = optional(list(object({<br/>      status_code = number<br/>      mappings    = map(string)<br/>    })), [])<br/>    template_selection_expression = optional(string, null)<br/>    timeout_milliseconds          = optional(number, null)<br/>    server_name_to_verify         = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_stages"></a> [stages](#input\_stages) | Map of stages to create in the API Gateway | <pre>map(object({<br/>    name                     = optional(string, null)<br/>    description              = optional(string, null)<br/>    deployment_id            = optional(string, null)<br/>    auto_deploy              = optional(bool, null)<br/>    log_group_arn            = optional(string, null)<br/>    log_group_retention_days = optional(number, 30)<br/>    log_group_skip_destroy   = optional(bool, false)<br/>    access_log_format        = optional(string, "{ \"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }")<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the API. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_id"></a> [api\_gateway\_id](#output\_api\_gateway\_id) | n/a |
| <a name="output_api_gateway_endpoint"></a> [api\_gateway\_endpoint](#output\_api\_gateway\_endpoint) | n/a |
| <a name="output_api_gateway_integrations"></a> [api\_gateway\_integrations](#output\_api\_gateway\_integrations) | n/a |
| <a name="output_api_gateway_stages"></a> [api\_gateway\_stages](#output\_api\_gateway\_stages) | n/a |
| <a name="output_api_gateway_routes"></a> [api\_gateway\_routes](#output\_api\_gateway\_routes) | n/a |
<!-- END_TF_DOCS -->
