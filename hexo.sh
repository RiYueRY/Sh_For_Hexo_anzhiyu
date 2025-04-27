#!/bin/bash
# Hexo + Anzhiyu 主题一键配置脚本（GitHub Codespaces 优化版）
# 最后更新：2024-06-20
# 使用方法：在 Codespaces 中运行 ./hexo.sh

# 设置颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ------------ 用户配置区 ------------
# 基础信息
SITE_TITLE="日月R.Y.的小窝"                  # 【必填】网站主标题
SITE_SUBTITLE="日月R.Y."                     # 【必填】网站副标题
SITE_AUTHOR="RiYueRY"                        # 【必填】作者姓名
SITE_DESCRIPTION="记录技术学习点滴"           # 【推荐】网站描述（SEO用）
SITE_KEYWORDS="编程,技术,博客"               # 【推荐】关键词，逗号分隔
SITE_LANGUAGE="zh-CN"                        # 【必填】语言代码(zh-CN/en)
SITE_TIMEZONE="Asia/Shanghai"                # 【必填】时区(Asia/Shanghai/UTC)

# 外观设置
THEME_COLOR="#2a8cff"                        # 【可选】主题主色值
FAVICON_URL="/images/favicon.ico"            # 【可选】网站图标路径

# 部署配置
DEPLOY_BRANCH="main"                         # 【必填】部署分支(main/gh-pages)
# -----------------------------------

