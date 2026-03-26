FROM python:3.12-slim

WORKDIR /app 

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 1. 不要生成缓存垃圾文件
# 2. 日志必须立刻打印出来

ENV FLASK_ENV=production \
    PYTHONPATH=/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

# 更新软件源 → 安装最小依赖（编译工具） → 删除缓存，保持镜像干净

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# 升级 pip → 安装项目依赖 → 安装生产运行服务器 gunicorn → 不保留缓存

COPY . .
# first point  把当前目录下的所有文件（包括代码和相关文件）
# second point  复制到镜像的 /app 目录下（WORKDIR 已经设置为 /app）

RUN useradd -m appuser
USER appuser

EXPOSE 8000

CMD ["gunicorn", "--blind", "0.0.0.0:8000", "app:app"]
# gunicorn 本身就是“运行你的 Python Web 应用”的工具
# 它不是普通命令行工具，而是一个 WSGI 应用服务器
# app:app 的意思是：第一个 app 是指 app.py 文件（不需要写 .py 后缀），第二个 app 是指 app.py 文件中创建的 Flask 应用对象（通常命名为 app）