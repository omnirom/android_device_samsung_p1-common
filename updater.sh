#!/tmp/busybox sh
#
# Copyright (C) 2008 The Android Open-Source Project
# Copyright (C) 2012 by Teamhacksung
# Copyright (C) 2013 OmniROM Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Universal Updater Script for Samsung Galaxy Tab 7"
# Combined GSM & CDMA version
#

SYSTEM_SIZE='629145600' # 600M

check_mount() {
    local MOUNT_POINT=`/tmp/busybox readlink $1`
    if ! /tmp/busybox test -n "$MOUNT_POINT" ; then
        # readlink does not work on older recoveries for some reason
        # doesn't matter since the path is already correct in that case
        /tmp/busybox echo "Using non-readlink mount point $1"
        MOUNT_POINT=$1
    fi
    if ! /tmp/busybox grep -q $MOUNT_POINT /proc/mounts ; then
        /tmp/busybox mkdir -p $MOUNT_POINT
        /tmp/busybox umount -l $2
        if ! /tmp/busybox mount -t $3 $2 $MOUNT_POINT ; then
            /tmp/busybox echo "Cannot mount $1 ($MOUNT_POINT)."
            exit 1
        fi
    fi
}

set_log() {
    rm -rf $1
    exec >> $1 2>&1
}

# ui_print
OUTFD=$(/tmp/busybox ps | /tmp/busybox grep -v "grep" | /tmp/busybox grep -o -E "/tmp/updater .*" | /tmp/busybox cut -d " " -f 3);
if /tmp/busybox test -e /tmp/update_binary ; then
    OUTFD=$(/tmp/busybox ps | /tmp/busybox grep -v "grep" | /tmp/busybox grep -o -E "update_binary(.*)" | /tmp/busybox cut -d " " -f 3);
fi

ui_print() {
  if [ $OUTFD != "" ]; then
    echo "ui_print ${1} " 1>&$OUTFD;
    echo "ui_print " 1>&$OUTFD;
  else
    echo "${1}";
  fi;
}

warn_repartition() {
    if ! /tmp/busybox test -e /tmp/.accept_wipe ; then
        /tmp/busybox touch /tmp/.accept_wipe
        ui_print ""
        ui_print "============================================"
        ui_print "ATTENTION"
        ui_print ""
        ui_print "This VERSION uses an incompatible partition layout"
        ui_print "Your /data will be wiped upon installation"
        ui_print "So, make your backups (if you want) and then just"
        ui_print "Run this update.zip again to confirm install"
        ui_print ""
        ui_print "ATTENTION"
        ui_print "============================================"
        ui_print ""
        exit 9
    fi
    /tmp/busybox rm -fr /tmp/.accept_wipe
}

format_partitions() {
    /lvm/sbin/lvm lvcreate -L ${SYSTEM_SIZE}B -n system lvpool
    /lvm/sbin/lvm lvcreate -l 100%FREE -n userdata lvpool

    # format data (/system will be formatted by updater-script)
    /tmp/make_ext4fs -b 4096 -g 32768 -i 8192 -I 256 -l -16384 -a /data /dev/lvpool/userdata

    # unmount and format datadata
    /tmp/busybox umount -l /datadata
    /tmp/erase_image datadata
}

