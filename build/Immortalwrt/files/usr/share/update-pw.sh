#!/bin/sh
# Passwall 自动更新脚本 - 仪式感增强版
# 路径: /usr/share/update-pw.sh

set -u
set -o pipefail

# 颜色定义
RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'

# --- 1. 仪式感启动界面 ---
clear
echo -e "${CYAN}"
echo "  █████╗ ██████╗ ██████╗  █████╗ ███████╗███████╗"
echo " ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝"
echo " ███████║██████╔╝██████╔╝███████║███████╗███████╗"
echo " ██╔══██║██╔═══╝ ██╔═══╝ ██╔══██║╚════██║╚════██║"
echo " ██║  ██║██║     ██║     ██║  ██║███████║███████║"
echo " ╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝"
echo -e "         ${YELLOW}>> Passwall 云端同步升级程序 <<${NC}"
echo -e "${PURPLE}--------------------------------------------------${NC}"
echo -e "${BLUE}[系统]${NC} 正在初始化环境..."
sleep 1

# --- 2. 配置与环境检查 ---
CHANNEL_PREFIX="23.05-24.10"
TEMP_DIR="/tmp/pw_upgrade"
RULE_DIR="/usr/share/passwall/rules"
LOCKFILE="/tmp/pw_update.lock"

[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

if ! mkdir "$LOCKFILE" 2>/dev/null; then
    echo -e "${RED}[错误]${NC} 另一个更新任务正在运行，请勿重复操作。"
    exit 1
fi
trap 'rm -rf "$TEMP_DIR" "$LOCKFILE"; exit' INT TERM EXIT

# --- 3. 检测版本 (带进度感) ---
echo -ne "${BLUE}[网络]${NC} 正在连接 GitHub API 检索最新版本... [⏳]"
RELEASE_API="https://api.github.com/repos/Openwrt-Passwall/openwrt-passwall/releases/latest"
JSON_DATA=$(curl -s --connect-timeout 10 "$RELEASE_API")

if [ -z "$JSON_DATA" ]; then
    echo -e "\r${RED}[错误]${NC} 无法连接 GitHub，请检查您的科学上网环境。   "
    exit 1
fi
echo -e "\r${GREEN}[完成]${NC} 已获取云端 Release 数据。                 "

APP_URL=$(echo "$JSON_DATA" | grep -o "\"browser_download_url\": \"[^\"]*${CHANNEL_PREFIX}_luci-app-passwall_[0-9.]\+.*\.ipk\"" | head -n 1 | cut -d\" -f4)
LANG_URL=$(echo "$JSON_DATA" | grep -o "\"browser_download_url\": \"[^\"]*${CHANNEL_PREFIX}_luci-i18n-passwall-zh-cn_[0-9.]\+.*\.ipk\"" | head -n 1 | cut -d\" -f4)

NEW_VER=$(echo "$APP_URL" | sed -E 's/.*_([0-9]+\.[0-9]+\.[0-9]+-[0-9]+).*/\1/')
OLD_VER=$(opkg list-installed | grep 'luci-app-passwall' | awk '{print $3}')

echo -e "${BLUE}[比对]${NC} 本地版本: ${YELLOW}${OLD_VER:-未安装}${NC}"
echo -e "${BLUE}[比对]${NC} 云端版本: ${GREEN}${NEW_VER}${NC}"

if [ "$NEW_VER" == "$OLD_VER" ]; then
    echo -e "${GREEN}[提示]${NC} 已经是最新版，无需折腾！"
    exit 0
fi

# --- 4. 确认与下载 ---
echo -e "${PURPLE}--------------------------------------------------${NC}"
echo -e "${YELLOW}🚀 发现新版本，准备开始“换芯”手术...${NC}"
sleep 1

echo -e "${BLUE}[下载]${NC} 正在拉取主程序包..."
wget -q --show-progress -O "$TEMP_DIR/app.ipk" "$APP_URL"
echo -e "${BLUE}[下载]${NC} 正在拉取中文语言包..."
wget -q --show-progress -O "$TEMP_DIR/lang.ipk" "$LANG_URL"

# --- 5. 备份与安装 ---
echo -e "${BLUE}[备份]${NC} 正在保护您的自定义规则名单..."
mkdir -p "$TEMP_DIR/rules_bak"
for f in direct_host direct_ip proxy_host proxy_ip; do
    [ -f "$RULE_DIR/$f" ] && cp "$RULE_DIR/$f" "$TEMP_DIR/rules_bak/" && echo -e "  └─ 已备份 $f"
done

echo -e "${BLUE}[清理]${NC} 正在重置旧的防火墙表 (nftables)..."
/etc/init.d/passwall stop 2>/dev/null || true
for t in passwall passwall_chn passwall_geo passwall1; do
    nft delete table inet "$t" 2>/dev/null || true
done

echo -e "${BLUE}[安装]${NC} 正在覆盖安装最新补丁..."
opkg install "$TEMP_DIR/app.ipk" --force-overwrite >/dev/null
opkg install "$TEMP_DIR/lang.ipk" --force-overwrite >/dev/null

# --- 6. 恢复与重启 ---
echo -e "${BLUE}[恢复]${NC} 还原自定义规则..."
cp -r "$TEMP_DIR/rules_bak/"* "$RULE_DIR/" 2>/dev/null || true

echo -e "${BLUE}[重载]${NC} 正在重启网络核心服务..."
/etc/init.d/firewall restart >/dev/null 2>&1
/etc/init.d/passwall restart >/dev/null 2>&1
/etc/init.d/dnsmasq restart >/dev/null 2>&1

if command -v conntrack >/dev/null; then conntrack -F >/dev/null 2>&1; fi

echo -e "${PURPLE}--------------------------------------------------${NC}"
echo -e "${GREEN}✨ 恭喜！Passwall 已成功升级至 $NEW_VER ✨${NC}"
echo -e "${CYAN}系统已无缝恢复正常运行。${NC}"