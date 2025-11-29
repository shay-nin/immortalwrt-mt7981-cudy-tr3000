#!/bin/bash
set -e

#
# diy-part2.sh — OpenWrt / ImmortalWrt 自定义脚本 (After feeds/config, before build)
#

# ———— 设备 / DTS 修改 — 以 Cudy TR3000 为例 ————
# 启用 USB 电源 (如果需要的话)
sed -i '/modem-power/,/};/{ s/gpio-export,output = <1>;/gpio-export,output = <0>;/ }' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dtsi || true

# ———— 在固件文件名中加入构建日期 (便于区分版本) ————
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk || true

# ———— (可选) 调整 UBI 分区大小 — 根据 flash 大小决定是否启用 ————
# 如果你使用 256 MB flash，并希望扩大 rootfs／overlay，可取消下面这行的注释
# sed -i 's/reg = <0x5c0000 0x7000000>;/reg = <0x5c0000 0x7a40000>;/' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts || true

set ubi to 122M
sed -i 's/reg = <0x5c0000 0x7000000>;/reg = <0x5c0000 0x7a40000>;/' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts

# ———— (可选) 默认配置修改 —— IP / hostname / theme 等 —— 根据需要取消下面注释 —— 
# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
# sed -i 's/OpenWrt/MyRouter/g' package/base-files/files/bin/config_generate

# ———— (可选) 自定义 package / theme / plugin —— 如有需要可在这里 clone —— 
# git clone https://github.com/... package/...

echo "diy-part2.sh — custom adjustments applied (without OpenClash parts)"