fix_package_location() {
    local PACKAGE_LOCATION=$1
    # Remove leading /mnt for Samsung recovery
    PACKAGE_LOCATION=${PACKAGE_LOCATION#/mnt}
    # Convert to modern sdcard path
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | /tmp/busybox sed -e "s|^/sdcard/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | /tmp/busybox sed -e "s|^/emmc/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | /tmp/busybox sed -e "s|^/external_sd/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | /tmp/busybox sed -e "s|^/storage/sdcard0/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | /tmp/busybox sed -e "s|^/storage/sdcard1/||"`
    echo $PACKAGE_LOCATION
}

set -x
export PATH=/:/sbin:/system/xbin:/system/bin:/tmp:$PATH

# Check if we're in CDMA or GSM mode
if /tmp/busybox test "$1" = cdma ; then
    # CDMA mode
    IS_GSM='/tmp/busybox false'
    SD_PART='/dev/block/mmcblk1p1'
    MMC_PART1='/dev/block/mmcblk0p1'
    MMC_PART2='/dev/block/mmcblk0p2'
    MTD_SIZE='490733568'
else
    # GSM mode
    IS_GSM='/tmp/busybox true'
    SD_PART='/dev/block/mmcblk0p1'
    MMC_PART1='/dev/block/mmcblk0p2'
    MMC_PART2='/dev/block/mmcblk0p3'
    MTD_SIZE='442499072'
    EFS_PART=`/tmp/busybox grep efs /proc/mtd | /tmp/busybox awk '{print $1}' | /tmp/busybox sed 's/://g' | /tmp/busybox sed 's/mtd/mtdblock/g'`
    RADIO_PART=`/tmp/busybox grep radio /proc/mtd | /tmp/busybox awk '{print $1}' | /tmp/busybox sed 's/://g' | /tmp/busybox sed 's/mtd/mtdblock/g'`
fi

setup_lvm_partitions() {
    /tmp/busybox dd if=/dev/zero of=$MMC_PART1 bs=1k count=1
    /tmp/busybox blockdev --rereadpt $MMC_PART1

    /tmp/busybox dd if=/dev/zero of=$MMC_PART2 bs=1k count=1
    /tmp/busybox blockdev --rereadpt $MMC_PART2

    /lvm/sbin/lvm vgremove -f lvpool
    /lvm/sbin/lvm lvremove -f lvpool
    /lvm/sbin/lvm pvcreate $MMC_PART1 $MMC_PART2
    /lvm/sbin/lvm vgcreate lvpool $MMC_PART1 $MMC_PART2
}

# Check if this is a CDMA device with no eMMC
if ! $IS_GSM && /tmp/busybox test `cat /sys/devices/platform/s3c-sdhci.0/mmc_host/mmc0/mmc0:0001/type` != "MMC" ; then
   SD_PART='/dev/block/mmcblk0p1'
fi

# check for old/non-cwm recovery.
if ! /tmp/busybox test -n "$UPDATE_PACKAGE" ; then
    # scrape package location from /tmp/recovery.log
    UPDATE_PACKAGE=`/tmp/busybox cat /tmp/recovery.log | /tmp/busybox grep 'Update location:' | /tmp/busybox tail -n 1 | /tmp/busybox cut -d ' ' -f 3-`
fi

# check if we're running on a bml, mtd (old) or mtd (current) device
if /tmp/busybox test -e /dev/block/bml7 ; then
    # we're running on a bml device

    # make sure sdcard is mounted
    check_mount /mnt/sdcard $SD_PART vfat

    # everything is logged into /mnt/sdcard/omni_bml.log
    set_log /mnt/sdcard/omni_bml.log

    if $IS_GSM ; then
        # make sure efs is mounted
        check_mount /efs /dev/block/stl3 rfs

        # create a backup of efs
        if /tmp/busybox test -e /mnt/sdcard/backup/efs ; then
            /tmp/busybox mv /mnt/sdcard/backup/efs /mnt/sdcard/backup/efs-$$
        fi
        /tmp/busybox rm -rf /mnt/sdcard/backup/efs

        /tmp/busybox mkdir -p /mnt/sdcard/backup/efs
        /tmp/busybox cp -R /efs/ /mnt/sdcard/backup
    fi

    # write the package path to sdcard omni.cfg
    if /tmp/busybox test -n "$UPDATE_PACKAGE" ; then
        /tmp/busybox echo `fix_package_location $UPDATE_PACKAGE` > /mnt/sdcard/omni.cfg
    fi

    # write new kernel to boot partition
    /tmp/flash_image boot /tmp/boot.img
    if [ "$?" != "0" ] ; then
        exit 3
    fi
    /tmp/busybox sync

    /sbin/reboot now
    exit 0

elif /tmp/busybox test `/tmp/busybox cat /sys/class/mtd/mtd2/size` != "$MTD_SIZE" || \
    /tmp/busybox test `/tmp/busybox cat /sys/class/mtd/mtd2/name` != "datadata" ; then
    # we're running on a mtd (old) device

    # make sure sdcard is mounted
    check_mount /sdcard $SD_PART vfat

    # everything is logged into /sdcard/omni_mtd_old.log
    set_log /sdcard/omni_mtd_old.log

    warn_repartition

    # write the package path to sdcard omni.cfg
    if /tmp/busybox test -n "$UPDATE_PACKAGE" ; then
        /tmp/busybox echo `fix_package_location $UPDATE_PACKAGE` > /sdcard/omni.cfg
    fi

    if $IS_GSM ; then
        # make sure efs is mounted
        check_mount /efs /dev/block/$EFS_PART yaffs2

        # create a backup of efs
        if /tmp/busybox test -e /sdcard/backup/efs ; then
            /tmp/busybox mv /sdcard/backup/efs /sdcard/backup/efs-$$
        fi
        /tmp/busybox rm -rf /sdcard/backup/efs

        /tmp/busybox mkdir -p /sdcard/backup/efs
        /tmp/busybox cp -R /efs/ /sdcard/backup
    fi

    # write new kernel to boot partition
    /tmp/bml_over_mtd.sh boot 72 reservoir 2004 /tmp/boot.img

    # Remove /system/build.prop to trigger emergency boot
    /tmp/busybox mount /system
    /tmp/busybox rm -f /system/build.prop
    /tmp/busybox umount -l /system

    /tmp/busybox sync

    /sbin/reboot now
    exit 0

elif /tmp/busybox test -e /dev/block/mtdblock0 ; then
    # we're running on a mtd (current) device

    # make sure sdcard is mounted
    check_mount /sdcard $SD_PART vfat

    # everything is logged into /sdcard/omni.log
    set_log /sdcard/omni_mtd.log

    # unmount system and data (recovery seems to expect system to be unmounted)
    /tmp/busybox umount -l /system
    /tmp/busybox umount -l /data

    # Resize partitions
    # (For first install, this will get skipped because device doesn't exist)
    if /tmp/busybox test -e /dev/mapper/lvpool-system ; then
        if /tmp/busybox test `/tmp/busybox blockdev --getsize64 /dev/mapper/lvpool-system` -ne $SYSTEM_SIZE ; then
            warn_repartition
            setup_lvm_partitions
            format_partitions
        fi
    fi

    if $IS_GSM ; then
        # create mountpoint for radio partition
        /tmp/busybox mkdir -p /radio

        # make sure radio partition is mounted
        if ! /tmp/busybox grep -q /radio /proc/mounts ; then
            /tmp/busybox umount -l /dev/block/$RADIO_PART
            if ! /tmp/busybox mount -t yaffs2 /dev/block/$RADIO_PART /radio ; then
                /tmp/busybox echo "Cannot mount radio partition."
                exit 5
            fi
        fi

        # if modem.bin doesn't exist on radio partition, format the partition and copy it
        if ! /tmp/busybox test -e /radio/modem.bin ; then
            /tmp/busybox umount -l /dev/block/$RADIO_PART
            /tmp/erase_image radio
            if ! /tmp/busybox mount -t yaffs2 /dev/block/$RADIO_PART /radio ; then
                /tmp/busybox echo "Cannot copy modem.bin to radio partition."
                exit 5
            else
                /tmp/busybox cp /tmp/modem.bin /radio/modem.bin
            fi
        fi

        # unmount radio partition
        /tmp/busybox umount -l /radio
    fi

    if ! /tmp/busybox test -e /sdcard/omni.cfg && \
            /tmp/busybox test -e /dev/mapper/lvpool-system ; then
        # update install - flash boot image then skip back to updater-script
        # (boot image is already flashed for first time install or old mtd upgrade)

        # flash boot image
        /tmp/bml_over_mtd.sh boot 72 reservoir 2004 /tmp/boot.img

        if ! $IS_GSM ; then
            /tmp/bml_over_mtd.sh recovery 102 reservoir 2004 /tmp/recovery_kernel
        fi

        exit 0
    fi

    # if a omni.cfg exists, then this is a first time install
    # let's format the volumes and restore radio and efs

    # remove the omni.cfg to prevent this from looping
    /tmp/busybox rm -f /sdcard/omni.cfg

    # setup lvm volumes
    if ! /tmp/busybox test -e /dev/mapper/lvpool-system ; then
        /tmp/busybox umount -l /cache
        /tmp/erase_image cache
        setup_lvm_partitions
        format_partitions
    fi

    /tmp/busybox mount -t yaffs2 /dev/block/mtdblock3 /cache

    # restart into recovery so the user can install further packages before booting
    /tmp/busybox touch /cache/.startrecovery

    if $IS_GSM ; then
        # restore efs backup
        if /tmp/busybox test -e /sdcard/backup/efs/nv_data.bin ; then
            /tmp/busybox umount -l /efs
            /tmp/erase_image efs
            /tmp/busybox mkdir -p /efs

            if ! /tmp/busybox grep -q /efs /proc/mounts ; then
                if ! /tmp/busybox mount -t yaffs2 /dev/block/$EFS_PART /efs ; then
                    /tmp/busybox echo "Cannot mount efs."
                    exit 6
                fi
            fi

            /tmp/busybox cp -R /sdcard/backup/efs /
            /tmp/busybox umount -l /efs
        else
            /tmp/busybox echo "Cannot restore efs."
            exit 7
        fi
    fi

    exit 0
fi

