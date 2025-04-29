#!/bin/bash
set -e  # 遇到错误立即停止执行

# ========================
# 用户配置区
# ========================
GITHUB_USERNAME="RiYueRY"    # 修改为你的GitHub用户名
SITE_TITLE="日月R.Y.的小窝"    # 网站标题

# ========================
# 核心执行部分（修复版）
# ========================

# 安装Hexo脚手架
echo "⚙️ 安装Hexo CLI..."
npm install hexo-cli -g

# 初始化项目
echo "🛠️ 初始化Hexo项目..."
[ -d "hexo" ] && rm -rf hexo
hexo init hexo
cd hexo

# 安装主题
echo "🎨 下载并安装 anzhiyu 主题..."
git clone -b main \
  "https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git" \
  "themes/anzhiyu" --depth=1

# 安装主题依赖（关键修复）
echo "📦 安装主题必要依赖..."
cd themes/anzhiyu
if [ -f "package.json" ]; then
  npm install --production
fi
cd ../../

# 修改核心配置
echo "⚙️ 配置基本参数..."
sed -i "s/^title:.*/title: ${SITE_TITLE}/" _config.yml
sed -i "s/^theme:.*/theme: anzhiyu/" _config.yml

# 修复部署配置（增强版）
echo "🔧 配置部署信息..."
DEPLOY_CONFIG="deploy:\\
  type: git\\
  repo: git@github.com:${GITHUB_USERNAME}/${GITHUB_USERNAME}.github.io.git\\
  branch: main"

awk -v conf="$DEPLOY_CONFIG" '
BEGIN { replaced=0 }
/^deploy:/ {
  print conf
  replaced=1
  # 跳过原有缩进内容
  while (getline) {
    if ($0 ~ /^[^[:blank:]]/) { print; break }
  }
  next
}
{ print }
END {
  if (!replaced) { print conf }
}
' _config.yml > tmp && mv tmp _config.yml

# 安装必要插件（关键补充）
echo "📦 安装编译依赖..."
npm install --save \
  hexo-deployer-git \
  hexo-renderer-marked \
  hexo-renderer-stylus \
  hexo-renderer-pug

# 生成前验证
echo "🔍 验证配置完整性..."
grep -E "title:|theme:" _config.yml
grep -A3 "^deploy:" _config.yml

# 生成静态文件（增加调试）
echo "🚀 生成静态文件（调试模式）..."
hexo clean
hexo generate --debug

# 验证生成结果
echo "🔍 检查生成内容..."
[ -d "public" ] || { echo "错误：未生成public目录"; exit 1; }
[ -f "public/index.html" ] || { echo "错误：缺少首页文件"; exit 1; }
echo "✅ 生成文件统计："
find public -type f | wc -l

# 部署到GitHub
echo "📤 正在部署..."
hexo deploy

echo "🎉 部署完成！访问地址：https://${GITHUB_USERNAME}.github.io"
