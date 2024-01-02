import csv
import boto3
import codecs
from contextlib import closing

def lambda_handler(event, context):
    # Initialize a session using AWS SDK
    session = boto3.Session()
    # Create DynamoDB client
    dynamodb = session.client('dynamodb')

    # The S3 bucket and file details should be passed in the 'event' parameter
    # For example, event = {'bucket': 'mybucket', 'key': 'data.csv'}
    print(event)
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']

    # Get the object from S3
    s3 = session.client('s3')
    response = s3.get_object(Bucket=bucket_name, Key=file_key)

    # Read the CSV file line by line
    with closing(response['Body']) as csv_file:
        rows = csv.DictReader(codecs.getreader('utf-8')(csv_file))
        
        for row in rows:
            hostname = row['hostname']
            redirect_host = row['redirect_host']
            redirect_http_code = row['redirect_http_code']
            
            # Prepare the item to insert or update
            item = {
                'hostname': {'S': hostname},
                'redirect_host': {'S': redirect_host},
                'redirect_http_code': {'N': str(redirect_http_code)}
            }
            
            # Insert or update the item in the DynamoDB table
            dynamodb.put_item(TableName='redirect-hosts', Item=item)

    return 'Process completed successfully!'
