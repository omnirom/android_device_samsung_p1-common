#
# Copyright (C) 2012 The CyanogenMod Project
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

INSTALLED_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/boot.img

uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk.cpio
$(uncompressed_ramdisk): $(INSTALLED_RAMDISK_TARGET)
	zcat $< > $@

TARGET_KERNEL_BINARIES: $(KERNEL_OUT) $(KERNEL_CONFIG) $(KERNEL_HEADERS_INSTALL) $(recovery_uncompressed_ramdisk) $(uncompressed_ramdisk)
	$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(TARGET_ARCH) $(ARM_CROSS_COMPILE) $(TARGET_PREBUILT_INT_KERNEL_TYPE)
	-$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(TARGET_ARCH) $(ARM_CROSS_COMPILE) modules
	-$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT) INSTALL_MOD_PATH=../../$(KERNEL_MODULES_INSTALL) ARCH=$(TARGET_ARCH) $(ARM_CROSS_COMPILE) modules_install

$(INSTALLED_BOOTIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET) $(PRODUCT_OUT)/utilities/busybox $(PRODUCT_OUT)/utilities/erase_image $(PRODUCT_OUT)/utilities/flash_image $(PRODUCT_OUT)/utilities/make_ext4fs
	$(ACP) -fp $< $@

$(INSTALLED_RECOVERYIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET)
	$(ACP) -fp $< $@
