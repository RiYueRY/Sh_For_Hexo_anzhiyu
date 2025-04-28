#!/bin/bash

# --------------------------
# 用户自定义配置区 (按需修改)
# --------------------------
SITE_NAME="日月R.Y."
SITE_SUBTITLE="记录与分享技术点滴"
GITHUB_USERNAME="RiYurRY"       # 替换为 GitHub 用户名
TIMEZONE="Asia/Shanghai"                    # 时区设置
SITE_URL="https://${GITHUB_USERNAME}.github.io"
THEME_CONFIG_FILE="hexo/themes/anzhiyu/_config.yml"  # 更新后的主题配置路径
COMMIT_EMAIL="3968773701@qq.com"        # 提交邮箱
COMMIT_NAME="RiYue"                      # 提交者姓名

# --------------------------
# 基础环境配置
# --------------------------
git config --global user.email "${COMMIT_EMAIL}"
git config --global user.name "${COMMIT_NAME}"
npm install -g hexo-cli

# --------------------------
# 项目初始化
# --------------------------
# 创建并进入 hexo 目录
hexo init hexo && cd hexo || exit

# 安装核心依赖
npm install --save hexo-server hexo-generator-feed hexo-renderer-marked

# 安装主题（通过 Git）
git clone https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu

# --------------------------
# 配置文件修改
# --------------------------
# 修改主配置
sed -i "s/title:.*/title: ${SITE_NAME}/" _config.yml
sed -i "s/subtitle:.*/subtitle: ${SITE_SUBTITLE}/" _config.yml
sed -i "s/url:.*/url: ${SITE_URL}/" _config.yml
sed -i "s/timezone:.*/timezone: ${TIMEZONE}/" _config.yml
sed -i "s/theme:.*/theme: anzhiyu/" _config.yml

# 添加部署配置
cat >> _config.yml << EOF

# Auto Deploy Settings
deploy:
  type: git
  repo: https://github.com/${GITHUB_USERNAME}/${GITHUB_USERNAME}.github.io.git
  branch: main
EOF

# 修改主题配置
sed -i "s/^title:.*/title: ${SITE_NAME}/" ${THEME_CONFIG_FILE}
sed -i "s/^subtitle:.*/subtitle: ${SITE_SUBTITLE}/" ${THEME_CONFIG_FILE}

# --------------------------
# 依赖安装与构建
# --------------------------
npm install hexo-deployer-git --save
hexo clean && hexo g

# --------------------------
# 自动部署与推送
# --------------------------
hexo d

# 返回上级目录处理源码提交
cd ..
git init
git add .
git commit -m "chore: Initial Hexo setup with anzhiyu theme [auto-generated]"
git branch -M main
git remote add origin "https://github.com/${GITHUB_USERNAME}/${GITHUB_USERNAME}.github.io.git"
git push -u origin main -f
