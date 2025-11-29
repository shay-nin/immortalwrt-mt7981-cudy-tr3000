#!/bin/bash
set -e

#
# diy-part2.sh — 在 feeds/config 应用后、编译前做额外定制
#

# -------------------------------
# 设备 / DTS 修改 — 以 Cudy TR3000 为例
# 启用 USB 电源 (如果需要的话)
sed -i '/modem-power/,/};/{ s/gpio-export,output = <1>;/gpio-export,output = <0>;/ }' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dtsi || true

# -------------------------------
# 固件文件名中添加构建日期 (可识别不同构建版本)
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk || true

# -------------------------------
# 可选：调整 UBI 分区大小（根据你的 flash 大小，谨慎使用）
# 以下示例将 UBI 分区设为 122M — 仅当你设备 flash 空间足够时启用
# sed -i 's/reg = <0x5c0000 0x7000000>;/reg = <0x5c0000 0x7a40000>;/' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts || true

# -------------------------------
# 添加其它自定义 files / 配置 / 脚本 (如果有)
# 例如 increase default timezone, default IP, hostname, theme 等
# sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
# sed -i 's/OpenWrt/MyRouter/g' package/base-files/files/bin/config_generate

# -------------------------------
# 如果你需要集成某些第三方插件／theme／package
# 可以在这里 clone 对应 repo 到 package/ 下
# 例如 (示例，仅当你需要时取消注释):
# git clone https://github.com/someuser/some-luci-app.git package/some-luci-app

# -------------------------------
# 示例：为 OpenClash 下载 core (如果你真的需要)
CLASH_DIR="files/etc/openclash/core"
mkdir -p "$CLASH_DIR"
wget -qO "${CLASH_DIR}/clash_meta.tar.gz" "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
tar -zxvf "${CLASH_DIR}/clash_meta.tar.gz" -C "$CLASH_DIR"
# 将文件重命名 / 设置为可执行
if [ -f "${CLASH_DIR}/clash" ]; then
  mv "${CLASH_DIR}/clash" "${CLASH_DIR}/clash_meta"
  chmod +x "${CLASH_DIR}/clash_meta"
fi
rm -f "${CLASH_DIR}/clash_meta.tar.gz"

# -------------------------------
echo "diy-part2.sh — custom adjustments applied"
