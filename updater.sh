#!/sbin/busybox sh
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

check_mount() {
    local MOUNT_POINT=`busybox readlink $1`
    if ! busybox test -n "$MOUNT_POINT" ; then
        # readlink does not work on older recoveries for some reason
        # doesn't matter since the path is already correct in that case
        busybox echo "Using non-readlink mount point $1"
        MOUNT_POINT=$1
    fi
    if ! busybox grep -q $MOUNT_POINT /proc/mounts ; then
        busybox mkdir -p $MOUNT_POINT
        busybox umount -l $2
        if ! busybox mount -t $3 $2 $MOUNT_POINT ; then
            busybox echo "Cannot mount $1 ($MOUNT_POINT)."
            exit 1
        fi
    fi
}

set_log() {
    rm -rf $1
    exec >> $1 2>&1
}

fix_package_location() {
    local PACKAGE_LOCATION=$1
    # Remove leading /mnt
    PACKAGE_LOCATION=${PACKAGE_LOCATION#/mnt}
    # Convert to modern sdcard path
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | busybox sed -e "s|^/sdcard/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | busybox sed -e "s|^/emmc/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | busybox sed -e "s|^/external_sd/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | busybox sed -e "s|^/storage/sdcard1/||"`
    PACKAGE_LOCATION=`echo $PACKAGE_LOCATION | busybox sed -e "s|^/storage/sdcard1/||"`
    echo $PACKAGE_LOCATION
}

# ui_print by Chainfire
OUTFD=$(busybox ps | busybox grep -v "grep" | busybox grep -o -E "update_binary(.*)" | busybox cut -d " " -f 3);
ui_print() {
  if [ $OUTFD != "" ]; then
    echo "ui_print ${1} " 1>&$OUTFD;
    echo "ui_print " 1>&$OUTFD;
  else
    echo "${1}";
  fi;
}

set -x
export PATH=/:/sbin:/system/xbin:/system/bin:/tmp:$PATH

# Check if we're in CDMA or GSM mode
if busybox test "$1" = cdma ; then
    # CDMA mode
    IS_GSM='busybox false'
    SD_PART='/dev/block/mmcblk1p1'
    MTD_SIZE='490733568'
else
    # GSM mode
    IS_GSM='busybox true'
    SD_PART='/dev/block/mmcblk0p1'
    MTD_SIZE='454557696'

    EFS_PART=`busybox grep efs /proc/mtd | busybox awk '{print $1}'`
    EFS_PART=`busybox echo "$EFS_PART" | busybox sed 's/://g'`
    EFS_PART=`busybox echo "$EFS_PART" | busybox sed 's/mtd/mtdblock/g'`

    RADIO_PART=`busybox grep radio /proc/mtd | busybox awk '{print $1}'`
    RADIO_PART=`busybox echo "$RADIO_PART" | busybox sed 's/://g'`
    RADIO_PART=`busybox echo "$RADIO_PART" | busybox sed 's/mtd/mtdblock/g'`
fi

# Check if this is a CDMA device with no eMMC
if ! $IS_GSM && busybox test `cat /sys/devices/platform/s3c-sdhci.0/mmc_host/mmc0/mmc0:0001/type` != "MMC" ; then
   SD_PART='/dev/block/mmcblk0p1'
fi

# check for old/non-cwm recovery.
if ! busybox test -n "$UPDATE_PACKAGE" ; then
    # scrape package location from /tmp/recovery.log
    UPDATE_PACKAGE=`busybox cat /tmp/recovery.log | busybox grep 'Update location:' | busybox tail -n 1 | busybox cut -d ' ' -f 3-`
fi

# check if we're running on a bml, mtd (old) or mtd (current) device
if busybox test -e /dev/block/bml7 ; then
    # we're running on a bml device

    # make sure sdcard is mounted
    check_mount /mnt/sdcard $SD_PART vfat

    # everything is logged into /mnt/sdcard/omni_bml.log
    set_log /mnt/sdcard/omni_bml.log

    if $IS_GSM ; then
        # make sure efs is mounted
        check_mount /efs /dev/block/stl3 rfs

        # create a backup of efs
        if busybox test -e /mnt/sdcard/backup/efs ; then
            busybox mv /mnt/sdcard/backup/efs /mnt/sdcard/backup/efs-$$
        fi
        busybox rm -rf /mnt/sdcard/backup/efs

        busybox mkdir -p /mnt/sdcard/backup/efs
        busybox cp -R /efs/ /mnt/sdcard/backup
    fi

    # write the package path to sdcard omni.cfg
    if busybox test -n "$UPDATE_PACKAGE" ; then
        busybox echo `fix_package_location $UPDATE_PACKAGE` > /mnt/sdcard/omni.cfg
    fi

    # Scorch any ROM Manager settings to require the user to reflash recovery
    busybox rm -f /mnt/sdcard/TWRP/.settings

    # write new kernel to boot partition
    /tmp/flash_image boot /tmp/boot.img
    if [ "$?" != "0" ] ; then
        exit 3
    fi
    busybox sync

    /sbin/reboot now
    exit 0

elif busybox test `busybox cat /sys/class/mtd/mtd2/size` != "$MTD_SIZE" || \
    busybox test `busybox cat /sys/class/mtd/mtd2/name` != "system" ; then
    # we're running on a mtd (old) device

    # make sure sdcard is mounted
    check_mount /sdcard $SD_PART vfat

    # everything is logged into /sdcard/omni_mtd_old.log
    set_log /sdcard/omni_mtd_old.log

    if ! busybox test -e /cache/.accept_wipe ; then
        busybox touch /cache/.accept_wipe
        ui_print
        ui_print "============================================"
        ui_print "This ROM uses an incompatible partition layout"
        ui_print "Your /data will be wiped upon installation"
        ui_print "Run this update.zip again to confirm install"
        ui_print "============================================"
        ui_print
        exit 9
    fi
    busybox rm /cache/.accept_wipe

    # write the package path to sdcard omni.cfg
    if busybox test -n "$UPDATE_PACKAGE" ; then
        busybox echo `fix_package_location $UPDATE_PACKAGE` > /sdcard/omni.cfg
    fi

    if $IS_GSM ; then
        # make sure efs is mounted
        check_mount /efs /dev/block/$EFS_PART yaffs2

        # create a backup of efs
        if busybox test -e /sdcard/backup/efs ; then
            busybox mv /sdcard/backup/efs /sdcard/backup/efs-$$
        fi
        busybox rm -rf /sdcard/backup/efs

        busybox mkdir -p /sdcard/backup/efs
        busybox cp -R /efs/ /sdcard/backup
    fi

    # write new kernel to boot partition
    /tmp/bml_over_mtd.sh boot 72 reservoir 2004 /tmp/boot.img

    # Remove /system/build.prop to trigger emergency boot
    busybox mount /system
    busybox rm -f /system/build.prop
    busybox umount -l /system

    busybox sync

    /sbin/reboot now
    exit 0

elif busybox test -e /dev/block/mtdblock0 ; then
    # we're running on a mtd (current) device

    # make sure sdcard is mounted
    check_mount /sdcard $SD_PART vfat

    # everything is logged into /sdcard/omni.log
    set_log /sdcard/omni_mtd.log

    if $IS_GSM ; then
        # create mountpoint for radio partition
        busybox mkdir -p /radio

        # make sure radio partition is mounted
        if ! busybox grep -q /radio /proc/mounts ; then
            busybox umount -l /dev/block/$RADIO_PART
            if ! busybox mount -t yaffs2 /dev/block/$RADIO_PART /radio ; then
                busybox echo "Cannot mount radio partition."
                exit 5
            fi
        fi

        # if modem.bin doesn't exist on radio partition, format the partition and copy it
        if ! busybox test -e /radio/modem.bin ; then
            busybox umount -l /dev/block/$RADIO_PART
            /tmp/erase_image radio
            if ! busybox mount -t yaffs2 /dev/block/$RADIO_PART /radio ; then
                busybox echo "Cannot copy modem.bin to radio partition."
                exit 5
            else
                busybox cp /tmp/modem.bin /radio/modem.bin
            fi
        fi

        # unmount radio partition
        busybox umount -l /radio
    fi

    if ! busybox test -e /sdcard/omni.cfg ; then
        # update install - flash boot image then skip back to updater-script
        # (boot image is already flashed for first time install or old mtd upgrade)

        # flash boot image
        /tmp/bml_over_mtd.sh boot 72 reservoir 2004 /tmp/boot.img

        # unmount system (recovery seems to expect system to be unmounted)
        busybox umount -l /system

        exit 0
    fi

    # if a omni.cfg exists, then this is a first time install
    # let's format the volumes and restore modem and efs

    # remove the omni.cfg to prevent this from looping
    busybox rm -f /sdcard/omni.cfg

    # unmount and format system (recovery seems to expect system to be unmounted)
    # unmount and format data
    busybox umount -l /data
    busybox umount -l /system

    /tmp/make_ext4fs -b 4096 -g 32768 -i 8192 -I 256 -a /data /dev/block/mmcblk0p2
    /tmp/erase_image system

    # restart into recovery so the user can install further packages before booting
    busybox touch /cache/.startrecovery

    if $IS_GSM ; then
        # restore efs backup
        if busybox test -e /sdcard/backup/efs/nv_data.bin ; then
            busybox umount -l /efs
            /tmp/erase_image efs
            busybox mkdir -p /efs

            if ! busybox grep -q /efs /proc/mounts ; then
                if ! busybox mount -t yaffs2 /dev/block/$EFS_PART /efs ; then
                    busybox echo "Cannot mount efs."
                    exit 6
                fi
            fi

            busybox cp -R /sdcard/backup/efs /
            busybox umount -l /efs
        else
            busybox echo "Cannot restore efs."
            exit 7
        fi
    fi

    exit 0
fi
