#!/bin/bash
#
# diy-part1.sh — OpenWrt / ImmortalWrt 自定义包合并脚本
#

set -e

# 1. 切换到 OpenWrt 源码目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENWRT_DIR="$SCRIPT_DIR/openwrt"

if [ ! -d "$OPENWRT_DIR" ]; then
    echo "❌ OpenWrt source directory not found at $OPENWRT_DIR"
    exit 1
fi

cd "$OPENWRT_DIR"
echo "📁 Entered OpenWrt source directory: $PWD"

# 2. 【关键修复】确保 feeds.conf.default 中的核心源没有被注释掉
# 这一步会把 helloworld, packages, luci 等被注释的源全部解除注释，解决 libpam, lm-sensors 等缺失问题
if [ -f "feeds.conf.default" ]; then
    echo "🔓 Uncommenting all feeds in feeds.conf.default..."
    sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*packages\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*luci\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*routing\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*telephony\)/\1/' feeds.conf.default
fi

# 3. 【调整顺序】先下载自定义插件 (Cloning custom packages)
# 必须放在 feeds install 之前，这样 feeds 脚本才能检测到这些新包的依赖关系
echo "📥 Cloning custom packages / themes..."

# 使用判断语句防止重复 clone 导致脚本报错
function git_clone_path() {
    local url=$1
    local dir=$2
    if [ ! -d "$dir" ]; then
        git clone "$url" "$dir"
        echo "✅ Cloned $dir"
    else
        echo "⚠️ $dir already exists, skipping..."
    fi
}

git_clone_path "https://github.com/eamonxg/luci-theme-aurora" "package/luci-theme-aurora"
git_clone_path "https://github.com/timsaya/luci-app-bandix" "package/luci-app-bandix"
git_clone_path "https://github.com/timsaya/openwrt-bandix" "package/openwrt-bandix"

# 4. 【关键步骤】更新并安装 Feeds
# 此时 package 目录下已经有了自定义包，install -a 会自动处理所有依赖
echo "🔄 Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 5. 合并自定义配置
PKG_FRAGMENT="$SCRIPT_DIR/my_packages.config"
if [ -f "$PKG_FRAGMENT" ]; then
    echo "📦 Merging custom package config fragment..."
    cat "$PKG_FRAGMENT" >> .config
fi

# 6. 【最后执行】生成配置 (Running defconfig)
# 放在最后是为了确保所有新加的包和 feeds 都在 .config 中生效
echo "⚙️ Running defconfig..."
make defconfig

echo "✅ diy-part1.sh completed successfully!"
