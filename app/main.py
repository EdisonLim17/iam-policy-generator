from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from iam_policy_generator import generate_iam_policy

app = FastAPI()

origins = [
    "https://main.d38p951x38v43o.amplifyapp.com"  # Production domain
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PromptRequest(BaseModel):
    prompt: str

@app.get("/")
def read_root():
    return {"message": "Welcome to the IAM Policy Generator API"}

#returns healthy status of the API
@app.get("/health")
def health_check():
    return {"status": "healthy"}

#calls the generate_iam_policy function with the user's prompt
@app.post("/generate")
async def generate(prompt: PromptRequest):
    if not prompt.prompt:
        return {"error": "Missing prompt in request data"}

    iam_policy = generate_iam_policy(prompt.prompt)
    return {"iam_policy": iam_policy}