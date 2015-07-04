#
# Copyright (C) 2008 The Android Open-Source Project
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

# BoardConfigCommon.mk
#
# Product-specific compile-time definitions.
#

# Set this up here so that BoardVendorConfig.mk can override it
BOARD_USES_GENERIC_AUDIO := false
AUDIO_FEATURE_ENABLED_INCALL_MUSIC := false
AUDIO_FEATURE_ENABLED_COMPRESS_VOIP := false

# ARMv7-A Cortex-A8 architecture
TARGET_ARCH := arm
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_ARCH_VARIANT_CPU := cortex-a8
TARGET_CPU_VARIANT := cortex-a8
TARGET_CPU_SMP := false
KERNEL_TOOLCHAIN := "$(ANDROID_BUILD_TOP)/prebuilts/gcc/$(strip $(HOST_OS))-x86/arm/arm-eabi-4.7/bin/"

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

TARGET_BOARD_PLATFORM := s5pc110
TARGET_BOARD_PLATFORM_GPU := POWERVR_SGX540_120
TARGET_BOOTLOADER_BOARD_NAME := s5pc110

# Bionic stuff
BOARD_USES_LEGACY_MMAP := true
TARGET_NEEDS_BIONIC_MD5 := true
TARGET_NEEDS_BIONIC_PRELINK_SUPPORT := true
TARGET_ENABLE_NON_PIE_SUPPORT := true
MALLOC_IMPL := dlmalloc

# RIL
BOARD_USES_LIBSECRIL_STUB := true
BOARD_RIL_CLASS := ../../../hardware/samsung/exynos3/s5pc110/ril/

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/samsung/p1-common/bluetooth
BOARD_BLUEDROID_VENDOR_CONF := device/samsung/p1-common/bluetooth/libbt_vndcfg.txt

# WiFi related defines
BOARD_NO_WIFI_HAL           := true
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WPA_SUPPLICANT_VERSION      := VER_0_8_X
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER        := NL80211
BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_bcmdhd
BOARD_WLAN_DEVICE           := bcmdhd
BOARD_WLAN_DEVICE_REV       := bcm4329
WIFI_DRIVER_MODULE_NAME     := "bcmdhd"
WIFI_DRIVER_FW_PATH_PARAM   := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA     := "/vendor/firmware/fw_bcmdhd.bin"
WIFI_DRIVER_FW_PATH_AP      := "/vendor/firmware/fw_bcmdhd_apsta.bin"

# Camera HAL
USE_CAMERA_STUB := false
ifeq ($(USE_CAMERA_STUB),false)
BOARD_CAMERA_LIBRARIES := libcamera
endif
BOARD_V4L2_DEVICE := /dev/video1
BOARD_CAMERA_DEVICE := /dev/video0
BOARD_SECOND_CAMERA_DEVICE := /dev/video2
BOARD_CAMERA_HAVE_ISO := true

# OpenGL stuff
BOARD_EGL_CFG := device/samsung/p1-common/rootdir/system/lib/egl/egl.cfg
USE_OPENGL_RENDERER := true
BOARD_ALLOW_EGL_HIBERNATION := true
BOARD_EGL_WORKAROUND_BUG_10194508 := true
BOARD_EGL_SYSTEMUI_PBSIZE_HACK := true
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK := true

# Enable dex-preoptimization to speed up first boot sequence
ifeq ($(HOST_OS),linux)
    WITH_DEXPREOPT := true
    WITH_DEXPREOPT_BOOT_IMG_ONLY := true
    DONT_DEXPREOPT_PREBUILTS := true
endif

# Device related defines
BOARD_NAND_PAGE_SIZE := 4096
BOARD_NAND_SPARE_SIZE := 128
BOARD_KERNEL_BASE := 0x32000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_BOOTIMAGE_PARTITION_SIZE := 7864320
BOARD_FLASH_BLOCK_SIZE := 4096

