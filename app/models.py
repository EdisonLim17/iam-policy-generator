from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, Session, sessionmaker
import os, boto3, json
from botocore.exceptions import ClientError
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=True)
    picture = Column(String, nullable=True)

    histories = relationship("History", back_populates="user")

class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    prompt = Column(Text, nullable=False)
    policy = Column(Text, nullable=False)  # Store JSON as string
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="histories")

def get_database_values(secret_name: str):
    region_name = "us-east-1"
    client = boto3.client('secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except ClientError as e:
        print(f"Error retrieving secret {secret_name}: {e}")
        raise e
    
database_values = get_database_values("rds/iam-policy-generator-credentials-output")

DATABASE_URL = (
    f"postgresql://{database_values.get('username')}:{database_values.get('password')}@"
    f"{database_values.get('host')}:{database_values.get('port')}/{database_values.get('db_name')}"
)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create tables (run once at startup)
Base.metadata.create_all(bind=engine)

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, email: str, name: str = None, picture: str = None):
    db_user = User(email=email, name=name, picture=picture)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_or_create_user(db: Session, email: str, name: str = None, picture: str = None):
    user = get_user_by_email(db, email)
    if user:
        return user
    else:
        return create_user(db, email, name, picture)

def save_history(db: Session, user_id: int, prompt: str, policy: dict):
    import json
    db_history = History(user_id=user_id, prompt=prompt, policy=json.dumps(policy))
    db.add(db_history)
    db.commit()
    db.refresh(db_history)
    return db_history

def get_user_history(db: Session, user_id: int):
    return db.query(History).filter(History.user_id == user_id).order_by(History.created_at.desc()).all()