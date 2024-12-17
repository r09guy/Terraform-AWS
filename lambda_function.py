import json
import boto3
import base64
import uuid
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')
bucket_name = 'r0938274-terraform-file-upload-bucket'

def lambda_handler(event, context):
    try:
        # Extract file name from headers
        file_name = event['headers'].get('filename')
        if not file_name:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Filename is required in the headers.'})
            }
        
        # Get the raw file content from the body
        file_data = event['body']

        # Upload the file to S3
        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=file_data,
            ContentType="text/plain"  # Assuming plain text content for this example
        )

        # Return a success response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'File uploaded successfully!', 'file_name': file_name})
        }
    
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f"Error: {e.response['Error']['Message']}"})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f"Unexpected error: {str(e)}"})
        }
    try:
        # Get the file data from the API Gateway event
        file_data = event['body']
        file_data = base64.b64decode(file_data)

        file_name = str(uuid.uuid4())

        
        # Upload the file to S3
        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_name,
            Body=file_data,
            ContentType="application/octet-stream"
        )

        # Return a success response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'File uploaded successfully!'})
        }
    
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f"Error: {e.response['Error']['Message']}"})
        }
