from datetime import datetime
from models import db


class WorkoutPhoto(db.Model):
    __tablename__ = "workout_photos"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    filename = db.Column(db.String(255), nullable=False)
    caption = db.Column(db.String(255), default="")
    uploaded_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "filename": self.filename,
            "caption": self.caption,
            "uploaded_at": self.uploaded_at.isoformat() if self.uploaded_at else None
        }