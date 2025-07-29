import os, re
from openai import OpenAI
import json
import boto3
from botocore.exceptions import ClientError


def get_openai_api_key():

    secret_name = "openai/iam-policy-generator-api-key"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )

        secret_string = get_secret_value_response['SecretString']
        # Parse the secret string as JSON
        secret_dict = json.loads(secret_string)
        
        # Return the OpenAI API key
        return secret_dict.get('OPENAI_API_KEY')
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

client = OpenAI(api_key=get_openai_api_key())

def generate_iam_policy(user_prompt: str):
    try:
        response = client.responses.create(
            model = "gpt-4.1-nano-2025-04-14",
            instructions = "You are an expert at writing AWS IAM policies. " \
            "Given a description of access requirements, return a valid IAM policy JSON. " \
            "Include no comments and add no further output outside of the IAM policy JSON, your entire output should be in valid JSON format. " \
            "Ensure the policy is well-formed and adheres to latest AWS best practices.",
            input = user_prompt
        )

        return response.output_text

    except Exception as e:
        print(f"Error generating IAM policy: {e}")
        return {"error": "Failed to generate IAM policy. Please try again."}