#!/bin/bash
#
# diy-part1.sh — 强制重写源配置 (彻底解决依赖丢失问题)
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

# 2. 【核弹级修复】直接覆盖 feeds.conf.default
# 不再尝试修改原有文件，而是直接写入全新的标准源
echo "🔥 Nuke and rewrite feeds.conf.default..."
rm -f feeds.conf.default

# 写入 ImmortalWrt 官方源 (适配 24.10/Master 分支)
cat > feeds.conf.default <<EOF
src-git packages https://github.com/immortalwrt/packages.git
src-git luci https://github.com/immortalwrt/luci.git
src-git routing https://github.com/immortalwrt/routing.git
src-git telephony https://github.com/immortalwrt/telephony.git
EOF

echo "📄 New feeds.conf.default content:"
cat feeds.conf.default

# 3. 下载自定义插件 (Bandix & Aurora)
echo "📥 Cloning custom packages..."
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

git_clone_path "https://github.com/eamonxg/luci-theme-aurora" "package/luci-theme-aurora"
git_clone_path "https://github.com/timsaya/luci-app-bandix" "package/luci-app-bandix"
git_clone_path "https://github.com/timsaya/openwrt-bandix" "package/openwrt-bandix"

# 4. 【强制更新】清理缓存并安装 Feeds
echo "🔄 Updating and installing feeds (Fresh Start)..."
# 删除可能存在的旧 feeds 数据
rm -rf feeds/ packages/feeds/ tmp/

# 更新源
./scripts/feeds update -a
# 安装源 (强制覆盖)
./scripts/feeds install -a

# 5. 【验证检查】检查核心依赖是否安装成功
# 如果这步报错，说明网络有问题或者源完全不可用
echo "🕵️ verifying key dependencies..."
if [ -d "package/feeds/packages/libpam" ]; then
    echo "✅ libpam found!"
else
    echo "❌ libpam NOT found! Trying to force install..."
    ./scripts/feeds install libpam
fi

if [ -d "package/feeds/luci/luci-compat" ]; then
    echo "✅ luci-compat found!"
else
    echo "❌ luci-compat NOT found! Trying to force install..."
    ./scripts/feeds install luci-compat
fi

# 6. 合并自定义配置
PKG_FRAGMENT="$SCRIPT_DIR/my_packages.config"
if [ -f "$PKG_FRAGMENT" ]; then
    echo "📦 Merging custom package config..."
    cat "$PKG_FRAGMENT" >> .config
fi

# 7. 生成配置
echo "⚙️ Running defconfig..."
make defconfig

echo "✅ diy-part1.sh completed!"
