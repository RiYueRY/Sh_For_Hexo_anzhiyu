#!/bin/bash
# Hexo + Anzhiyu 主题一键配置脚本（Linux优化版）
# 最后更新：2024-06-20

# 设置颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为root用户
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}错误：请不要使用root用户运行此脚本${NC}"
    exit 1
fi

# ------------ 用户配置区 ------------
SITE_TITLE="我的技术博客"              # 网站主标题
SITE_SUBTITLE="记录与分享"            # 网站副标题
SITE_AUTHOR="$(whoami)"              # 使用当前用户名
SITE_DESCRIPTION="个人技术博客"       # 网站描述
SITE_KEYWORDS="技术,博客,Linux"      # 关键词
SITE_LANGUAGE="zh-CN"                # 语言
SITE_TIMEZONE="Asia/Shanghai"        # 时区

THEME_COLOR="#3b70fc"                # 主题色
DEPLOY_BRANCH="main"                 # 部署分支
# -----------------------------------

function show_header() {
    clear
    echo -e "${BLUE}"
    echo "┌──────────────────────────────────────────────┐"
    echo "│           Hexo 博客自动化安装工具           │"
    echo "│             (Linux优化版)                   │"
    echo "└──────────────────────────────────────────────┘"
    echo -e "${NC}"
}

function check_dependencies() {
    echo -e "${YELLOW}▶ 检查系统依赖...${NC}"
    local missing=0
    declare -A deps=(
        ["git"]="git --version"
        ["node"]="node --version"
        ["npm"]="npm --version"
    )

    for dep in "${!deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${RED}✗ 未安装 $dep${NC}"
            missing=1
        else
            echo -e "${GREEN}✓ 已安装 $dep ($(${deps[$dep]} 2>&1 | head -n 1))${NC}"
        fi
    done

    [ $missing -eq 1 ] && {
        echo -e "\n${YELLOW}运行以下命令安装依赖：${NC}"
        echo "Ubuntu/Debian: sudo apt-get install git nodejs npm"
        echo "CentOS/RHEL:   sudo yum install git nodejs npm"
        exit 1
    }
}

function init_hexo() {
    echo -e "\n${YELLOW}▶ 初始化Hexo项目...${NC}"
    [ -d "hexo" ] && {
        echo -e "${YELLOW}⚠ 存在旧的hexo目录，正在备份并删除...${NC}"
        mv hexo "hexo_backup_$(date +%Y%m%d%H%M%S)"
    }
    
    echo -e "${BLUE}正在安装Hexo脚手架...${NC}"
    npm install -g hexo-cli || {
        echo -e "${RED}Hexo安装失败，请检查npm权限${NC}"
        exit 1
    }

    hexo init hexo && cd hexo || {
        echo -e "${RED}Hexo初始化失败${NC}"
        exit 1
    }
    npm install
}

function install_theme() {
    echo -e "\n${YELLOW}▶ 安装Anzhiyu主题...${NC}"
    git clone --depth=1 https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu
    
    echo -e "${BLUE}正在安装主题依赖...${NC}"
    npm install hexo-renderer-pug hexo-renderer-stylus --save
}

function configure_blog() {
    echo -e "\n${YELLOW}▶ 配置博客设置...${NC}"
    # 生成主配置
    cat > _config.yml <<EOF
# Hexo配置
title: ${SITE_TITLE}
subtitle: ${SITE_SUBTITLE}
description: ${SITE_DESCRIPTION}
keywords: ${SITE_KEYWORDS}
author: ${SITE_AUTHOR}
language: ${SITE_LANGUAGE}
timezone: ${SITE_TIMEZONE}

url: https://${GITHUB_USER:-user}.github.io
theme: anzhiyu

deploy:
  type: git
  repo: ${REPO_URL:-git@github.com:user/repo.git}
  branch: ${DEPLOY_BRANCH}
EOF

    # 配置主题
    cp themes/anzhiyu/_config.yml _config.anzhiyu.yml
    sed -i "s/#3b70fc/${THEME_COLOR}/g" _config.anzhiyu.yml
    echo -e "${GREEN}✓ 主题颜色已设置为: ${THEME_COLOR}${NC}"
}

function deploy() {
    echo -e "\n${YELLOW}▶ 开始部署...${NC}"
    npm install hexo-deployer-git --save
    hexo clean && hexo deploy && \
    echo -e "\n${GREEN}✔ 部署成功！访问地址: https://${GITHUB_USER:-user}.github.io${NC}" || \
    echo -e "${RED}✗ 部署失败${NC}"
}

# 主流程
show_header
check_dependencies
init_hexo
install_theme
configure_blog
deploy