function show_header() {
  echo -e "${BLUE}"
  echo "╔════════════════════════════════════════════════╗"
  echo "║      Hexo + Anzhiyu 一键配置脚本               ║"
  echo "║      专为 GitHub Codespaces 优化               ║"
  echo "╚════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

function check_environment() {
  echo -e "${YELLOW}▶ 检查运行环境...${NC}"
  
  # 检查是否在 Codespaces 中
  if [[ -n "${CODESPACES}" ]]; then
    echo -e "${GREEN}✓ 检测到 GitHub Codespaces 环境${NC}"
  else
    echo -e "${YELLOW}⚠ 不在 GitHub Codespaces 环境中运行，某些功能可能受限${NC}"
  fi

  # 检查必要的命令
  local missing=0
  for cmd in git node npm; do
    if ! command -v $cmd &> /dev/null; then
      echo -e "${RED}✗ 未找到 $cmd 命令${NC}"
      missing=1
    else
      echo -e "${GREEN}✓ 已安装 $cmd ($($cmd --version 2>&1 | head -n 1))${NC}"
    fi
  done

  if [[ $missing -ne 0 ]]; then
    echo -e "${RED}错误：缺少必要的依赖，请先安装上述工具${NC}"
    exit 1
  fi
}

function validate_input() {
  echo -e "${YELLOW}▶ 验证用户配置...${NC}"
  
  local valid=1
  
  # 检查必填项
  [[ -z "$SITE_TITLE" ]] && { echo -e "${RED}✗ SITE_TITLE 不能为空${NC}"; valid=0; }
  [[ -z "$SITE_AUTHOR" ]] && { echo -e "${RED}✗ SITE_AUTHOR 不能为空${NC}"; valid=0; }
  [[ -z "$DEPLOY_BRANCH" ]] && { echo -e "${RED}✗ DEPLOY_BRANCH 不能为空${NC}"; valid=0; }

  # 检查分支名称有效性
  if ! [[ "$DEPLOY_BRANCH" =~ ^(main|gh-pages)$ ]]; then
    echo -e "${RED}✗ DEPLOY_BRANCH 必须是 'main' 或 'gh-pages'${NC}"
    valid=0
  fi

  if [[ $valid -eq 0 ]]; then
    echo -e "${RED}错误：请修正上述配置问题后重试${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}✓ 所有配置验证通过${NC}"
}

function setup_hexo() {
  echo -e "${YELLOW}▶ 开始配置 Hexo...${NC}"
  
  # 自动获取仓库信息
  REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
  GITHUB_USER=$(git config user.name || echo "anonymous")
  
  # 配置 Git 身份
  git config --global user.name "${SITE_AUTHOR}"
  git config --global user.email "${GITHUB_USER}@users.noreply.github.com"
  echo -e "${GREEN}✓ 配置 Git 用户为: ${SITE_AUTHOR} <${GITHUB_USER}@users.noreply.github.com>${NC}"

  # 安装 Hexo CLI
  if ! command -v hexo &> /dev/null; then
    echo -e "${BLUE}⚙ 安装 hexo-cli...${NC}"
    npm install -g hexo-cli
  fi
  echo -e "${GREEN}✓ Hexo 版本: $(hexo version)${NC}"

  # 初始化项目
  echo -e "${BLUE}⚙ 初始化 Hexo 项目...${NC}"
  [ -d "hexo" ] && { echo -e "${YELLOW}⚠ 检测到现有 hexo 目录，将删除重建${NC}"; rm -rf hexo; }
  hexo init hexo
  cd hexo || { echo -e "${RED}✗ 进入 hexo 目录失败${NC}"; exit 1; }
  npm install

  # 安装主题
  echo -e "${BLUE}⚙ 下载 Anzhiyu 主题...${NC}"
  git clone -b main https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu

  # 生成核心配置文件
  echo -e "${BLUE}⚙ 生成详细配置文件...${NC}"
  cat > _config.yml << EOF
# ======================
# Hexo 主配置文件
# 由自动化脚本生成
# ======================

# 站点元信息
title: ${SITE_TITLE}
subtitle: ${SITE_SUBTITLE}
description: ${SITE_DESCRIPTION}
keywords: ${SITE_KEYWORDS}
author: ${SITE_AUTHOR}
language: ${SITE_LANGUAGE}
timezone: ${SITE_TIMEZONE}

# 网址配置
url: https://${GITHUB_USER}.github.io
root: /
permalink: :year/:month/:title/
permalink_defaults:

# 扩展功能
feed:
  type: atom
  path: atom.xml
  limit: 20
sitemap:
  path: sitemap.xml

# 部署设置
deploy:
  type: git
  repo: ${REPO_URL}
  branch: ${DEPLOY_BRANCH}
  message: "Auto deployed by Hexo"

# 主题配置
theme: anzhiyu
EOF

  # 应用主题配置
  echo -e "${BLUE}⚙ 配置主题参数...${NC}"
  cp themes/anzhiyu/_config.yml _config.anzhiyu.yml

  # 设置主题颜色
  if [ -n "${THEME_COLOR}" ]; then
    sed -i "s/#3b70fc/${THEME_COLOR}/g" _config.anzhiyu.yml
    echo -e "${GREEN}✓ 设置主题颜色为: ${THEME_COLOR}${NC}"
  fi

  # 设置网站图标
  if [ -n "${FAVICON_URL}" ]; then
    sed -i "s|/img/favicon.ico|${FAVICON_URL}|g" _config.anzhiyu.yml
    echo -e "${GREEN}✓ 设置网站图标为: ${FAVICON_URL}${NC}"
  fi

  # 安装必要插件
  echo -e "${BLUE}⚙ 安装依赖组件...${NC}"
  npm install hexo-deployer-git hexo-renderer-pug hexo-renderer-stylus --save

  # 创建默认目录结构
  echo -e "${BLUE}⚙ 初始化资源目录...${NC}"
  mkdir -p source/_posts source/images
}

function deploy_blog() {
  echo -e "${YELLOW}▶ 开始部署博客...${NC}"
  
  # 执行部署
  echo -e "${BLUE}⚙ 生成静态文件并部署...${NC}"
  hexo clean && hexo g --deploy
  
  # 检查部署结果
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 部署成功完成！${NC}"
  else
    echo -e "${RED}✗ 部署过程中出现错误${NC}"
    exit 1
  fi
}

function show_footer() {
  echo -e "${BLUE}"
  echo "╔════════════════════════════════════════════════╗"
  echo "║                配置完成！                      ║"
  echo "╚════════════════════════════════════════════════╝"
  echo -e "${NC}"
  
  echo -e "\n${GREEN}✔ 所有操作已完成！${NC}"
  echo -e "\n${YELLOW}════════════════ 后续操作指南 ════════════════${NC}"
  echo -e "${BLUE}1. 添加新文章:${NC} hexo new \"文章标题\""
  echo -e "${BLUE}2. 本地预览:${NC} hexo server --port 8080"
  echo -e "${BLUE}3. 修改主题配置:${NC} 编辑 _config.anzhiyu.yml"
  echo -e "${BLUE}4. 重新部署:${NC} hexo clean && hexo g --deploy"
  echo -e "\n${YELLOW}════════════════ 访问信息 ════════════════${NC}"
  echo -e "${GREEN}博客地址:${NC} https://${GITHUB_USER}.github.io"
  echo -e "${GREEN}仓库地址:${NC} ${REPO_URL}"
  echo -e "\n${YELLOW}感谢使用本脚本！Happy Blogging!${NC}"
}

# 主执行流程
show_header
check_environment
validate_input
setup_hexo
deploy_blog
show_footer
