#!/bin/bash
# Hexo博客管理脚本（Linux优化版）
# 最后更新：2024-06-20

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

HEXO_DIR="${HEXO_DIR:-hexo}"
CONFIG_FILE="${HEXO_DIR}/.hexo-config"

function show_menu() {
    clear
    echo -e "${CYAN}"
    echo "┌──────────────────────────────────────────────┐"
    echo "│           Hexo 博客管理控制台               │"
    echo "│             (Linux优化版)                   │"
    echo "└──────────────────────────────────────────────┘"
    echo -e "${NC}"
    echo -e "${YELLOW}1. 删除默认文章"
    echo -e "2. 创建新文章"
    echo -e "3. 备份博客"
    echo -e "4. 恢复博客"
    echo -e "5. 更新主题"
    echo -e "6. 重新部署"
    echo -e "0. 退出${NC}"
    echo
}

function delete_default_posts() {
    echo -e "\n${YELLOW}▶ 删除默认文章...${NC}"
    find "${HEXO_DIR}/source/_posts" -name "hello-world.md" -delete && \
    echo -e "${GREEN}✓ 已删除默认文章${NC}" || \
    echo -e "${RED}✗ 删除失败或文件不存在${NC}"
}

function create_new_post() {
    read -rp "请输入文章标题: " title
    (cd "${HEXO_DIR}" && hexo new "${title}") && \
    echo -e "${GREEN}✓ 文章已创建: ${HEXO_DIR}/source/_posts/${title// /-}.md${NC}" || \
    echo -e "${RED}✗ 创建失败${NC}"
}

function backup_blog() {
    local backup_name="hexo_backup_$(date +%Y%m%d%H%M%S).tar.gz"
    echo -e "\n${YELLOW}▶ 备份博客数据...${NC}"
    tar -czf "${backup_name}" "${HEXO_DIR}" && \
    echo -e "${GREEN}✓ 备份完成: ${backup_name}${NC}" || \
    echo -e "${RED}✗ 备份失败${NC}"
}

function update_theme() {
    echo -e "\n${YELLOW}▶ 更新主题...${NC}"
    (cd "${HEXO_DIR}/themes/anzhiyu" && git pull) && \
    echo -e "${GREEN}✓ 主题更新完成${NC}" || \
    echo -e "${RED}✗ 更新失败${NC}"
}

# 主循环
while true; do
    show_menu
    read -rp "请选择操作 [0-6]: " choice

    case $choice in
        1) delete_default_posts ;;
        2) create_new_post ;;
        3) backup_blog ;;
        4) echo -e "${YELLOW}请手动解压备份文件到当前目录${NC}" ;;
        5) update_theme ;;
        6) (cd "${HEXO_DIR}" && hexo clean && hexo deploy) ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选择${NC}" ;;
    esac

    read -rp "按回车键继续..."
done
