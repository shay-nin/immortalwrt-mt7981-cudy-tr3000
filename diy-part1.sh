#!/bin/bash
# ---------------------------------------------------------
# diy-part1.sh: 修复软件源并下载插件
# ---------------------------------------------------------

# 1. 【核心修复】强制重写 feeds.conf.default
# 使用 ImmortalWrt 官方源，确保基础依赖(luci-base, libev)齐全
echo 'src-git packages https://github.com/immortalwrt/packages.git' > feeds.conf.default
echo 'src-git luci https://github.com/immortalwrt/luci.git' >> feeds.conf.default
echo 'src-git routing https://github.com/immortalwrt/routing.git' >> feeds.conf.default
echo 'src-git telephony https://github.com/immortalwrt/telephony.git' >> feeds.conf.default

# 2. 下载自定义插件源码
# Argon 主题与配置
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# RKP-IPID 防检测模块 (必须配合 UA2F)
git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid
git clone https://github.com/Zxilly/UA2F.git package/UA2F

# 其他自定义包
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
