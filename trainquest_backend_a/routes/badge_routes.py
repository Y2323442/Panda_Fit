from flask import Blueprint, jsonify
from utils.auth import token_required

badge_bp = Blueprint("badge_bp", __name__, url_prefix="/api/badges")


@badge_bp.route("", methods=["GET"])
@token_required
def get_my_badges(current_user):
    return jsonify([item.to_dict() for item in current_user.badges]), 200