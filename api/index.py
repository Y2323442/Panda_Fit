# api/index.py
import sys
import os

# 把项目根目录加入 Python 路径
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

# 现在可以稳定导入
from trainquest_backend_a.app import app
application = app