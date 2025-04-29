#!/bin/bash

# ========================
# 用户配置区
# ========================
GITHUB_USERNAME="RiYueRY"  # 修改为你的GitHub用户名

# ========================
# 核心执行部分
# ========================

# 安装Hexo脚手架
npm install hexo-cli -g

# 初始化项目
hexo init hexo
cd hexo

# 下载主题
git clone https://github.com/anzhiyu-c/hexo-theme-anzhiyu.git themes/anzhiyu

# 修改主题配置
sed -i "s/^theme:.*/theme: anzhiyu/" _config.yml

# 替换部署配置 (核心修复)
awk -v user="$GITHUB_USERNAME" '
/deploy:/ {
    print "deploy:"
    print "  type: git"
    print "  repo: https://github.com/" user "/" user ".github.io.git"
    print "  branch: main"
    while (getline > 0) {
        if (/^[^[:blank:]]/) { print; break }
    }
    next
}
{ print }
' _config.yml > tmp && mv tmp _config.yml

# 安装部署插件
npm install hexo-deployer-git --save

# 生成并部署
hexo clean && hexo g --deploy

echo "部署完成！访问地址：https://${GITHUB_USERNAME}.github.io"
