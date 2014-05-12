
##
# HD
#
HD_HOME="/home/shared/Virt/KvmQemu/disks"
HD_DISK="NetBSD-6.1.2-amd64_1/NetBSD-6.1.2-amd64.qcow2"
HD_HDA="$HD_HOME/$HD_DISK"

##
# CD
#
CD_HOME="/home/shared/Virt/KvmQemu/isodvd"
CD_DISK="NetBSD-6.1.2-amd64/NetBSD-6.1.2-amd64.iso"
CD_ISO="$CD_HOME/$CD_DISK"

##
# OPT
#
OPT_FLAGS="-no-acpi"
OPT_RAMSIZE="-m 512"
OPT_NOGRAPHIC="-nographic -monitor tcp:127.0.0.1:30002,server,nowait"
OPT_DAEMONIZE="-daemonize"
OPT_BOOTFROMCD="-boot d"

##
# NET
#
NET_PARAM1="-net nic,vlan=1 -net tap,vlan=1,macaddr=52:54:00:12:34:56,ifname=tap0,script=no"
NET_PARAM2="-net nic,vlan=3 -net tap,vlan=3,macaddr=52:54:00:12:34:57,ifname=tap3,script=no"
NET_PARAMS="NET_PARAM1 $NET_PARAM2"