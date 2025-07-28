from sqlalchemy import Column, Integer, String, Text, ForeignKey, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, Session, sessionmaker
import os
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

DATABASE_URL = (
    f"postgresql://{os.getenv('DB_USERNAME')}:{os.getenv('DB_PASSWORD')}@"
    f"{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
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