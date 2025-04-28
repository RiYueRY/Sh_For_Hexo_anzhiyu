#!/bin/bash
# Hexo + Anzhiyu 主题一键配置脚本（适配 GitHub Codespaces）
# 最后更新：2024-06-08

# ------------ 用户配置区 ------------
GITHUB_USERNAME="RiYueRY"               # 你的 GitHub 用户名
SITE_TITLE="日月R.Y.的小窝"                  # 网站标题
SITE_SUBTITLE="技术与生活的交响曲"       # 网站副标题
THEME_COLOR="#2a8cff"                   # 主题主颜色
DEPLOY_BRANCH="main"                    # 部署分支
# -----------------------------------

set -e
echo "▶ 开始配置 Hexo 博客系统..."

# 自动生成仓库地址
GIT_REPO="git@github.com:${GITHUB_USERNAME}/${GITHUB_USERNAME}.github.io.git"

# 配置 Git 全局身份（避免提交错误）
git config --global user.name "${GITHUB_USERNAME}"
git config --global user.email "${GITHUB_USERNAME}@users.noreply.github.com"

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
  git clone -b main https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu
else
  echo "⏩ 主题已存在，跳过下载..."
fi

# 生成 Hexo 主配置
echo "⚙ 生成核心配置文件..."
cat > _config.yml << EOF
# ===================================
# Hexo 主配置 (由自动化脚本生成)
# ===================================

# 站点信息
title: ${SITE_TITLE}
subtitle: ${SITE_SUBTITLE}
description: 由 ${GITHUB_USERNAME} 创作的博客
keywords: 技术,编程,博客
author: ${GITHUB_USERNAME}
language: zh-CN
timezone: Asia/Shanghai

# 扩展配置
theme: anzhiyu
url: https://${GITHUB_USERNAME}.github.io
root: /
permalink: :year/:month/:title/

# 部署设置 (使用 SSH 协议)
deploy:
  type: git
  repo: ${GIT_REPO}
  branch: ${DEPLOY_BRANCH}
  message: "Auto deployed by Hexo"
EOF

# 应用主题配置
echo "⚙ 应用主题设置..."
cp themes/anzhiyu/_config.yml _config.anzhiyu.yml
sed -i "s/#3b70fc/${THEME_COLOR}/g" _config.anzhiyu.yml

# 安装依赖
echo "⚙ 安装必要插件..."
npm install hexo-deployer-git hexo-renderer-pug hexo-renderer-stylus --save

# 自动部署测试
echo "🚀 尝试首次部署..."
hexo clean && hexo g --deploy

# 完成提示
echo -e "\n\033[32m✔ 部署成功！访问地址：\033[4mhttps://${GITHUB_USERNAME}.github.io\033[0m"
