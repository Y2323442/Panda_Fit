from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from models import db


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)

    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    # gamification 相关字段
    level = db.Column(db.Integer, default=1)
    xp = db.Column(db.Integer, default=0)
    streak_days = db.Column(db.Integer, default=0)
    total_sign_in_days = db.Column(db.Integer, default=0)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # 关系映射
    tasks = db.relationship("Task", backref="user", lazy=True)
    progress_records = db.relationship("ProgressRecord", backref="user", lazy=True)
    badges = db.relationship("UserBadge", backref="user", lazy=True)
    photos = db.relationship("WorkoutPhoto", backref="user", lazy=True)

    def set_password(self, raw_password):
        self.password_hash = generate_password_hash(raw_password)

    def check_password(self, raw_password):
        return check_password_hash(self.password_hash, raw_password)

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "level": self.level,
            "xp": self.xp,
            "streak_days": self.streak_days,
            "total_sign_in_days": self.total_sign_in_days,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }