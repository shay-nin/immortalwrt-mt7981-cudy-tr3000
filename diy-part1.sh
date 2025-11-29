#!/bin/bash
# ---------------------------------------------------------
# diy-part1.sh: 核心任务是把“食材”买回来
# ---------------------------------------------------------

# 1. 确保 Argon 主题及其配置插件都有源码
# 注意：luci-app-argon-config 强依赖 luci-theme-argon，必须同时存在
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 2. 解决 kmod-rkp-ipid 及其防检测依赖 (针对 Kernel 6.x)
# rkp-ipid 是非官方内核模块，必须手动下载。
# 这里使用适配较新的仓库，通常能兼容 6.6 内核
git clone https://github.com/EOYOHOO/rkp-ipid.git package/rkp-ipid
git clone https://github.com/Zxilly/UA2F.git package/UA2F

# 3. 添加 luci-app-ttyd (如果官方源里没有，手动拉取)
# 通常官方 feed 里有，但为了保险可以拉取
# git clone https://github.com/openwrt/luci-app-ttyd.git package/luci-app-ttyd

# 4. 保留你原有的自定义包
git clone https://github.com/eamonxg/luci-theme-aurora package/luci-theme-aurora
git clone https://github.com/timsaya/luci-app-bandix package/luci-app-bandix
git clone https://github.com/timsaya/openwrt-bandix package/openwrt-bandix
