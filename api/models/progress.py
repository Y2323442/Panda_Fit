from datetime import date
from models import db


class ProgressRecord(db.Model):
    __tablename__ = "progress_records"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)

    record_date = db.Column(db.Date, default=date.today)

    steps = db.Column(db.Integer, default=0)
    workout_minutes = db.Column(db.Integer, default=0)
    calories = db.Column(db.Integer, default=0)
    distance_km = db.Column(db.Float, default=0.0)

    signed_in = db.Column(db.Boolean, default=False)

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "record_date": self.record_date.isoformat() if self.record_date else None,
            "steps": self.steps,
            "workout_minutes": self.workout_minutes,
            "calories": self.calories,
            "distance_km": self.distance_km,
            "signed_in": self.signed_in
        }