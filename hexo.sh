#!/bin/bash
# Hexo + Anzhiyu 主题一键配置脚本
# 最后更新：2024-06-08

# ------------ 用户配置区 ------------
# 基础信息
SITE_TITLE="日月R.Y.的小窝"          # 网站标题
SITE_SUBTITLE="日月R.Y."       # 网站副标题
SITE_AUTHOR="RiYueRY"             # 作者姓名
SITE_DESCRIPTION="记录技术学习笔记" # 网站描述
SITE_KEYWORDS="技术,编程,博客"     # 网站关键词（逗号分隔）
SITE_LANGUAGE="zh-CN"            # 语言代码
SITE_TIMEZONE="Asia/Shanghai"    # 时区

# 部署配置
GIT_REPO="https://github.com/XK-YiM/XK-YiM.github.io.git"  # 仓库地址
DEPLOY_BRANCH="main"              # 部署分支

# 主题配置
THEME_CLONE_CMD="git clone -b main https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu"
THEME_COLOR="#3b70fc"            # 主题主颜色
ENABLE_DARKMODE="true"           # 启用暗黑模式 (true/false)
# -----------------------------------

set -e
echo "▶ 开始配置 Hexo 博客系统..."

# 安装 Hexo CLI
if ! command -v hexo &> /dev/null; then
  echo "⚙ 安装 hexo-cli..."
  npm install -g hexo-cli
fi

# 初始化项目
if [ ! -d "hexo" ]; then
  echo "⚙ 初始化 Hexo 项目..."
  hexo init hexo
  cd hexo
  npm install
else
  echo "⏩ 检测到现有 Hexo 项目，跳过初始化..."
  cd hexo
fi

# 安装主题
if [ ! -d "themes/anzhiyu" ]; then
  echo "⚙ 下载 Anzhiyu 主题..."
  eval "$THEME_CLONE_CMD"
else
  echo "⏩ 主题已存在，跳过下载..."
fi

# 生成主配置文件
echo "⚙ 生成核心配置文件..."
cat > _config.yml << EOF
# ===================================
# Hexo 主配置 (由自动化脚本生成)
# ===================================

# 站点信息
title: $SITE_TITLE
subtitle: $SITE_SUBTITLE
description: $SITE_DESCRIPTION
keywords: $SITE_KEYWORDS
author: $SITE_AUTHOR
language: $SITE_LANGUAGE
timezone: $SITE_TIMEZONE

# 扩展配置
theme: anzhiyu
url: https://${GIT_REPO#*github.com/}
root: /
permalink: :year/:month/:title/
permalink_defaults:

# 部署设置
deploy:
  type: git
  repo: $GIT_REPO
  branch: $DEPLOY_BRANCH
  message: "Auto deployed by Hexo"

# 扩展功能
feed:
  type: atom
  path: atom.xml
  limit: 20
EOF

# 生成主题配置文件
echo "⚙ 生成主题配置文件..."
if [ ! -f "_config.anzhiyu.yml" ]; then
  cp themes/anzhiyu/_config.yml _config.anzhiyu.yml
fi

# 应用主题配色方案
echo "⚙ 应用主题颜色 ($THEME_COLOR)..."
sed -i "s/#3b70fc/$THEME_COLOR/g" _config.anzhiyu.yml
sed -i "s/enable: false/enable: $ENABLE_DARKMODE/" _config.anzhiyu.yml

# 安装依赖
echo "⚙ 安装必要插件..."
npm install hexo-deployer-git hexo-renderer-pug hexo-renderer-stylus --save
# 完成提示
echo -e "\n\033[32m✔ 配置完成！\033[0m"
echo "========================================"
echo "后续操作建议："
echo "1. 修改主题配置：vim _config.anzhiyu.yml"
echo "2. 创建第一篇博客：hexo new \"Hello World\""
echo "3. 本地预览：hexo server --port 8080"
echo "4. 部署发布：hexo clean && hexo g --deploy"
echo "========================================"
