from datetime import datetime
from models import db


class Task(db.Model):
    __tablename__ = "tasks"

    id = db.Column(db.Integer, primary_key=True)

    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, default="")
    category = db.Column(db.String(30), default="daily")   # daily / project
    status = db.Column(db.String(20), default="pending")   # pending / completed
    difficulty = db.Column(db.String(20), default="easy")
    time_slot = db.Column(db.String(30), default="")

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    completed_at = db.Column(db.DateTime, nullable=True)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "title": self.title,
            "description": self.description,
            "category": self.category,
            "status": self.status,
            "difficulty": self.difficulty,
            "time_slot": self.time_slot,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None
        }