# Vold
BOARD_VOLD_EMMC_SHARES_DEV_MAJOR := true
TARGET_USE_CUSTOM_LUN_FILE_PATH := "/sys/devices/platform/s3c-usbgadget/gadget/lun%d/file"
BOARD_USES_MULTIPLE_SDCARD_FS := true

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := device/samsung/p1-common

# Samsung EMMC brick bug
# Already disabled in kernel, but disable again for safety
BOARD_SUPPRESS_EMMC_WIPE := true

# Boot Animation
TARGET_BOOTANIMATION_TEXTURE_CACHE := false
TARGET_BOOTANIMATION_USE_RGB565 := true

# Open Source Charging Mode
BOARD_USES_OWN_CHARGER := true
BOARD_POWER_SUPPLY_PATH := /sys/class/power_supply
BOARD_BATTERY_SYSFS_PATH := $(BOARD_POWER_SUPPLY_PATH)/battery
BOARD_AC_SYSFS_PATH := $(BOARD_POWER_SUPPLY_PATH)/ac
BOARD_USB_SYSFS_PATH := $(BOARD_POWER_SUPPLY_PATH)/usb
BOARD_CHARGER_ENABLE_SUSPEND := true
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../../device/samsung/p1-common/recovery/keys.c
BOARD_CUSTOM_GRAPHICS := ../../../device/samsung/p1-common/recovery/graphics.c

# TARGET_DISABLE_TRIPLE_BUFFERING can be used to disable triple buffering
# on per target basis. On crespo it is possible to do so in theory
# to save memory, however, there are currently some limitations in the
# OpenGL ES driver that in conjunction with disable triple-buffering
# would hurt performance significantly (see b/6016711)
TARGET_DISABLE_TRIPLE_BUFFERING := false

# OMX buffer reallocate
BOARD_CANT_REALLOCATE_OMX_BUFFERS := true

# hwcomposer: custom vsync ioctl
BOARD_CUSTOM_VSYNC_IOCTL := true

# Include an expanded selection of fonts
EXTENDED_FONT_FOOTPRINT := true

# TWRP
BOARD_USES_BML_OVER_MTD := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_RECOVERY_PRE_COMMAND := "echo 1 > /cache/.startrecovery; sync;"
TARGET_RECOVERY_PIXEL_FORMAT := "RGB_565"
BOARD_HAS_FLIPPED_SCREEN := true
RECOVERY_TOUCHSCREEN_FLIP_Y := true
RECOVERY_TOUCHSCREEN_FLIP_X := true
TW_THEME := landscape_mdpi
TW_EXCLUDE_MTP := true
TW_NO_REBOOT_BOOTLOADER := true
TW_USE_MODEL_HARDWARE_ID_FOR_DEVICE_ID := true
TW_INCLUDE_FB2PNG := true
TW_FLASH_FROM_STORAGE := true
TW_NO_PARTITION_SD_CARD := true
TW_EXCLUDE_SUPERSU := true
TW_INTERNAL_STORAGE_PATH := "/sdcard"
TW_INTERNAL_STORAGE_MOUNT_POINT := "sdcard"
TW_MAX_BRIGHTNESS := 255
TW_BRIGHTNESS_PATH := /sys/devices/platform/s3cfb/cmc623_pwm_bl/backlight/s5p_bl/brightness

# SELinux
BOARD_SEPOLICY_DIRS += \
    device/samsung/p1-common/sepolicy

BOARD_SEPOLICY_UNION += \
    bluetooth.te \
    debuggerd.te \
    device.te \
    file.te \
    file_contexts \
    gpsd.te \
    init.te \
    installd.te \
    kernel.te \
    lvm.te \
    mediaserver.te \
    netd.te \
    platform_app.te \
    property_contexts \
    pvrsrvinit.te \
    radio.te \
    recovery.te \
    rild.te \
    sdcardd.te \
    servicemanager.te \
    shared_relro.te \
    shell.te \
    surfaceflinger.te \
    system_app.te \
    system_server.te \
    ueventd.te \
    untrusted_app.te \
    zygote.te
