# -----------------------------
# 阶段 1: 构建/测试环境
# -----------------------------
# 使用一个官方的 Python 镜像作为基础
FROM python:3.10-slim as builder

# 设置工作目录，后续所有命令都在这个目录下执行
WORKDIR /app

# 将依赖文件复制到容器中
COPY requirements.txt .

# 安装依赖。--no-cache-dir 减少镜像体积
RUN pip install --no-cache-dir -r requirements.txt

# 将所有项目文件复制到容器中
COPY . .

# [CI 专用] 在构建镜像时运行测试，如果测试失败，构建也会失败
# 这是一个好习惯，确保只有通过测试的代码才能被打包成最终镜像
RUN pytest

# -----------------------------
# 阶段 2: 生产环境
# -----------------------------
# 再次使用一个更小的基础镜像，以减小最终镜像的体积
FROM python:3.10-slim as final

# 设置工作目录
WORKDIR /app

# 只从上一个阶段（builder）复制必要的产物，而不是整个项目文件
# 这里我们只需要 main.py
COPY --from=builder /app/main.py .

# 设置容器启动时要执行的命令
CMD ["python", "main.py"]
