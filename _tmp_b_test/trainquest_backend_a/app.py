import os
from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS

# 注意：这里自动读取 Vercel 云数据库链接，本地也能兼容
class Config:
    # 云数据库优先，本地用 sqlite
    SQLALCHEMY_DATABASE_URI = os.getenv("POSTGRES_URL", "sqlite:///pandafit.db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-key-for-course")
    UPLOAD_FOLDER = "uploads"

# 导入 db
from models import db

# 导入所有模型，确保 db.create_all() 时能识别到这些表
from models.user import User
from models.task import Task
from models.progress import ProgressRecord
from models.badge import Badge, UserBadge
from models.photo import WorkoutPhoto

# 导入所有蓝图
from routes.auth_routes import auth_bp
from routes.task_routes import task_bp
from routes.progress_routes import progress_bp
from routes.badge_routes import badge_bp
from routes.photo_routes import photo_bp
from routes.dashboard_routes import dashboard_bp


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # 允许前端跨域访问（Flutter Web 必须）
    CORS(app, resources={r"/*": {"origins": "*"}})

    # 初始化数据库
    db.init_app(app)

    # 自动创建需要的文件夹
    base_dir = os.path.dirname(__file__)
    os.makedirs(os.path.join(base_dir, "instance"), exist_ok=True)
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # 注册蓝图
    app.register_blueprint(auth_bp, url_prefix="/api")
    app.register_blueprint(task_bp, url_prefix="/api")
    app.register_blueprint(progress_bp, url_prefix="/api")
    app.register_blueprint(badge_bp, url_prefix="/api")
    app.register_blueprint(photo_bp, url_prefix="/api")
    app.register_blueprint(dashboard_bp, url_prefix="/api")

    @app.route("/", methods=["GET"])
    def home():
        return jsonify({
            "message": "PandaFit 后端已成功部署在 Vercel 🚀"
        }), 200

    @app.route("/uploads/<filename>", methods=["GET"])
    def uploaded_file(filename):
        return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

    return app


app = create_app()

# 自动建表
with app.app_context():
    db.create_all()


# Vercel 必须要这个入口，不能删
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=57885, debug=True)