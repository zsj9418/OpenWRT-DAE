#!/bin/bash

function cat_kernel_config() {
  if [ -f $1 ]; then
    cat >> $1 <<EOF
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_CGROUPS=y
CONFIG_KPROBES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_ACT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_REDUCED is not set
CONFIG_DEBUG_INFO_BTF=y
CONFIG_KPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y

CONFIG_SCHED_CLASS_EXT=y
CONFIG_PROBE_EVENTS_BTF_ARGS=y
CONFIG_IMX_SCMI_MISC_DRV=y
EOF
    echo "add_kernel_config to $1 done"
  fi
}

function cat_ebpf_config() {

#ebpf相关
  cat >> $1 <<EOF
#eBPF
CONFIG_DEVEL=y
CONFIG_KERNEL_DEBUG_INFO=y
CONFIG_KERNEL_DEBUG_INFO_REDUCED=n
CONFIG_KERNEL_DEBUG_INFO_BTF=y
CONFIG_KERNEL_CGROUPS=y
CONFIG_KERNEL_CGROUP_BPF=y
CONFIG_KERNEL_BPF_EVENTS=y
CONFIG_BPF_TOOLCHAIN_HOST=y
CONFIG_KERNEL_XDP_SOCKETS=y
CONFIG_PACKAGE_kmod-xdp-sockets-diag=y
EOF
}



function cat_usb_net() {

#ebpf相关
  cat >> $1 <<EOF
CONFIG_PACKAGE_kmod-usb-net=y
CONFIG_PACKAGE_kmod-usb-net-cdc-eem=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y
CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ncm=y
CONFIG_PACKAGE_kmod-usb-net-cdc-subset=y
CONFIG_PACKAGE_kmod-usb-net-huawei-cdc-ncm=y
CONFIG_PACKAGE_kmod-usb-net-ipheth=y
CONFIG_PACKAGE_kmod-usb-net-rndis=y
CONFIG_PACKAGE_kmod-usb-net-rtl8150=y
CONFIG_PACKAGE_kmod-usb-net-rtl8152=y
EOF
#6.12内核不包含以下驱动
if echo "$CI_NAME" | grep -v "6.12" > /dev/null; then
  cat >> $1 <<EOF
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan-fibocom=y
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan-quectel=y
EOF
fi

}

function cat_ipq60xx_nowifi() {
cat >> $1 <<EOF
# CONFIG_DRIVER_11AC_SUPPORT is not set
# CONFIG_DRIVER_11AX_SUPPORT is not set
# CONFIG_NSS_DRV_WIFI_EXT_VDEV_ENABLE is not set
# CONFIG_PACKAGE_hostapd-common is not set
# CONFIG_PACKAGE_iw is not set
# CONFIG_PACKAGE_kmod-ath is not set
# CONFIG_PACKAGE_kmod-ath11k is not set
# CONFIG_PACKAGE_kmod-ath11k-ahb is not set
# CONFIG_PACKAGE_kmod-ath11k-pci is not set
# CONFIG_PACKAGE_kmod-cfg80211 is not set
# CONFIG_PACKAGE_kmod-mac80211 is not set
# CONFIG_PACKAGE_wifi-scripts is not set
# CONFIG_PACKAGE_wireless-regdb is not set
# CONFIG_PACKAGE_wpad-openssl is not set
# CONFIG_PACKAGE_ath11k-firmware-ipq6018 is not set
# CONFIG_PACKAGE_ath11k-firmware-qcn9074 is not set
EOF
}

function cat_ipq807x_nowifi() {
cat >> $1 <<EOF
#WIFI驱动
# CONFIG_DRIVER_11AC_SUPPORT is not set
# CONFIG_DRIVER_11AX_SUPPORT is not set
# CONFIG_NSS_DRV_WIFI_EXT_VDEV_ENABLE is not set
# CONFIG_PACKAGE_hostapd-common is not set
# CONFIG_PACKAGE_MAC80211_MESH is not set
# CONFIG_PACKAGE_iw is not set
# CONFIG_PACKAGE_kmod-ath is not set
# CONFIG_PACKAGE_kmod-ath10k-smallbuffers is not set
# CONFIG_PACKAGE_kmod-ath11k is not set
# CONFIG_PACKAGE_kmod-ath11k-ahb is not set
# CONFIG_PACKAGE_kmod-ath11k-pci is not set
# CONFIG_PACKAGE_kmod-cfg80211 is not set
# CONFIG_PACKAGE_kmod-mac80211 is not set
# CONFIG_PACKAGE_wifi-scripts is not set
# CONFIG_PACKAGE_wireless-regdb is not set
# CONFIG_PACKAGE_wpad-openssl is not set
# CONFIG_PACKAGE_ath10k-board-qca9887 is not set
# CONFIG_PACKAGE_ath10k-firmware-qca9887 is not set
# CONFIG_PACKAGE_ath11k-firmware-ipq8074 is not set
# CONFIG_PACKAGE_ath11k-firmware-qcn9074 is not set
EOF
}

function generate_config() {

  local target=$(echo $CI_NAME | cut -d'-' -f1)
  cat >> $1 << EOF
CONFIG_TARGET_qualcommax=y
CONFIG_TARGET_qualcommax_${target}=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_PER_DEVICE_ROOTFS=n
CONFIG_TARGET_DEVICE_qualcommax_${target}_DEVICE_${WRT_TARGET}=y
EOF
  cat $GITHUB_WORKSPACE/Config/GENERAL.txt >> $1
  #增加wifi 驱动
  if [[ "$CI_NAME" == *"NOWIFI"* ]]; then
    case "$(target)" in
    	ipq60xx)
    	  cat_ipq60xx_nowifi $1
    	;;
     ipq807x)
       cat_ipq807x_nowifi $1
      ;;
    esac
  else
    echo ""
  fi

  case "$(WRT_TARGET)" in
  	jdcloud_re-ss-01|\
    jdcloud_re-cs-02)|\
    jdcloud_re-cs-07)
      cat_usb_net $1
  		;;
  esac
  #增加ebpf
  add_ebpf_config $1
}


