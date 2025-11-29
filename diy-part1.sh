#!/bin/bash
#
# diy-part1.sh — 适配 Padavanonly 源码的依赖修复脚本
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

# 2. 【核心修复】修改 feeds.conf.default
# Padavanonly 源码默认注释了官方源，导致缺少 libpam, luci-compat 等库
# 这里我们使用 sed 命令强制解除注释
if [ -f "feeds.conf.default" ]; then
    echo "🔓 Uncommenting standard feeds..."
    # 解除 packages, luci, routing, telephony 的注释
    sed -i 's/^#\(.*packages\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*luci\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*routing\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*telephony\)/\1/' feeds.conf.default
    
    # 检查一下内容，确保修改生效
    echo "📄 Content of feeds.conf.default (Head 5 lines):"
    head -n 5 feeds.conf.default
fi

# 3. 下载自定义插件 (Bandix & Aurora)
echo "📥 Cloning custom packages..."

# 定义下载函数
function git_clone_path() {
    local url=$1
    local dir=$2
    if [ ! -d "$dir" ]; then
        git clone --depth 1 "$url" "$dir"
        echo "✅ Cloned $dir"
    else
        echo "⚠️ $dir already exists, skipping..."
    fi
}

# 下载你的插件
git_clone_path "https://github.com/eamonxg/luci-theme-aurora" "package/luci-theme-aurora"
git_clone_path "https://github.com/timsaya/luci-app-bandix" "package/luci-app-bandix"
git_clone_path "https://github.com/timsaya/openwrt-bandix" "package/openwrt-bandix"

# 4. 【关键步骤】更新并安装 Feeds
# 这一步会拉取刚刚解除注释的官方源，并解析自定义插件的依赖
echo "🔄 Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 5. 【补救措施】强制安装可能遗漏的核心依赖
# 针对你之前的报错日志，手动确保这些库被安装
echo "💉 Ensuring core dependencies are installed..."
./scripts/feeds install libpam libtirpc lm-sensors pciutils usbutils luci-compat luci-lib-jsonc || true

# 6. 应用自定义配置
PKG_FRAGMENT="$SCRIPT_DIR/my_packages.config"
if [ -f "$PKG_FRAGMENT" ]; then
    echo "📦 Merging custom package config..."
    cat "$PKG_FRAGMENT" >> .config
fi

# 7. 生成配置
echo "⚙️ Running defconfig..."
make defconfig

echo "✅ diy-part1.sh completed successfully!"
