#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好


# 后台IP设置
export Ipv4_ipaddr="192.168.5.1"            # 修改openwrt后台地址(填0为关闭)
export Netmask_netm="255.255.255.0"         # IPv4 子网掩码（默认：255.255.255.0）(填0为不作修改)
export Op_name="Reimu"                # 修改主机名称为OpenWrt-123(填0为不作修改)

# 内核和系统分区大小(不是每个机型都可用)
export Kernel_partition_size="32"            # 内核分区大小,每个机型默认值不一样 (填写您想要的数值,默认一般16,数值以MB计算，填0为不作修改),如果你不懂就填0
export Rootfs_partition_size="500"            # 系统分区大小,每个机型默认值不一样 (填写您想要的数值,默认一般300左右,数值以MB计算，填0为不作修改),如果你不懂就填0

# 默认主题设置
export Mandatory_theme="argon"              # 将bootstrap替换您需要的主题为必选主题(可自行更改您要的,源码要带此主题就行,填写名称也要写对) (填写主题名称,填0为不作修改)
export Default_theme="argon"                # 多主题时,选择某主题为默认第一主题 (填写主题名称,填0为不作修改)

# 旁路由选项
export Gateway_Settings="192.168.5.3"                 # 旁路由设置 IPv4 网关(填入您的网关IP为启用)(填0为不作修改)
export DNS_Settings="223.5.5.5 114.114.114.114"                     # 旁路由设置 DNS(填入DNS，多个DNS要用空格分开)(填0为不作修改)
export Broadcast_Ipv4="192.168.5.255"                   # 设置 IPv4 广播(填入您的IP为启用)(填0为不作修改)
export Disable_DHCP="1"                     # 旁路由关闭DHCP功能(1为启用命令,填0为不作修改)
export Disable_Bridge="1"                   # 旁路由去掉桥接模式(1为启用命令,填0为不作修改)
export Create_Ipv6_Lan="0"                  # 爱快+OP双系统时,爱快接管IPV6,在OP创建IPV6的lan口接收IPV6信息(1为启用命令,填0为不作修改)

# IPV6、IPV4 选择
export Enable_IPV6_function="0"             # 编译IPV6固件(1为启用命令,填0为不作修改)(如果跟Create_Ipv6_Lan一起启用命令的话,Create_Ipv6_Lan命令会自动关闭)
export Enable_IPV4_function="1"             # 编译IPV4固件(1为启用命令,填0为不作修改)(如果跟Enable_IPV6_function一起启用命令的话,此命令会自动关闭)

# 替换OpenClash的源码(默认master分支)
export OpenClash_branch="0"                 # OpenClash的源码分别有【master分支】和【dev分支】(填0为关闭,填1为使用master分支,填2为使用dev分支,填入1或2的时候固件自动增加此插件)

# 个性签名,默认增加年月日[$(TZ=UTC-8 date "+%Y.%m.%d")]
export Customized_Information="灵梦 $(TZ=UTC-8 date "+%Y.%m.%d")"  # 个性签名,你想写啥就写啥，(填0为不作修改)

# 更换固件内核
export Replace_Kernel="0"                    # 更换内核版本,在对应源码的[target/linux/架构]查看patches-x.x,看看x.x有啥就有啥内核了(填入内核x.x版本号,填0为不作修改)

# 设置免密码登录(个别源码本身就没密码的)
export Password_free_login="1"               # 设置首次登录后台密码为空（进入openwrt后自行修改密码）(1为启用命令,填0为不作修改)

# 增加AdGuardHome插件和核心
export AdGuardHome_Core="0"                  # 编译固件时自动增加AdGuardHome插件和AdGuardHome插件核心,需要注意的是一个核心20多MB的,小闪存机子搞不来(1为启用命令,填0为不作修改)

# 开启NTFS格式盘挂载
export Automatic_Mount_Settings="0"          # 编译时加入开启NTFS格式盘挂载的所需依赖(1为启用命令,填0为不作修改)

# 去除网络共享(autosamba)
export Disable_autosamba="1"                 # 去掉源码默认自选的luci-app-samba或luci-app-samba4(1为启用命令,填0为不作修改)

# 其他
export Ttyd_account_free_login="1"           # 设置ttyd免密登录(1为启用命令,填0为不作修改)
export Delete_unnecessary_items="0"          # 个别机型内一堆其他机型固件,删除其他机型的,只保留当前主机型固件(1为启用命令,填0为不作修改)
export Disable_53_redirection="0"            # 删除DNS强制重定向53端口防火墙规则(个别源码本身不带此功能)(1为启用命令,填0为不作修改)
export Cancel_running="0"                    # 取消路由器每天跑分任务(个别源码本身不带此功能)(1为启用命令,填0为不作修改)


