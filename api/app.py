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

# 生产环境
os.environ["FLASK_ENV"] = "production"

# ==============================================
# ⚠️ 重要：Vercel 不支持 SQLite 文件数据库
# 你必须换成 Vercel Postgres 或 Supabase
# 下面先临时兼容，不让构建报错
# ==============================================
# 注释掉 SQLite（会丢数据）
# os.environ["DATABASE_URL"] = "sqlite:////tmp/pandafit.db"

# 临时用内存数据库（部署测试用）
os.environ["DATABASE_URL"] = "sqlite:///:memory:"

# 上传目录（Vercel 只读，只能放 tmp）
os.environ["UPLOAD_FOLDER"] = "/tmp/uploads"


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    CORS(app)
    db.init_app(app)

    base_dir = os.path.dirname(__file__)
    os.makedirs(os.path.join(base_dir, "instance"), exist_ok=True)
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # 蓝图路由（全部 /api/... 正确）
    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(task_bp, url_prefix="/api/tasks")
    app.register_blueprint(progress_bp, url_prefix="/api/progress")
    app.register_blueprint(badge_bp, url_prefix="/api/badges")
    app.register_blueprint(photo_bp, url_prefix="/api/photos")
    app.register_blueprint(dashboard_bp, url_prefix="/api/dashboard")

    @app.route("/")
    def index():
        return "Hello from Flask on Vercel!"

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
application = app  # ✅ Vercel 专用

# 数据库初始化（内存版，测试用）
with app.app_context():
    db.create_all()

# ❌ 下面这段保留也没关系，Vercel 不会执行
# if __name__ == "__main__":
#     app.run(debug=True, host="0.0.0.0", port=8080)