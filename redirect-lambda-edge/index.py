import boto3
import json

CONFIG_FILE_PATH = 'config.json'

def load_config():
    """Load configuration from the JSON file."""
    with open(CONFIG_FILE_PATH, 'r') as config_file:
        return json.load(config_file)

def initialize_dynamodb(table_name, table_region):
    """Initialize DynamoDB resource."""
    dynamodb = boto3.resource('dynamodb', region_name=table_region)
    return dynamodb.Table(table_name)

def get_redirect_response(table, hostname, path):
    """Get redirect response from DynamoDB table."""
    try:
        response = table.get_item(Key={'hostname': hostname, 'hostname_path': path})
        item = response.get('Item')
        if item:
            return {
                'status': str(item['redirect_http_code']),
                'statusDescription': 'Found',
                'headers': {
                    'location': [{
                        'key': 'Location',
                        'value': 'https://' + item['redirect_host'] + item['redirect_path']
                    }]
                }
            }
    except Exception as e:
        print(f"Error querying DynamoDB: {e}")

def lambda_handler(event, context):
    """AWS Lambda handler function."""
    request = event['Records'][0]['cf']['request']
    hostname, path = request['headers']['host'][0]['value'], request['uri']
    
    config = load_config()
    table = initialize_dynamodb(config['dynamodb_table'], config['dynamodb_region'])
    
    redirect_response = get_redirect_response(table, hostname, path)
    if redirect_response:
        return redirect_response
    
    # Fallback to base origin if no redirect is found
    return {
        'status': '302',
        'statusDescription': 'Found',
        'headers': {
            'location': [{
                'key': 'Location',
                'value': f'https://{config["origin_domain"]}'
            }]
        }
    }
