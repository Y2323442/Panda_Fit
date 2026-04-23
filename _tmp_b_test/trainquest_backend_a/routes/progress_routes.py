from datetime import date
from flask import Blueprint, request, jsonify

from models import db
from models.progress import ProgressRecord
from utils.auth import token_required
from services.gamification_service import add_xp, update_streak, try_unlock_badges

progress_bp = Blueprint("progress_bp", __name__, url_prefix="/api/progress")


@progress_bp.route("/today", methods=["GET"])
@token_required
def get_today_progress(current_user):
    today = date.today()

    record = ProgressRecord.query.filter_by(
        user_id=current_user.id,
        record_date=today
    ).first()

    if record is None:
        record = ProgressRecord(
            user_id=current_user.id,
            record_date=today
        )
        db.session.add(record)
        db.session.commit()

    return jsonify(record.to_dict()), 200


@progress_bp.route("/today", methods=["POST"])
@token_required
def update_today_progress(current_user):
    data = request.get_json()
    today = date.today()

    record = ProgressRecord.query.filter_by(
        user_id=current_user.id,
        record_date=today
    ).first()

    if record is None:
        record = ProgressRecord(
            user_id=current_user.id,
            record_date=today
        )
        db.session.add(record)

    record.steps = data.get("steps", record.steps)
    record.workout_minutes = data.get("workout_minutes", record.workout_minutes)
    record.calories = data.get("calories", record.calories)
    record.distance_km = data.get("distance_km", record.distance_km)

    db.session.commit()

    return jsonify({
        "message": "Progress updated successfully",
        "record": record.to_dict()
    }), 200


@progress_bp.route("/sign-in", methods=["POST"])
@token_required
def daily_sign_in(current_user):
    today = date.today()

    record = ProgressRecord.query.filter_by(
        user_id=current_user.id,
        record_date=today
    ).first()

    if record is None:
        record = ProgressRecord(
            user_id=current_user.id,
            record_date=today
        )
        db.session.add(record)
        db.session.commit()

    if record.signed_in:
        return jsonify({"message": "Already signed in today"}), 400

    record.signed_in = True
    db.session.commit()

    add_xp(current_user, 15)
    update_streak(current_user, record)
    new_badges = try_unlock_badges(current_user)

    return jsonify({
        "message": "Sign in successful",
        "record": record.to_dict(),
        "user": current_user.to_dict(),
        "new_badges": new_badges
    }), 200