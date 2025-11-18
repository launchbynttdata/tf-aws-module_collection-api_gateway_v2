# tf-aws-module_collection-api_gateway_v2

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

Provides a full API Gateway collection, comprised of:

- An API Gateway
- One or more Stages
- One or more Routes
- One or more Integrations

Routes and Integrations use a common identifier (referred to internally as an `alias`) to allow for routes to be tied to an integration dynamically.

Passing a Route without a `target` attribute will pull the `api_gateway_integration_id` out of the Integration with a matching `alias` and apply it to the route. Consider the following inputs:

```hcl
routes = {
  one = {
    route_key = "GET /route_one"
  },
  two = {
    route_key = "GET /route_two"
  }
  ...
}

integrations = {
  one = {
    integration_type = "HTTP_PROXY"
    integration_uri = "https://some-other-service.example.com/v1/proxied_route_one"
  },
  two = {
    integration_type = "AWS_PROXY"
    integration_uri = "<AWS Lambda Function ARN>
  }
  ...
}
```

This module will create `route[one].target` and `route[two].target` values that will be fed into the Route after the matching Integration is created. The expected outcome is that accessing /route_one on the API Gateway results in your traffic being proxied to some-other-service.example.com, and accessing /route_two will call a Lambda function.

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. _THIS STEP APPLIES ONLY TO MICROSOFT AZURE. IF YOU ARE USING A DIFFERENT PLATFORM PLEASE SKIP THIS STEP._ The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `azure_env.sh` file on local workstation. Devloper would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Service principle used for authentication(value of ARM_CLIENT_ID) should have below privileges on resource group within the subscription.

```
"Microsoft.Resources/subscriptions/resourceGroups/write"
"Microsoft.Resources/subscriptions/resourceGroups/read"
"Microsoft.Resources/subscriptions/resourceGroups/delete"
```

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `azure` specific. If primitive/segment under development uses any other cloud provider than azure, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "azurerm" {
  features {}
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform.registry.launch.nttdata.com/module_primitive/api_gateway_v2/aws | ~> 1.0 |
| <a name="module_api_gateway_route"></a> [api\_gateway\_route](#module\_api\_gateway\_route) | terraform.registry.launch.nttdata.com/module_primitive/api_gateway_v2_route/aws | ~> 1.0 |
| <a name="module_api_gateway_integration"></a> [api\_gateway\_integration](#module\_api\_gateway\_integration) | terraform.registry.launch.nttdata.com/module_primitive/api_gateway_v2_integration/aws | ~> 1.0 |
| <a name="module_api_gateway_stage"></a> [api\_gateway\_stage](#module\_api\_gateway\_stage) | terraform.registry.launch.nttdata.com/module_collection/api_gateway_v2_stage/aws | ~> 1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the API Gateway | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | Map of routes to create in the API Gateway. | <pre>map(object({<br/>    route_key = string<br/>    target    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | Map of integrations to create in the API Gateway. | <pre>map(object({<br/>    integration_type          = string<br/>    connection_id             = optional(string, null)<br/>    connection_type           = optional(string, null)<br/>    content_handling_strategy = optional(string, null)<br/>    credentials_arn           = optional(string, null)<br/>    description               = optional(string, null)<br/>    integration_method        = optional(string, null)<br/>    integration_subtype       = optional(string, null)<br/>    integration_uri           = optional(string, null)<br/>    passthrough_behavior      = optional(string, "WHEN_NO_MATCH")<br/>    payload_format_version    = optional(string, "2.0")<br/>    request_parameters        = optional(map(string), {})<br/>    request_templates         = optional(map(string), {})<br/>    response_parameters = optional(list(object({<br/>      status_code = number<br/>      mappings    = map(string)<br/>    })), [])<br/>    template_selection_expression = optional(string, null)<br/>    timeout_milliseconds          = optional(number, null)<br/>    server_name_to_verify         = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_stages"></a> [stages](#input\_stages) | Map of stages to create in the API Gateway | <pre>map(object({<br/>    name                     = optional(string, null)<br/>    description              = optional(string, null)<br/>    deployment_id            = optional(string, null)<br/>    auto_deploy              = optional(bool, null)<br/>    log_group_arn            = optional(string, null)<br/>    log_group_retention_days = optional(number, 30)<br/>    log_group_skip_destroy   = optional(bool, false)<br/>    access_log_format        = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the API. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_id"></a> [api\_gateway\_id](#output\_api\_gateway\_id) | n/a |
| <a name="output_api_gateway_endpoint"></a> [api\_gateway\_endpoint](#output\_api\_gateway\_endpoint) | n/a |
| <a name="output_api_gateway_routes"></a> [api\_gateway\_routes](#output\_api\_gateway\_routes) | n/a |
| <a name="output_api_gateway_integrations"></a> [api\_gateway\_integrations](#output\_api\_gateway\_integrations) | n/a |
| <a name="output_api_gateway_stages"></a> [api\_gateway\_stages](#output\_api\_gateway\_stages) | n/a |
<!-- END_TF_DOCS -->
