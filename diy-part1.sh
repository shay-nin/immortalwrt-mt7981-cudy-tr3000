#!/bin/bash
# diy-part1.sh — OpenWrt / ImmortalWrt 自定义包合并脚本 (Before feeds update / build)

set -e

# 更新并安装所有 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 合并自定义 package 配置 fragment
if [ -f "./my_packages.config" ]; then
  echo "=== Merging custom package config fragment ==="
  cat "./my_packages.config" >> .config
else
  echo ">>> Warning: my_packages.config not found — skip merging custom packages"
fi

# 推荐做 defconfig，以避免 config 与 kernel / target 不一致的问题
yes "" | make defconfig

# （保留你原来 clone 的主题 / package，如果你还需要的话）
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
