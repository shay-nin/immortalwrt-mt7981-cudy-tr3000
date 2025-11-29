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

# 2. 关键修复：确保 feeds.conf.default 中的核心源没有被注释掉
# 这一步会把 helloworld, packages, luci 等被注释的源全部解除注释
if [ -f "feeds.conf.default" ]; then
    echo "🔓 Uncommenting all feeds in feeds.conf.default..."
    sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*packages\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*luci\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*routing\)/\1/' feeds.conf.default
    sed -i 's/^#\(.*telephony\)/\1/' feeds.conf.default
fi

# 3. 先下载自定义插件 (Cloning custom packages)
# 建议放在 feeds install 之前，以便处理依赖覆盖
echo "📥 Cloning custom packages / themes..."
# 检查目录是否存在以避免重复 clone 报错
[ -d "package/luci-theme-aurora" ] || git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
[ -d "package/luci-app-bandix" ] || git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
[ -d "package/openwrt-bandix" ] || git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix

# 4. 更新并安装 Feeds (Updating and installing feeds)
# 这一步必须在 clone 完自定义插件后执行，或者执行完后再补充执行一次
echo "🔄 Updating and installing feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 5. 合并自定义配置 (Merging custom config)
PKG_FRAGMENT="$SCRIPT_DIR/my_packages.config"
if [ -f "$PKG_FRAGMENT" ]; then
    echo "📦 Merging custom package config fragment..."
    cat "$PKG_FRAGMENT" >> .config
fi

# 6. 生成配置 (Running defconfig)
echo "⚙️ Running defconfig..."
# 使用 make defconfig 自动补全依赖

# 强制添加 luci-compat 以解决旧版插件报错 (Dependency on luci-lua-runtime)
echo "🔧 Enabling luci-compat for legacy package support..."
echo "CONFIG_PACKAGE_luci-compat=y" >> .config
echo "CONFIG_PACKAGE_luci-lib-ipkg=y" >> .config

# 做一次 defconfig
echo "⚙️ Running defconfig..."
yes "" | make defconfig
make defconfig

echo "✅ diy-part1.sh completed successfully!"
