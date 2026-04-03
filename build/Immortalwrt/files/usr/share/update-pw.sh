#!/bin/sh
# Passwall 自动更新脚本 - 版本比对优化版
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
echo -e "         ${YELLOW}>> Passwall 云端同步加速升级程序 <<${NC}"
echo -e "${PURPLE}--------------------------------------------------${NC}"

# --- 2. 配置区 ---
CHANNEL_PREFIX="23.05-24.10"
TEMP_DIR="/tmp/pw_upgrade"
RULE_DIR="/usr/share/passwall/rules"
LOCKFILE="/tmp/pw_update.lock"
GH_PROXY="https://mirror.ghproxy.com/"

[ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

if ! mkdir "$LOCKFILE" 2>/dev/null; then
    echo -e "${RED}[错误]${NC} 另一个更新任务正在运行，请勿重复操作。"
    exit 1
fi
trap 'rm -rf "$TEMP_DIR" "$LOCKFILE"; exit' INT TERM EXIT

# --- 3. 获取数据与精准比对 ---
echo -ne "${BLUE}[网络]${NC} 正在检索云端数据... [⏳]"
RELEASE_API="https://api.github.com/repos/Openwrt-Passwall/openwrt-passwall/releases/latest"
JSON_DATA=$(curl -s --connect-timeout 15 "$RELEASE_API")

if [ -z "$JSON_DATA" ]; then
    echo -e "\r${RED}[错误]${NC} 无法连接 GitHub API，请检查网络设置。          "
    exit 1
fi
echo -e "\r${GREEN}[完成]${NC} 已成功获取 Release 数据。                 "

# 提取 URL
APP_URL=$(echo "$JSON_DATA" | grep -o "\"browser_download_url\": \"[^\"]*${CHANNEL_PREFIX}_luci-app-passwall_[0-9.]\+.*\.ipk\"" | head -n 1 | cut -d\" -f4)
LANG_URL=$(echo "$JSON_DATA" | grep -o "\"browser_download_url\": \"[^\"]*${CHANNEL_PREFIX}_luci-i18n-passwall-zh-cn_[0-9.]\+.*\.ipk\"" | head -n 1 | cut -d\" -f4)

# 精准提取版本号 (处理类似 26.4.3-r1 的格式)
NEW_VER=$(echo "$APP_URL" | sed -n 's/.*passwall_\([^_]*\)_all.*/\1/p')
OLD_VER=$(opkg list-installed | grep 'luci-app-passwall' | awk '{print $3}')

echo -e "${BLUE}[比对]${NC} 本地版本: ${YELLOW}${OLD_VER:-未安装}${NC}"
echo -e "${BLUE}[比对]${NC} 云端版本: ${GREEN}${NEW_VER:-未知}${NC}"

# --- 核心逻辑：版本相同则退出 ---
if [ -n "$NEW_VER" ] && [ "$NEW_VER" == "$OLD_VER" ]; then
    echo -e "${PURPLE}--------------------------------------------------${NC}"
    echo -e "${GREEN}✅ 检测到本地版本与云端一致，无需更新。${NC}"
    echo -e "${CYAN}您的 Passwall 已经是最新的了，祝您使用愉快！${NC}"
    exit 0
fi

# --- 4. 执行更新流程 (仅在版本不同时触发) ---
echo -e "${PURPLE}--------------------------------------------------${NC}"
echo -e "${YELLOW}🚀 发现新版本，开始执行升级任务...${NC}"

echo -e "${BLUE}[下载]${NC} 正在拉取主程序包 (尝试加速)..."
wget -q --show-progress -O "$TEMP_DIR/app.ipk" "${GH_PROXY}${APP_URL}" || wget -q --show-progress -O "$TEMP_DIR/app.ipk" "$APP_URL"

echo -e "${BLUE}[下载]${NC} 正在拉取语言包 (尝试加速)..."
wget -q --show-progress -O "$TEMP_DIR/lang.ipk" "${GH_PROXY}${LANG_URL}" || wget -q --show-progress -O "$TEMP_DIR/lang.ipk" "$LANG_URL"

echo -e "${BLUE}[备份]${NC} 保护自定义规则名单..."
mkdir -p "$TEMP_DIR/rules_bak"
for f in direct_host direct_ip proxy_host proxy_ip; do
    [ -f "$RULE_DIR/$f" ] && cp "$RULE_DIR/$f" "$TEMP_DIR/rules_bak/" && echo -e "  └─ 备份成功: $f"
done

echo -e "${BLUE}[清理]${NC} 停服并清理防火墙规则..."
/etc/init.d/passwall stop 2>/dev/null || true
for t in passwall passwall_chn passwall_geo passwall1; do
    nft delete table inet "$t" 2>/dev/null || true
done

echo -e "${BLUE}[安装]${NC} 执行覆盖安装 (静默模式)..."
opkg install "$TEMP_DIR/app.ipk" --force-overwrite --force-maintainer >/dev/null 2>&1
opkg install "$TEMP_DIR/lang.ipk" --force-overwrite --force-maintainer >/dev/null 2>&1

echo -e "${BLUE}[恢复]${NC} 还原您的自定义规则..."
cp -r "$TEMP_DIR/rules_bak/"* "$RULE_DIR/" 2>/dev/null || true

echo -e "${BLUE}[重载]${NC} 重启网络核心服务..."
/etc/init.d/firewall restart >/dev/null 2>&1
/etc/init.d/passwall restart >/dev/null 2>&1
/etc/init.d/dnsmasq restart >/dev/null 2>&1
[ -x /usr/bin/conntrack ] && conntrack -F >/dev/null 2>&1

echo -e "${PURPLE}--------------------------------------------------${NC}"
echo -e "${GREEN}✨ 升级成功！当前版本: $NEW_VER ✨${NC}"