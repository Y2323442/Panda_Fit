from datetime import datetime
from models import db


class Badge(db.Model):
    __tablename__ = "badges"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    description = db.Column(db.String(255), default="")
    threshold = db.Column(db.Integer, default=0)
    badge_type = db.Column(db.String(30), default="streak")  
    # streak / xp / signin

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "threshold": self.threshold,
            "badge_type": self.badge_type
        }


class UserBadge(db.Model):
    __tablename__ = "user_badges"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    badge_id = db.Column(db.Integer, db.ForeignKey("badges.id"), nullable=False)
    earned_at = db.Column(db.DateTime, default=datetime.utcnow)

    badge = db.relationship("Badge")

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "badge": self.badge.to_dict() if self.badge else None,
            "earned_at": self.earned_at.isoformat() if self.earned_at else None
        }