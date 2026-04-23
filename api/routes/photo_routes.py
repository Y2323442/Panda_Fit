import os
from uuid import uuid4
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename

from models import db
from models.photo import WorkoutPhoto
from utils.auth import token_required

photo_bp = Blueprint("photo_bp", __name__, url_prefix="/api/photos")


@photo_bp.route("", methods=["POST"])
@token_required
def upload_photo(current_user):
    if "photo" not in request.files:
        return jsonify({"message": "No photo uploaded"}), 400

    photo = request.files["photo"]
    caption = request.form.get("caption", "")

    if photo.filename == "":
        return jsonify({"message": "Empty file name"}), 400

    original_name = secure_filename(photo.filename)
    _, extension = os.path.splitext(original_name)
    filename = f"user_{current_user.id}_{uuid4().hex}{extension.lower()}"

    save_path = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
    photo.save(save_path)

    new_photo = WorkoutPhoto(
        user_id=current_user.id,
        filename=filename,
        caption=caption
    )

    db.session.add(new_photo)
    db.session.commit()

    return jsonify({
        "message": "Photo uploaded successfully",
        "photo": new_photo.to_dict()
    }), 201


@photo_bp.route("", methods=["GET"])
@token_required
def get_photos(current_user):
    photos = WorkoutPhoto.query.filter_by(user_id=current_user.id).order_by(
        WorkoutPhoto.uploaded_at.desc()
    ).all()

    return jsonify([p.to_dict() for p in photos]), 200
