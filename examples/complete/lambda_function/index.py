"""Simple Lambda Handler to test API Gateway Functionality"""

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from Lambda!"
    }
