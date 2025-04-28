#!/bin/bash
# Hexo + Anzhiyu 主题一键配置脚本（优化版）
# 最后更新：2024-06-15

# ------------ 用户配置区 ------------
# 基础信息
SITE_TITLE="日月R.Y.的小窝"             # 【必填】网站主标题
SITE_SUBTITLE="日月R.Y."                # 【必填】网站副标题
SITE_AUTHOR="RiYueRY"                   # 【必填】作者姓名
SITE_DESCRIPTION="记录技术学习点滴"      # 【推荐】网站描述（SEO用）
SITE_KEYWORDS="编程,技术,博客"          # 【推荐】关键词，逗号分隔
SITE_LANGUAGE="zh-CN"                   # 【必填】语言代码(zh-CN/en)
SITE_TIMEZONE="Asia/Shanghai"           # 【必填】时区(Asia/Shanghai/UTC)

# 外观设置
THEME_COLOR="#2a8cff"                   # 【可选】主题主色值
FAVICON_URL="/images/favicon.ico"       # 【可选】网站图标路径

# 部署配置
DEPLOY_BRANCH="main"                    # 【必填】部署分支(main/gh-pages)
# -----------------------------------

# 初始化设置
set -euo pipefail
trap 'echo -e "\n\033[31m✗ 脚本执行中断，请检查错误\033[0m"; exit 1' INT TERM

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

# 检查并安装依赖
check_dependencies() {
    local missing=()
    
    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        missing+=("Node.js")
    fi
    
    # 检查 Git
    if ! command -v git &> /dev/null; then
        missing+=("Git")
    fi
    
    # 检查 npm
    if ! command -v npm &> /dev/null; then
        missing+=("npm")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}✗ 缺少必要依赖: ${missing[*]}${RESET}"
        echo -e "${BLUE}正在尝试安装依赖...${RESET}"
        
        # 尝试自动安装 (Ubuntu/Debian)
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y nodejs npm git || {
                echo -e "${RED}✗ 依赖安装失败，请手动安装后再运行脚本${RESET}"
                exit 1
            }
        else
            echo -e "${RED}✗ 请手动安装以下依赖后重新运行脚本: ${missing[*]}${RESET}"
            exit 1
        fi
    fi
}

# 显示配置确认
show_config() {
    echo -e "${BLUE}========================================"
    echo "           Hexo 博客配置信息"
    echo "========================================"
    echo -e "主标题: ${GREEN}${SITE_TITLE}${BLUE}"
    echo "副标题: ${SITE_SUBTITLE}"
    echo "作者: ${SITE_AUTHOR}"
    echo "描述: ${SITE_DESCRIPTION}"
    echo "关键词: ${SITE_KEYWORDS}"
    echo "语言: ${SITE_LANGUAGE}"
    echo "时区: ${SITE_TIMEZONE}"
    echo "主题颜色: ${THEME_COLOR:-默认}"
    echo "部署分支: ${DEPLOY_BRANCH}"
    echo -e "========================================${RESET}"
    
    read -rp "确认配置是否正确? [Y/n] " confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
        echo -e "${YELLOW}✗ 用户取消执行${RESET}"
        exit 0
    fi
}

# 主执行函数
main() {
    echo -e "${BLUE}▶ 开始自动化博客配置...${RESET}"
    
    # 检查依赖
    check_dependencies
    
    # 显示配置确认
    show_config
    
    # 自动获取仓库信息
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
    GITHUB_USER=$(git config user.name || echo "${SITE_AUTHOR}")
    
    # 配置 Git 身份
    git config --global user.name "${SITE_AUTHOR}"
    git config --global user.email "${GITHUB_USER}@users.noreply.github.com"
    
    # 安装 Hexo 环境
    if ! command -v hexo &> /dev/null; then
        echo -e "${BLUE}⚙ 安装 hexo-cli...${RESET}"
        npm install -g hexo-cli --silent
    fi
    
    # 初始化项目
    echo -e "${BLUE}⚙ 初始化 Hexo 项目...${RESET}"
    [ -d "hexo" ] && rm -rf hexo
    hexo init hexo --silent
    cd hexo || exit 1
    
    # 安装主题
    echo -e "${BLUE}⚙ 下载 Anzhiyu 主题...${RESET}"
    git clone -b main --depth 1 https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu
    
    # 生成核心配置文件
    echo -e "${BLUE}⚙ 生成详细配置文件...${RESET}"
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
  repo: ${REPO_URL:-"请手动设置仓库URL"}
  branch: ${DEPLOY_BRANCH}
  message: "Auto deployed by Hexo"

# 主题配置
theme: anzhiyu
EOF
    
    # 应用主题配置
    echo -e "${BLUE}⚙ 配置主题参数...${RESET}"
    cp themes/anzhiyu/_config.yml _config.anzhiyu.yml
    
    # 设置主题颜色
    if [ -n "${THEME_COLOR}" ]; then
        sed -i "s/#3b70fc/${THEME_COLOR}/g" _config.anzhiyu.yml
    fi
    
    # 设置网站图标
    if [ -n "${FAVICON_URL}" ]; then
        sed -i "s|/img/favicon.ico|${FAVICON_URL}|g" _config.anzhiyu.yml
    fi
    
    # 安装必要插件
    echo -e "${BLUE}⚙ 安装依赖组件...${RESET}"
    npm install hexo-deployer-git hexo-renderer-pug hexo-renderer-stylus --silent
    
    # 创建默认目录结构
    echo -e "${BLUE}⚙ 初始化资源目录...${RESET}"
    mkdir -p source/_posts source/images
    
    # 执行部署
    echo -e "${BLUE}🚀 开始部署到 ${DEPLOY_BRANCH} 分支...${RESET}"
    hexo clean && hexo g --deploy
    
    # 完成提示
    echo -e "\n${GREEN}✔ 部署成功！${RESET}"
    echo -e "${BLUE}========================================"
    echo "访问地址：https://${GITHUB_USER}.github.io"
    echo "后续建议操作："
 
