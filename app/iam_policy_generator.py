import os, re
from openai import OpenAI

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def generate_iam_policy(user_prompt: str):
    try:
        response = client.responses.create(
            model = "gpt-4.1-nano-2025-04-14",
            instructions = "You are an expert at writing AWS IAM policies. " \
            "Given a description of access requirements, return a valid IAM policy JSON. " \
            "Include comments to summarize each rule, but add no further output outside of the IAM policy JSON. " \
            "Ensure the policy is well-formed and adheres to latest AWS best practices.",
            input = user_prompt
        )

        return response.output_text

    except Exception as e:
        print(f"Error generating IAM policy: {e}")
        return {"error": "Failed to generate IAM policy. Please try again."}