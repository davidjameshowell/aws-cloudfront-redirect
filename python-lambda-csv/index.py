import csv
import boto3
import codecs
import os
import tempfile
from contextlib import closing
import re
from datetime import datetime

# Constants
DDB_TABLE_ENV_VAR = 'DDB_TABLE'
CSV_ENCODING = 'utf-8'
PROCESSED_FILE_PREFIX = 'processed/'

def is_valid_hostname(hostname):
    """Check if the hostname is valid."""
    return re.match(r"^[a-zA-Z0-9.-]+$", hostname) and not hostname.endswith('.')

def is_valid_path(path):
    """Check if the path is valid."""
    return re.match(r"^/([^/?#]*?/)*([^/?#]*|\*)?$", path)

def is_valid_http_code(code):
    """Check if the HTTP code is valid."""
    return code in [301, 302]

def process_csv_row(dynamodb_client, row):
    """Process a single row of the CSV file."""
    validations = {
        'hostname': (is_valid_hostname, 'Invalid hostname'),
        'hostname_path': (is_valid_path, 'Invalid hostname path'),
        'redirect_host': (is_valid_hostname, 'Invalid redirect host'),
        'redirect_path': (is_valid_path, 'Invalid redirect path'),
        'redirect_http_code': (lambda code: is_valid_http_code(int(code)), 'Invalid HTTP code')
    }

    errors = [error_message for field, (validator, error_message) in validations.items()
              if not validator(row[field])]

    if errors:
        row['import_status'] = 'Errors: ' + '; '.join(errors)
        return row

    item = {
        'hostname': {'S': row['hostname']},
        'hostname_path': {'S': row['hostname_path']},
        'redirect_host': {'S': row['redirect_host']},
        'redirect_path': {'S': row['redirect_path']}
    }

    try:
        dynamodb_client.put_item(TableName=os.environ[DDB_TABLE_ENV_VAR], Item=item)
        row['import_status'] = 'Success'
    except Exception as e:
        row['import_status'] = f'Error: {str(e)}'
    return row

def process_file(bucket_name, file_key, dynamodb_client, s3_client):
    """Process the entire CSV file."""
    response = s3_client.get_object(Bucket=bucket_name, Key=file_key)

    with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp_file:
        with closing(response['Body']) as csv_file:
            rows = csv.DictReader(codecs.getreader(CSV_ENCODING)(csv_file))

            fieldnames = rows.fieldnames + ['import_status']
            writer = csv.DictWriter(temp_file, fieldnames=fieldnames)
            writer.writeheader()

            for row in rows:
                updated_row = process_csv_row(dynamodb_client, row)
                writer.writerow(updated_row)

    return temp_file.name

def lambda_handler(event, context):
    """AWS Lambda handler function."""
    session = boto3.Session()
    dynamodb = session.client('dynamodb')
    s3 = session.client('s3')

    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['object']['key']

    temp_file_name = process_file(bucket_name, file_key, dynamodb, s3)

    epoch_time = int(datetime.now().timestamp())
    new_file_key = f"{PROCESSED_FILE_PREFIX}{os.path.splitext(file_key)[0]}_{epoch_time}.csv"

    s3.upload_file(temp_file_name, bucket_name, new_file_key)
    s3.delete_object(Bucket=bucket_name, Key=file_key)
    os.remove(temp_file_name)

    return 'Process completed successfully!'
