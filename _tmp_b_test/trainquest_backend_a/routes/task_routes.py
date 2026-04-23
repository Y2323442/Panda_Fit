from datetime import datetime
from flask import Blueprint, request, jsonify

from models import db
from models.task import Task
from utils.auth import token_required

task_bp = Blueprint("task_bp", __name__, url_prefix="/api/tasks")


@task_bp.route("", methods=["GET"])
@token_required
def get_tasks(current_user):
    category = request.args.get("category")

    query = Task.query.filter_by(user_id=current_user.id)

    if category:
        query = query.filter_by(category=category)

    tasks = query.order_by(Task.created_at.desc()).all()

    return jsonify([task.to_dict() for task in tasks]), 200


@task_bp.route("", methods=["POST"])
@token_required
def create_task(current_user):
    data = request.get_json()

    title = data.get("title", "").strip()
    description = data.get("description", "").strip()
    category = data.get("category", "daily").strip()
    difficulty = data.get("difficulty", "easy").strip()
    time_slot = data.get("time_slot", "").strip()

    if not title:
        return jsonify({"message": "Task title is required"}), 400

    new_task = Task(
        user_id=current_user.id,
        title=title,
        description=description,
        category=category,
        difficulty=difficulty,
        time_slot=time_slot,
        status="pending"
    )

    db.session.add(new_task)
    db.session.commit()

    return jsonify({
        "message": "Task created successfully",
        "task": new_task.to_dict()
    }), 201


@task_bp.route("/<int:task_id>/complete", methods=["PATCH"])
@token_required
def complete_task(current_user, task_id):
    task = Task.query.filter_by(id=task_id, user_id=current_user.id).first()

    if task is None:
        return jsonify({"message": "Task not found"}), 404

    if task.status == "completed":
        return jsonify({"message": "Task is already completed"}), 400

    task.status = "completed"
    task.completed_at = datetime.utcnow()

    db.session.commit()

    return jsonify({
        "message": "Task completed successfully",
        "task": task.to_dict()
    }), 200


@task_bp.route("/<int:task_id>", methods=["DELETE"])
@token_required
def delete_task(current_user, task_id):
    task = Task.query.filter_by(id=task_id, user_id=current_user.id).first()

    if task is None:
        return jsonify({"message": "Task not found"}), 404

    db.session.delete(task)
    db.session.commit()

    return jsonify({"message": "Task deleted successfully"}), 200