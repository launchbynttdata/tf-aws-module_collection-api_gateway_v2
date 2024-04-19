package testimpl

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/apigatewayv2"
	apitypes "github.com/aws/aws-sdk-go-v2/service/apigatewayv2/types"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go/aws/arn"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	apiGatewayClient := GetAWSApiGatewayV2Client(t)
	apiGatewayId := terraform.Output(t, ctx.TerratestTerraformOptions(), "api_gateway_id")
	apiGatewayUrl := terraform.Output(t, ctx.TerratestTerraformOptions(), "api_gateway_endpoint")

	stages := terraform.OutputMapOfObjects(t, ctx.TerratestTerraformOptions(), "api_gateway_stages")
	routes := terraform.OutputMapOfObjects(t, ctx.TerratestTerraformOptions(), "api_gateway_routes")
	integrations := terraform.OutputMapOfObjects(t, ctx.TerratestTerraformOptions(), "api_gateway_integrations")

	fmt.Printf("\n\nSTAGES: %v\n\n", stages)
	fmt.Printf("\n\nROUTES: %v\n\n", routes)
	fmt.Printf("\n\nINTEGRATIONS: %v\n\n", integrations)

	t.Run("TestApiGatewayV2Exists", func(t *testing.T) {
		apiGateway, err := apiGatewayClient.GetApi(context.TODO(), &apigatewayv2.GetApiInput{
			ApiId: &apiGatewayId,
		})
		if err != nil {
			t.Errorf("Failure during GetApi: %v", err)
		}

		assert.Equal(t, *apiGateway.ApiId, apiGatewayId, "Expected ID did not match actual ID!")
		assert.Equal(t, apiGateway.ProtocolType, apitypes.ProtocolTypeHttp, "Expected protocol type did not match actual!")
	})

	t.Run("TestApiGatewayV2StageExists", func(t *testing.T) {
		var stageName string

		for _, stageObject := range stages {
			for key, value := range stageObject.(map[string]interface{}) {
				if key == "api_gateway_stage_name" {
					stageName = value.(string)
				}
			}
			apiGatewayStage, err := apiGatewayClient.GetStage(context.TODO(), &apigatewayv2.GetStageInput{
				ApiId:     &apiGatewayId,
				StageName: &stageName,
			})
			if err != nil {
				t.Errorf("Failure during GetApi: %v", err)
			}
			assert.Equal(t, *apiGatewayStage.StageName, stageName, "Expected Stage Name did not match actual Stage Name!")
		}
	})

	t.Run("TestApiGatewayV2RouteExists", func(t *testing.T) {
		var routeId string

		for _, routeObject := range routes {
			for key, value := range routeObject.(map[string]interface{}) {
				if key == "api_gateway_route_id" {
					routeId = value.(string)
				}
			}

			apiGatewayRoute, err := apiGatewayClient.GetRoute(context.TODO(), &apigatewayv2.GetRouteInput{
				ApiId:   &apiGatewayId,
				RouteId: &routeId,
			})
			if err != nil {
				t.Errorf("Failure during GetApi: %v", err)
			}
			assert.Equal(t, *apiGatewayRoute.RouteId, routeId, "Expected Route ID did not match actual Route ID!")
		}
	})

	t.Run("TestApiGatewayV2IntegrationExists", func(t *testing.T) {
		var integrationId string

		for _, integrationObject := range integrations {
			for key, value := range integrationObject.(map[string]interface{}) {
				if key == "api_gateway_integration_id" {
					integrationId = value.(string)
				}
			}

			apiGatewayIntegration, err := apiGatewayClient.GetIntegration(context.TODO(), &apigatewayv2.GetIntegrationInput{
				ApiId:         &apiGatewayId,
				IntegrationId: &integrationId,
			})
			if err != nil {
				t.Errorf("Failure during GetApi: %v", err)
			}
			assert.Equal(t, *apiGatewayIntegration.IntegrationId, integrationId, "Expected Integration ID did not match actual Integration ID!")
		}
	})

	t.Run("TestCloudWatchLogGroupWasCreated", func(t *testing.T) {
		cloudwatchClient := GetAWSCloudwatchClient(t)

		var logGroupArn string
		var logGroupCreated bool

		for _, stageObject := range stages {
			for key, value := range stageObject.(map[string]interface{}) {
				if key == "log_group_arn" {
					logGroupArn = value.(string)
				}
				if key == "log_group_created" {
					if value, ok := value.(bool); ok {
						logGroupCreated = value
					}
				}
			}

			assert.True(t, logGroupCreated, "Log group should have been created!")

			arn, err := arn.Parse(logGroupArn)
			if err != nil {
				t.Errorf("Failure during parsing Log Group ARN: %v", err)
			}

			namePrefix := strings.Replace(arn.Resource, "log-group:", "", 1)

			logGroups, err := cloudwatchClient.DescribeLogGroups(context.TODO(), &cloudwatchlogs.DescribeLogGroupsInput{
				LogGroupNamePrefix: &namePrefix,
			})
			if err != nil {
				t.Errorf("Failure during GetApi: %v", err)
			}

			assert.Equal(t, len(logGroups.LogGroups), 1, "Expected one matching log group!")
		}
	})

	t.Run("TestLambdaResponseFromApiGateway", func(t *testing.T) {
		resp, err := http.Get(apiGatewayUrl + "/lambda/")
		if err != nil {
			t.Errorf("Failure during HTTP GET: %v", err)
		}

		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Errorf("Failure reading Body: %v", err)
		}

		assert.Equal(t, string(body), "Hello from Lambda!", "Body did not contain expected response!")
	})

	t.Run("TestProxyResponseFromApiGateway", func(t *testing.T) {
		resp, err := http.Get(apiGatewayUrl + "/http/")
		if err != nil {
			t.Errorf("Failure during HTTP GET: %v", err)
		}

		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			t.Errorf("Failure reading Body: %v", err)
		}

		assert.Contains(t, string(body), "Example Domain", "Body did not contain expected response!")
	})
}

func GetAWSCloudwatchClient(t *testing.T) *cloudwatchlogs.Client {
	awsCloudwatchClient := cloudwatchlogs.NewFromConfig(GetAWSConfig(t))
	return awsCloudwatchClient
}

func GetAWSApiGatewayV2Client(t *testing.T) *apigatewayv2.Client {
	awsApiGatewayV2Client := apigatewayv2.NewFromConfig(GetAWSConfig(t))
	return awsApiGatewayV2Client
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
