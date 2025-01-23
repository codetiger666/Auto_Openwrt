#!/bin/bash
# https://github.com/nieningproj/AutoBuild_Openwrt


Core_x86_64(){
    Author=CodeTiger
    INCLUND_NGINX=true
}

Core_xiaomi_ac2100(){
    Author=CodeTiger
}

Core_redmi_ax6000(){
    Author=CodeTiger
}

Diy-Part1() {
    cd $GITHUB_WORKSPACE/openwrt/package
    mkdir codetiger
    # mtk私有
    cd $GITHUB_WORKSPACE/openwrt
    cd $GITHUB_WORKSPACE/openwrt/package/codetiger
    # smartdns
    git clone https://github.com/pymumu/openwrt-smartdns.git --dept=1
    git clone https://github.com/pymumu/luci-app-smartdns.git --dept=1
    # 添加默认配置
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/domain-set
    wget -O $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/domain-set/cn https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt
    wget -O $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/domain-set/ad https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt
    /bin/cp  $GITHUB_WORKSPACE/Customize/smartdns_customer $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/smartdns/custom.conf
    # ddns-go
    git clone https://github.com/sirpdboy/luci-app-ddns-go.git --dept=1
    # mihomo
    git clone https://github.com/morytyann/OpenWrt-mihomo.git --dept=1
    # fackmesh 使用x-wrt源码
    git clone https://github.com/x-wrt/com.x-wrt.git x --dept=1
    mv x/luci-app-fakemesh/ ./
    rm -rf x/
    # 获取kernel 指纹
    # curl https://downloads.openwrt.org/releases/$VERSION/targets/mediatek/filogic/openwrt-$VERSION-mediatek-filogic.manifest > kernel.manifest
    # cat kernel.manifest | grep kernel | awk -F '-' '{print $NF}' > $GITHUB_WORKSPACE/openwrt/vermagic
    sed -i 's/${ipaddr:-"192.168.1.1"}/${ipaddr:-"10.128.1.1"}/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i 's/${ipaddr:-"192.168.$((addr_offset++)).1"}/${ipaddr:-"10.128.$((addr_offset++)).1"}/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i "s/timezone='UTC'/timezone='Asia\/Shanghai'/g" $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i 's/0.openwrt.pool.ntp.org/ntp.aliyun.com/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i 's/1.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i '/2.openwrt.pool.ntp.org/d' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i '/3.openwrt.pool.ntp.org/d' $GITHUB_WORKSPACE/openwrt/package/base-files/files/bin/config_generate
    sed -i '/mkhash md5/c\\tcp $(TOPDIR)\/vermagic $(LINUX_DIR)\/.vermagic' $GITHUB_WORKSPACE/openwrt/include/kernel-defaults.mk
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
    mkdir -p $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/codetiger
    if [ "$Change_Wifi" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
        /bin/cp $GITHUB_WORKSPACE/Customize/newifiD2_wireless ./wireless
    fi
    if [ "$Change_DHCP" == "true" ]; then
        cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
        /bin/cp $GITHUB_WORKSPACE/Customize/newifiD2_dhcp ./dhcp
    fi
    cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/config
    /bin/cp $GITHUB_WORKSPACE/Customize/nginx ./nginx
    # 服务监听脚本
    cd $GITHUB_WORKSPACE/openwrt/package/base-files/files/etc/codetiger
    /bin/cp $GITHUB_WORKSPACE/scripts/servicewatch ./servicewatch
    chmod +x ./servicewatch
}


Diy-Part2_xiaomi_ac2100() {
    Date=`date "+%Y%m%d%H%M"`
	mkdir release
	mv -f artifacts/xiaomi_ac2100/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mi-router-ac2100-squashfs-sysupgrade.bin release/"openwrt-xiaomi-ac2100-${project_version}-$Date.bin"
	mv -f artifacts/xiaomi_ac2100/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mi-router-ac2100-initramfs-kernel.bin release/"openwrt-xiaomi-ac2100-kernel-${project_version}-$Date.bin"
    _MD5=$(md5sum release/"openwrt-xiaomi-ac2100-${project_version}-$Date.bin" | cut -d ' ' -f1)
    _MD5_kernel=$(md5sum release/"openwrt-xiaomi-ac2100-kernel-${project_version}-$Date.bin" | cut -d ' ' -f1)
    _SHA256=$(sha256sum release/"openwrt-xiaomi-ac2100-${project_version}-$Date.bin" | cut -d ' ' -f1)
    _SHA256_kernel=$(sha256sum release/"openwrt-xiaomi-ac2100-kernel-${project_version}-$Date.bin" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > release/"openwrt-xiaomi-ac2100-${project_version}-$Date.detail"
    echo -e "\nMD5:${_MD5_kernel}\nSHA256:${_SHA256_kernel}" > release/"openwrt-xiaomi-ac2100-kernel-${project_version}-$Date.detail"
}

Diy-Part2_redmi_ax6000() {
    Date=`date "+%Y%m%d%H%M"`
	mkdir release
	mv -f artifacts/redmi_ax6000/targets/mediatek/filogic/openwrt-mediatek-filogic-xiaomi_redmi-router-ax6000-ubootlayout-squashfs-sysupgrade.bin release/"openwrt-redmi-ax6000-${project_version}-$Date.bin"
	mv -f artifacts/redmi_ax6000/targets/mediatek/filogic/openwrt-mediatek-filogic-xiaomi_redmi-router-ax6000-ubootlayout-initramfs-kernel.bin release/"openwrt-redmi-ax6000-kernel-${project_version}-$Date.bin"
    _MD5=$(md5sum release/"openwrt-redmi-ax6000-${project_version}-$Date.bin" | cut -d ' ' -f1)
    _MD5_kernel=$(md5sum release/"openwrt-redmi-ax6000-kernel-${project_version}-$Date.bin" | cut -d ' ' -f1)
    _SHA256=$(sha256sum release/"openwrt-redmi-ax6000-${project_version}-$Date.bin" | cut -d ' ' -f1)
    _SHA256_kernel=$(sha256sum release/"openwrt-redmi-ax6000-kernel-${project_version}-$Date.bin" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > release/"openwrt-redmi-ax6000-${project_version}-$Date.detail"
    echo -e "\nMD5:${_MD5_kernel}\nSHA256:${_SHA256_kernel}" > release/"openwrt-redmi-ax6000-init-${project_version}-$Date.detail"
}

Diy-Part2_x86_64() {
    Date=`date "+%Y%m%d"`
	mkdir bin/Firmware
	mv -f bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz"
    mv -f bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz bin/Firmware/"openwrt-x86-64-$Date.img.gz"
	_MD5_efi=$(md5sum bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz" | cut -d ' ' -f1)
    _MD5=$(md5sum bin/Firmware/"openwrt-x86-64-$Date.img.gz" | cut -d ' ' -f1)
	_SHA256_efi=$(sha256sum bin/Firmware/"openwrt-x86-64-efi-$Date.img.gz" | cut -d ' ' -f1)
    _SHA256=$(sha256sum bin/Firmware/"openwrt-x86-64-$Date.img.gz" | cut -d ' ' -f1)
    echo -e "\nMD5:${_MD5}\nSHA256:${_SHA256}" > bin/Firmware/"openwrt-x86-64-$Date.detail"
    echo -e "\nMD5:${_MD5_efi}\nSHA256:${_SHA256_efi}" > bin/Firmware/"openwrt-x86-64-efi-$Date.detail"
}
