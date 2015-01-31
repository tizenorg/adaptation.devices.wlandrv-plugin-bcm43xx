#!/bin/sh

INSMOD_TOOL=/usr/sbin/modprobe
MOD_INFO_FILE=/opt/etc/.cid.info
DRV_PATH=/opt/driver
FW_PATH=/lib/firmware
IFACE_NAME=wlan0

# Driver path
DRIVER=dhd

# firmware : FIRMWARE_[Mode]_[Chip]_[Version]_{Additional Info}
	# net
		# bcm4330b1			
			FIRMWARE_NET_BCM4330B1_342=${FW_PATH}/wlan_net_bcm4330b1_5.90.100.342.bin
		# bcm4334b2
			FIRMWARE_NET_BCM4334B2_58=${FW_PATH}/wlan_net_bcm4334b2_6.10.58.740.bin
	# softap
		# bcm4330b1 : BCM4330 use same firmware for net and softap			
			FIRMWARE_SOFTAP_BCM4330B1_342=${FW_PATH}/wlan_softap_bcm4330b1_5.90.100.342.bin
		# bcm4334b2
			FIRMWARE_SOFTAP_BCM4334B2_58=${FW_PATH}/wlan_softap_bcm4334b2_6.10.58.740.bin
	# mft
		# bcm4330b1
			FIRMWARE_MFT_BCM4330B1_342=${FW_PATH}/wlan_mfg_bcm4330b1_5.90.100.342.bin
		#bcm4334b2
			FIRMWARE_MFT_BCM4334B2_58=${FW_PATH}/wlan_mfg_bcm4334b2_6.10.58.740.bin

	# p2p(Wi-Fi Direct)
		#bcm4330b1 : BCM4330b1 use same firmware for net and p2p
			FIRMWARE_P2P_BCM4330B1_342=${FW_PATH}/wlan_p2p_bcm4330b1_5.90.100.342.bin
		#bcm4334b2
			FIRMWARE_P2P_BCM4334B2_58=${FW_PATH}/wlan_net_bcm4334b2_6.10.58.740.bin


# nvram : NVRAM_[Mode]_[Chip]_[Type]_[Version]_{Additional Info}
	# net
		# bcm4330b1
			# semco
				NVRAM_NET_BCM4330B1_SEMCO_270=${FW_PATH}/nvram_net_bcm4330b1_semco_5.90.100.270.txt
		# bcm4334b2
			# semco
				NVRAM_NET_BCM4334B2_SEMCO=${FW_PATH}/nvram_net_bcm4334b2b3_semco_20120723.txt

	# mft
		# bcm4330b1
			# semco
				NVRAM_MFT_BCM4330B1_SEMCO_OLD=${FW_PATH}/nvram_mfg_bcm4330b1_semco_old.txt
		# bcm4334b2
			# semco
				NVRAM_MFT_BCM4334B2_SEMCO=${FW_PATH}/nvram_mfg_bcm4334b2b3_semco_20120723.txt

run_dhd_to_check_module_type()
{
	${INSMOD_TOOL} ${DRIVER} firmware_path=${FIRMWARE_MFT} nvram_path=${NVRAM_MFT} iface_name=${IFACE_NAME}
	/bin/sleep 1
	/usr/sbin/rmmod dhd
}

check_module_type()
{
	if	[ -s ${MOD_INFO_FILE} ]; then
		MOD_TYPE=`cat ${MOD_INFO_FILE}`
	else
		/bin/echo excute run_dhd_to_check_module_type
		run_dhd_to_check_module_type
		MOD_TYPE=`cat ${MOD_INFO_FILE}`
	fi
}

check_hw()
{
	HARDWARE_MODEL=`grep Hardware /proc/cpuinfo | awk "{print \\$3}"`
	REVISION_NUM=`grep Revision /proc/cpuinfo | awk "{print \\$3}"`

	/bin/echo "Hardware Model=${HARDWARE_MODEL} Revision Number=${REVISION_NUM}"

	case $HARDWARE_MODEL in

		"TRATS2")
			/bin/echo "This is BCM4334B2"
			FIRMWARE_NET=${FIRMWARE_NET_BCM4334B2_58}
			FIRMWARE_MFT=${FIRMWARE_MFT_BCM4334B2_58}
			FIRMWARE_SOFTAP=${FIRMWARE_SOFTAP_BCM4334B2_58}
			FIRMWARE_P2P=${FIRMWARE_P2P_BCM4334B2_58}
			NVRAM_MFT=${NVRAM_MFT_BCM4334B2_SEMCO}

			check_module_type	# get module type for nvram selection
			NVRAM_NET=${NVRAM_NET_BCM4334B2_SEMCO}
			NVRAM_MFT=${NVRAM_NET_BCM4334B2_SEMCO}
			/bin/echo "There are no info, Use default SEMCO module type"
		;;

		"TRATS")
			/bin/echo "This is BCM4330B1"
			FIRMWARE_NET=${FIRMWARE_NET_BCM4330B1_342}
			FIRMWARE_SOFTAP=${FIRMWARE_SOFTAP_BCM4330B1_342}
			FIRMWARE_MFT=${FIRMWARE_MFT_BCM4330B1_342}
			FIRMWARE_P2P=${FIRMWARE_P2P_BCM4330B1_342}
			NVRAM_MFT=${NVRAM_MFT_BCM4330B1_SEMCO_OLD}

			check_module_type       # get module type for nvram selection
			NVRAM_NET=${NVRAM_NET_BCM4330B1_SEMCO_270}
			NVRAM_MFT=${NVRAM_MFT_BCM4330B1_SEMCO_OLD}
			echo "This is SEMCO module type"
		;;

		*)		/bin/echo "This model is not correctly comfirmed"

	esac
}

__start()
{
		/bin/echo ${FIRMWARE}
		/bin/echo ${NVRAM}
		${INSMOD_TOOL} ${DRIVER} firmware_path=${FIRMWARE} nvram_path=${NVRAM}
		/bin/sleep 1
		/sbin/ifconfig ${IFACE_NAME} up
}

start()
{
	check_hw
	if /sbin/ifconfig -a | /bin/grep ${IFACE_NAME} > /dev/null
	then
		/bin/echo "wlan.sh start exit 1"
		exit 1
	fi
	# Set default firmware and nvram
	FIRMWARE=${FIRMWARE_NET}
	NVRAM=${NVRAM_NET}
	__start
}

stop()
{
	check_hw
	# /sbin/ifconfig ${IFACE_NAME} down
	/bin/sleep 1
	/usr/sbin/rmmod dhd
}

softap()
{
	check_hw
	if /sbin/ifconfig -a | /bin/grep ${IFACE_NAME} > /dev/null
	then
		/bin/echo "wlan.sh softap exit 1"
		exit 1
	fi
	FIRMWARE=${FIRMWARE_SOFTAP}
	NVRAM=${NVRAM_NET}
	__start
}

p2p()
{
	check_hw
	if /sbin/ifconfig -a | /bin/grep ${IFACE_NAME} > /dev/null
	then
		/bin/echo "wlan.sh p2p exit 1"
		exit 1
	fi
	FIRMWARE=${FIRMWARE_P2P}
	NVRAM=${NVRAM_NET}
	__start
}


case $1 in
"start")
start
;;
"stop")
stop
;;
"check_hw")
check_hw
;;
"softap")
softap
;;
"p2p")
p2p
;;
*)
/bin/echo wlan.sh [start] [stop] [softap] [p2p] [check_hw]
exit 1
;;
esac
