from app import app
from models import db

with app.app_context():
    db.drop_all()    # 删除所有表
    db.create_all()  # 根据模型重新创建
    print("The database has been reset.！")