import os
from flask import Flask, jsonify, request
from flask_cors import CORS

# 直接在这里写登录接口，不使用任何蓝图！
app = Flask(__name__)
CORS(app)

# 登录接口（直接写在这里，100% 不会 404）
@app.route("/api/auth/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    return jsonify({
        "msg": "后端接口正常！",
        "email": email,
        "status": "success"
    })

# 测试接口
@app.route("/")
def hello():
    return "✅ 后端运行成功！"

if __name__ == "__main__":
    app.run()