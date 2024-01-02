import boto3
from urllib.parse import urlparse

# Initialize a DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-west-2')

def lambda_handler(event, context):
    # Extract the request details
    request = event['Records'][0]['cf']['request']
    
    # Parse the hostname and path from the request URI
    hostname = request['headers']['host'][0]['value']
    path = request['uri']
    full_host_path = hostname + path

    # Specify the DynamoDB table
    table = dynamodb.Table('redirect-hosts')
    
    #try:
        # Query the DynamoDB table for the hostname and path
    response = table.get_item(
        Key={
            'hostname': full_host_path,
        }
    )
    
    # Check if a matching item was found
    if 'Item' in response:
        item = response['Item']
        redirect_hostname = item['redirect_hostname']
        redirect_http_code = int(item['redirect_http_code'])

        # Create a redirect response
        response = {
            'status': str(redirect_http_code),
            'statusDescription': 'Found',
            'headers': {
                'location': [{
                    'key': 'Location',
                    'value': 'https://' + redirect_hostname + path
                }]
            }
        }
        return response

    # except Exception as e:
    #     print(f"Error querying DynamoDB: {e}")

    # Return the original request if no redirect is necessary
    return request