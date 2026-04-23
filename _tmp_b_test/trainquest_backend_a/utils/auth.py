from functools import wraps
from flask import request, jsonify
import jwt

from config import Config
from models.user import User


def generate_token(user):
    payload = {
        "user_id": user.id,
        "username": user.username
    }
    token = jwt.encode(payload, Config.SECRET_KEY, algorithm="HS256")
    return token


def token_required(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")

        if not auth_header.startswith("Bearer "):
            return jsonify({"message": "Missing token"}), 401

        token = auth_header.split(" ")[1]

        try:
            data = jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])
            current_user = User.query.get(data["user_id"])

            if current_user is None:
                return jsonify({"message": "User not found"}), 401

        except Exception:
            return jsonify({"message": "Invalid token"}), 401

        return func(current_user, *args, **kwargs)

    return wrapper