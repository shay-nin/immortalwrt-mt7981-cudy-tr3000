#!/bin/bash
#
# diy-part1.sh — OpenWrt / ImmortalWrt 自定义包合并脚本
# 兼容 GitHub Actions 与 Codespace
#

set -e

# 自动切换到 OpenWrt 源码根目录
# 假设源码目录名为 openwrt
OPENWRT_DIR="$(dirname "$0")/openwrt"
if [ ! -d "$OPENWRT_DIR" ]; then
    echo "❌ OpenWrt source directory not found at $OPENWRT_DIR"
    exit 1
fi

cd "$OPENWRT_DIR" || exit 1
echo "📁 Entered OpenWrt source directory: $PWD"

# 更新并安装所有 feeds
echo "🔄 Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 合并自定义 package 配置 fragment
PKG_FRAGMENT="$(dirname "$0")/my_packages.config"
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
# 你可以根据需要修改或增加
echo "📥 Cloning custom packages / themes..."
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix

echo "✅ diy-part1.sh completed successfully!"
