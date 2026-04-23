import os
import secrets

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DATABASE_FILENAME = os.getenv("TRAINQUEST_DB_NAME", "trainquest_backup_20260418_215442.db")


def load_secret_key():
    env_secret = os.getenv("TRAINQUEST_SECRET_KEY")
    if env_secret:
        return env_secret

    instance_dir = os.path.join(BASE_DIR, "instance")
    os.makedirs(instance_dir, exist_ok=True)

    secret_path = os.path.join(instance_dir, ".secret_key")
    if os.path.exists(secret_path):
        with open(secret_path, "r", encoding="utf-8") as secret_file:
            secret = secret_file.read().strip()
            if secret:
                return secret

    secret = secrets.token_urlsafe(48)
    with open(secret_path, "w", encoding="utf-8") as secret_file:
        secret_file.write(secret)

    return secret


class Config:
    SECRET_KEY = load_secret_key()
    JWT_EXPIRES_HOURS = int(os.getenv("TRAINQUEST_JWT_EXPIRES_HOURS", "24"))

    # ==============================================
    # 核心改动：自动判断环境，线上用云数据库，本地用 SQLite
    # ==============================================
    if os.getenv("VERCEL_ENV") or os.getenv("POSTGRES_URL"):
        # 部署在 Vercel → 使用云数据库
        SQLALCHEMY_DATABASE_URI = os.getenv("POSTGRES_URL")
    else:
        # 本地运行 → 使用原来的 SQLite 不变
        SQLALCHEMY_DATABASE_URI = "sqlite:///" + os.path.join(BASE_DIR, "instance", DATABASE_FILENAME)

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")