from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from pydantic import BaseModel
from datetime import datetime, timedelta
import requests, urllib.parse, json, boto3
from botocore.exceptions import ClientError
from iam_policy_generator import generate_iam_policy
from models import SessionLocal, get_or_create_user, save_history, get_user_history

app = FastAPI()

origins = [
    "https://iampolicygenerator.edisonlim.ca"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Globals
google_client_id = None
google_client_secret = None
SECRET_KEY = None
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
REDIRECT_URI = "https://iampolicygenerator.edisonlim.ca/oauth2/callback"

# =======================
# Load AWS Secrets
# =======================
def get_secret(secret_name: str):
    region_name = "us-east-1"
    client = boto3.client('secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except ClientError as e:
        print(f"Error retrieving secret {secret_name}: {e}")
        raise e

@app.on_event("startup")
def startup_event():
    global google_client_id, google_client_secret, SECRET_KEY

    # Load Google OAuth credentials
    google_secrets = get_secret("google/iam-policy-generator-oauth-credentials")
    google_client_id = google_secrets.get("client_id")
    google_client_secret = google_secrets.get("client_secret")

    # Load JWT Secret
    jwt_secret = get_secret("jwt/iam-policy-generator-secret")
    SECRET_KEY = jwt_secret.get("key")

    if not google_client_id or not google_client_secret or not SECRET_KEY:
        raise ValueError("Critical secrets are missing in AWS Secrets Manager")


# =======================
# Pydantic Models
# =======================
class PromptRequest(BaseModel):
    prompt: str


# =======================
# Routes
# =======================
@app.get("/")
def read_root():
    return {"message": "Welcome to the IAM Policy Generator API"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.post("/generate")
async def generate(prompt: PromptRequest):
    if not prompt.prompt:
        return {"error": "Missing prompt in request data"}

    iam_policy = generate_iam_policy(prompt.prompt)
    return {"iam_policy": iam_policy}


# =======================
# Google OAuth Callback
# =======================
@app.get("/auth/google/callback")
def google_callback(code: str):
    token_url = "https://oauth2.googleapis.com/token"
    token_data = {
        "code": code,
        "client_id": google_client_id,
        "client_secret": google_client_secret,
        "redirect_uri": REDIRECT_URI,
        "grant_type": "authorization_code",
    }

    # Exchange code for token
    token_resp = requests.post(token_url, data=token_data).json()
    if "error" in token_resp:
        return {"error": token_resp.get("error_description", "Failed to get token")}

    access_token = token_resp.get("access_token")
    if not access_token:
        return {"error": "No access token received"}

    # Get user info
    userinfo_resp = requests.get(
        "https://www.googleapis.com/oauth2/v3/userinfo",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    userinfo = userinfo_resp.json()

    # Create user in DB if not exists
    db = SessionLocal()
    user = get_or_create_user(db, userinfo["email"], userinfo.get("name"), userinfo.get("picture"))

    # Create JWT
    token = create_access_token({"sub": user.email, "user_id": user.id})

    frontend_redirect = f"https://iampolicygenerator.edisonlim.ca?token={token}&email={urllib.parse.quote(user.email)}&picture={urllib.parse.quote(user.picture)}"
    return RedirectResponse(url=frontend_redirect)


# =======================
# JWT Utilities
# =======================
def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: int = payload.get("user_id")
        email: str = payload.get("sub")
        if user_id is None or email is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
        return {"user_id": user_id, "email": email}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


# =======================
# History Endpoints
# =======================
@app.post("/save-history")
def save_user_history(prompt: str, policy: dict, current_user=Depends(get_current_user)):
    db = SessionLocal()
    saved = save_history(db, current_user["user_id"], prompt, policy)
    return {"message": "History saved", "history_id": saved.id}

@app.get("/history")
def get_history(current_user=Depends(get_current_user)):
    db = SessionLocal()
    histories = get_user_history(db, current_user["user_id"])
    return [
        {"prompt": h.prompt, "policy": json.loads(h.policy), "created_at": h.created_at.isoformat()}
        for h in histories
    ]
