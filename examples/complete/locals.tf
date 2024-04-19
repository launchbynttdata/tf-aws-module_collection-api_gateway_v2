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

locals {
  default_tags = {
    provisioner = "Terraform"
  }

  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name

  transformed_integrations = {
    for alias, integration in var.integrations :
    alias => merge({
      integration_uri = try(module.lambda_function[alias].lambda_function_arn, null)
      }, {
      for integration_key, integration_value in integration :
      integration_key => integration_value if integration_value != null
    })
  }

  tags = merge(local.default_tags, var.tags)
}
