#!/bin/bash
# Hexo 高级配置管理脚本
# 功能：多维度博客配置管理
# 最后更新：2024-06-20

# 设置颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认配置
HEXO_DIR="hexo"                    # Hexo项目目录
CONFIG_FILE=".hexo-config"         # 配置文件路径
BACKUP_DIR="hexo_backups"          # 备份目录

# 加载保存的配置
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

function show_menu() {
  clear
  echo -e "${BLUE}"
  echo "╔════════════════════════════════════════════════╗"
  echo "║            Hexo 高级配置管理控制台             ║"
  echo "╚════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "${CYAN}1. 文章管理"
  echo -e "2. 主题定制"
  echo -e "3. 部署设置"
  echo -e "4. SEO优化"
  echo -e "5. 社交网络配置"
  echo -e "6. 插件管理"
  echo -e "7. 备份与恢复"
  echo -e "8. 系统设置"
  echo -e "0. 退出脚本${NC}"
  echo -e ""
}

# --------------------------
# 文章管理功能
# --------------------------
function post_management() {
  while true; do
    clear
    echo -e "${CYAN}=== 文章管理 ===${NC}"
    echo -e "1. 删除默认文章"
    echo -e "2. 创建占位文章"
    echo -e "3. 批量重命名文章"
    echo -e "4. 返回主菜单"
    read -rp "请输入选项: " choice

    case $choice in
      1)
        remove_default_posts
        ;;
      2)
        create_placeholder_post
        ;;
      3)
        batch_rename_posts
        ;;
      4)
        return
        ;;
      *)
        echo -e "${RED}无效选项${NC}"
        ;;
    esac
    echo -e "\n按回车键继续..."
    read -r
  done
}

# --------------------------
# 主题定制功能
# --------------------------
function theme_customization() {
  while true; do
    clear
    echo -e "${CYAN}=== 主题定制 ===${NC}"
    echo -e "1. 修改主题颜色"
    echo -e "2. 更新网站图标"
    echo -e "3. 调整布局设置"
    echo -e "4. 返回主菜单"
    read -rp "请输入选项: " choice

    case $choice in
      1)
        change_theme_color
        ;;
      2)
        update_favicon
        ;;
      3)
        adjust_layout
        ;;
      4)
        return
        ;;
      *)
        echo -e "${RED}无效选项${NC}"
        ;;
    esac
    echo -e "\n按回车键继续..."
    read -r
  done
}

# --------------------------
# 部署设置功能
# --------------------------
function deployment_settings() {
  while true; do
    clear
    echo -e "${CYAN}=== 部署设置 ===${NC}"
    echo -e "1. 修改部署分支"
    echo -e "2. 更新仓库地址"
    echo -e "3. 设置部署消息"
    echo -e "4. 返回主菜单"
    read -rp "请输入选项: " choice

    case $choice in
      1)
        change_deploy_branch
        ;;
      2)
        update_repo_url
        ;;
      3)
        set_deploy_message
        ;;
      4)
        return
        ;;
      *)
        echo -e "${RED}无效选项${NC}"
        ;;
    esac
    echo -e "\n按回车键继续..."
    read -r
  done
}

# --------------------------
# 新增功能实现示例
# --------------------------
function change_theme_color() {
  echo -e "${YELLOW}当前主题颜色: ${THEME_COLOR:-未设置}${NC}"
  read -rp "输入新的HEX颜色值 (例如#2a8cff): " new_color
  if [[ $new_color =~ ^#[0-9A-Fa-f]{6}$ ]]; then
    sed -i "s/^theme_color=.*/theme_color='$new_color'/" "$CONFIG_FILE"
    echo -e "${GREEN}✓ 主题颜色已更新${NC}"
  else
    echo -e "${RED}✗ 无效的颜色格式${NC}"
  fi
}

function update_favicon() {
  echo -e "${YELLOW}当前网站图标: ${FAVICON_URL:-未设置}${NC}"
  read -rp "输入新图标路径 (相对于source目录): " new_icon
  if [ -f "$HEXO_DIR/source/$new_icon" ]; then
    sed -i "s|^favicon_url=.*|favicon_url='$new_icon'|" "$CONFIG_FILE"
    echo -e "${GREEN}✓ 网站图标已更新${NC}"
  else
    echo -e "${RED}✗ 文件不存在: $HEXO_DIR/source/$new_icon${NC}"
  fi
}

function create_placeholder_post() {
  read -rp "输入文章标题: " title
  hexo new "$title" --path "guides/${title// /-}"
  echo -e "${GREEN}✓ 占位文章已创建于 source/_posts/guides/${title// /-}.md${NC}"
}

function batch_rename_posts() {
  echo -e "${YELLOW}正在扫描文章...${NC}"
  find "$HEXO_DIR/source/_posts" -name "*.md" -print0 | while IFS= read -r -d '' file; do
    new_name=$(basename "$file" | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]')
    mv "$file" "$(dirname "$file")/$new_name"
  done
  echo -e "${GREEN}✓ 已完成批量重命名${NC}"
}

function change_deploy_branch() {
  echo -e "${YELLOW}当前部署分支: ${DEPLOY_BRANCH}${NC}"
  read -rp "输入新的部署分支: " new_branch
  if [[ $new_branch =~ ^[a-zA-Z0-9_-]+$ ]]; then
    sed -i "s/^deploy_branch=.*/deploy_branch='$new_branch'/" "$CONFIG_FILE"
    echo -e "${GREEN}✓ 部署分支已更新${NC}"
  else
    echo -e "${RED}✗ 无效的分支名称${NC}"
  fi
}

# --------------------------
# 备份与恢复功能
# --------------------------
function backup_restore() {
  while true; do
    clear
    echo -e "${CYAN}=== 备份与恢复 ===${NC}"
    echo -e "1. 创建完整备份"
    echo -e "2. 从备份恢复"
    echo -e "3. 列出所有备份"
    echo -e "4. 返回主菜单"
    read -rp "请输入选项: " choice

    case $choice in
      1)
        create_backup
        ;;
      2)
        restore_backup
        ;;
      3)
        list_backups
        ;;
      4)
        return
        ;;
      *)
        echo -e "${RED}无效选项${NC}"
        ;;
    esac
    echo -e "\n按回车键继续..."
    read -r
  done
}

function create_backup() {
  local timestamp=$(date +%Y%m%d-%H%M%S)
  mkdir -p "$BACKUP_DIR"
  tar -czf "$BACKUP_DIR/hexo-backup-$timestamp.tar.gz" "$HEXO_DIR"
  echo -
