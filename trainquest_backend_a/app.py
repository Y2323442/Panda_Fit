import os
from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS

from config import Config
from models import db
from utils.auth import token_required

from models.user import User
from models.task import Task
from models.progress import ProgressRecord
from models.badge import Badge, UserBadge
from models.photo import WorkoutPhoto

from routes.auth_routes import auth_bp
from routes.task_routes import task_bp
from routes.progress_routes import progress_bp
from routes.badge_routes import badge_bp
from routes.photo_routes import photo_bp
from routes.dashboard_routes import dashboard_bp

os.environ["FLASK_ENV"] = "production"
os.environ["DATABASE_URL"] = "sqlite:////tmp/pandafit.db"
os.environ["UPLOAD_FOLDER"] = "/tmp/uploads"


def create_app():
    app = Flask(__name__, static_folder="../build/web", static_url_path="")
    app.config.from_object(Config)

    CORS(app)
    db.init_app(app)

    base_dir = os.path.dirname(__file__)
    os.makedirs(os.path.join(base_dir, "instance"), exist_ok=True)
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # ========== 这里是关键修改！添加了 API 前缀 ==========
    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(task_bp, url_prefix="/api/tasks")
    app.register_blueprint(progress_bp, url_prefix="/api/progress")
    app.register_blueprint(badge_bp, url_prefix="/api/badges")
    app.register_blueprint(photo_bp, url_prefix="/api/photos")
    app.register_blueprint(dashboard_bp, url_prefix="/api/dashboard")
    # ====================================================

    @app.route("/")
    def index():
        return "Hello from Flask!"  # 测试用

    @app.route("/uploads/<filename>", methods=["GET"])
    @token_required
    def uploaded_file(current_user, filename):
        photo = WorkoutPhoto.query.filter_by(
            user_id=current_user.id, filename=filename
        ).first()
        if not photo:
            return jsonify({"message": "Photo not found"}), 404
        return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

    return app


app = create_app()

with app.app_context():
    db.create_all()

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)