#!/bin/bash
#
# diy-part1.sh — OpenWrt / ImmortalWrt 自定义包合并脚本
# 兼容 GitHub Actions 与 Codespace
#

set -e

# 切换到 workflow clone 的源码目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENWRT_DIR="$SCRIPT_DIR/openwrt"

if [ ! -d "$OPENWRT_DIR" ]; then
    echo "❌ OpenWrt source directory not found at $OPENWRT_DIR"
    echo "ℹ️ Make sure workflow clone the full ImmortalWrt/OpenWrt source into openwrt/"
    exit 1
fi

cd "$OPENWRT_DIR"
echo "📁 Entered OpenWrt source directory: $PWD"

# 更新并安装所有 feeds
echo "🔄 Updating and installing feeds..."
if [ -f "./scripts/feeds" ]; then
    ./scripts/feeds update -a
    ./scripts/feeds install -a
else
    echo "⚠️ scripts/feeds not found, skipping feeds update/install"
fi

# 合并自定义 package 配置 fragment
PKG_FRAGMENT="$SCRIPT_DIR/my_packages.config"
if [ -f "$PKG_FRAGMENT" ]; then
    echo "📦 Merging custom package config fragment from $PKG_FRAGMENT"
    cat "$PKG_FRAGMENT" >> .config
else
    echo "⚠️ Warning: my_packages.config not found — skipping custom packages"
fi

# 做一次 defconfig，确保 config 与 kernel / target 一致
echo "⚙️ Running defconfig..."
yes "" | make defconfig

# 添加自定义 packages / themes
echo "📥 Cloning custom packages / themes..."
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora || true
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix || true
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix || true

echo "✅ diy-part1.sh completed successfully!"