# 晶晨CPU系列打包固件设置(不懂请看说明)
export amlogic_model="s905d"
export amlogic_kernel="6.1.120_6.12.15"
export auto_kernel="true"
export rootfs_size="512/2560"
export kernel_usage="stable"

## 更换最新 nikki 插件版本
# 先删除旧目录，确保拉取的是最新源码
rm -rf feeds/danshui/luci-app-nikki

echo "正在从 GitHub 获取最新的 nikki 插件源码..."
git clone https://github.com/nikkinikki-org/OpenWrt-nikki.git feeds/danshui/luci-app-nikki

# 定位需要修改的文件路径
NIKKI_INIT="feeds/danshui/luci-app-nikki/nikki/files/uci-defaults/init.sh"

echo "🚀 准备修改 nikki 插件的随机密码逻辑..."

# 检查文件是否存在并执行修改
if [ -f "$NIKKI_INIT" ]; then
    echo "✅ 成功找到目标文件: $NIKKI_INIT"
    
    # 核心修改：将 random=$(awk...) 替换为 random=""
    # 注意：这里使用了正则匹配，兼容性更好
    sed -i 's/random=\$(awk .*)/random=""/g' "$NIKKI_INIT"
    
    # 验证修改结果并显示到日志
    CHECK_RESULT=$(grep "random=" "$NIKKI_INIT")
    echo "✨ 恭喜！代码修改成功，当前配置为: $CHECK_RESULT"
    echo "💡 提示：该操作已取消随机密码生成，固件安装后 api_secret 将为空。"
else
    echo "❌ 错误：未找到目标文件！请检查路径或源码结构。"
fi

# --- 自定义插件处理结束 ---

## 拉取最新 momo 插件版本
rm -rf feeds/danshui/OpenWrt-momo
git clone https://github.com/nikkinikki-org/OpenWrt-momo.git feeds/danshui/OpenWrt-momo



## 更换最新 passwall 插件版本
## rm -rf feeds/danshui/luci-app-passwall && git clone https://github.com/xiaorouji/openwrt-passwall.git feeds/danshui/luci-app-passwall

## 拉取最新 momo 插件版本
git clone https://github.com/nikkinikki-org/OpenWrt-momo.git feeds/danshui/OpenWrt-momo

## 更换最新 argon 主题版本
## rm -rf package/luci-theme-argon && git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

## 强行加入argon主题控制插件           云编译不适合
# sed -i 's/# CONFIG_PACKAGE_luci-app-argon-config is not set/CONFIG_PACKAGE_luci-app-argon-config=y/' .config

# 修改插件名字
grep -rl '"终端"' . | xargs -r sed -i 's?"终端"?"TTYD"?g'
grep -rl '"TTYD 终端"' . | xargs -r sed -i 's?"TTYD 终端"?"TTYD"?g'
grep -rl '"网络存储"' . | xargs -r sed -i 's?"网络存储"?"NAS"?g'
grep -rl '"实时流量监测"' . | xargs -r sed -i 's?"实时流量监测"?"流量"?g'
grep -rl '"KMS 服务器"' . | xargs -r sed -i 's?"KMS 服务器"?"KMS激活"?g'
grep -rl '"USB 打印服务器"' . | xargs -r sed -i 's?"USB 打印服务器"?"打印服务"?g'
grep -rl '"Web 管理"' . | xargs -r sed -i 's?"Web 管理"?"Web管理"?g'
grep -rl '"管理权"' . | xargs -r sed -i 's?"管理权"?"改密码"?g'
grep -rl '"带宽监控"' . | xargs -r sed -i 's?"带宽监控"?"监控"?g'


# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间(根据编译机型变化,自行调整删除名称)
cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
sha256sums
version.buildinfo
profiles.json
openwrt-x86-64-generic-kernel.bin
openwrt-x86-64-generic.manifest
openwrt-x86-64-generic-squashfs-rootfs.img.gz
EOF

# 在线更新时，删除不想保留固件的某个文件，在EOF跟EOF之间加入删除代码，记住这里对应的是固件的文件路径，比如： rm -rf /etc/config/luci
cat >>$DELETE <<-EOF
EOF
