from flask import Blueprint, jsonify

from utils.auth import token_required
from services.stats_service import get_weekly_summary
from models.task import Task

dashboard_bp = Blueprint("dashboard_bp", __name__, url_prefix="/api/dashboard")


@dashboard_bp.route("/home", methods=["GET"])
@token_required
def get_home_data(current_user):
    daily_tasks = Task.query.filter_by(
        user_id=current_user.id,
        category="daily"
    ).all()

    weekly_summary = get_weekly_summary(current_user.id)

    response = {
        "user": current_user.to_dict(),
        "daily_tasks": [task.to_dict() for task in daily_tasks],
        "weekly_summary": weekly_summary
    }

    return jsonify(response), 200