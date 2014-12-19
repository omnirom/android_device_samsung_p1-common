#
# Copyright (C) 2012 The CyanogenMod Project
# Copyright (C) 2012 The Android Open-Source Project
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

"""Custom OTA commands for p1"""

import common
import os

TARGET_DIR = os.getenv('OUT')
UTILITIES_DIR = os.path.join(TARGET_DIR, 'utilities')
TARGET_DEVICE = os.getenv('CUSTOM_BUILD')

def FullOTA_Assertions(info):
  if TARGET_DEVICE != "p1c":
    info.output_zip.write(os.path.join(TARGET_DIR, "modem.bin"), "modem.bin")

    if TARGET_DEVICE == "p1":
      info.output_zip.write(os.path.join(TARGET_DIR, "p1ln.sh"), "p1ln.sh")
      info.output_zip.write(os.path.join(TARGET_DIR, "boot_p1ln.img"), "boot_p1ln.img")

  info.output_zip.write(os.path.join(TARGET_DIR, "updater.sh"), "updater.sh")
  info.output_zip.write(os.path.join(UTILITIES_DIR, "make_ext4fs"), "make_ext4fs")
  info.output_zip.write(os.path.join(UTILITIES_DIR, "busybox"), "busybox")
  info.output_zip.write(os.path.join(UTILITIES_DIR, "flash_image"), "flash_image")
  info.output_zip.write(os.path.join(UTILITIES_DIR, "erase_image"), "erase_image")
  info.output_zip.write(os.path.join(UTILITIES_DIR, "bml_over_mtd"), "bml_over_mtd")
  info.output_zip.write(os.path.join(TARGET_DIR, "bml_over_mtd.sh"), "bml_over_mtd.sh")

  if TARGET_DEVICE != "p1c":
    info.script.AppendExtra(
          ('package_extract_file("modem.bin", "/tmp/modem.bin");\n'
           'set_metadata("/tmp/modem.bin", "uid", 0, "gid", 0, "mode", 0777);'))

    if TARGET_DEVICE == "p1":
      info.script.AppendExtra(
            ('package_extract_file("p1ln.sh", "/tmp/p1ln.sh");\n'
             'set_metadata("/tmp/p1ln.sh", "uid", 0, "gid", 0, "mode", 0777);'))

  info.script.AppendExtra(
        ('package_extract_file("updater.sh", "/tmp/updater.sh");\n'
         'set_metadata("/tmp/updater.sh", "uid", 0, "gid", 0, "mode", 0777);'))
  info.script.AppendExtra(
       ('package_extract_file("make_ext4fs", "/tmp/make_ext4fs");\n'
        'set_metadata("/tmp/make_ext4fs", "uid", 0, "gid", 0, "mode", 0777);'))
  info.script.AppendExtra(
        ('package_extract_file("busybox", "/tmp/busybox");\n'
         'set_metadata("/tmp/busybox", "uid", 0, "gid", 0, "mode", 0777);'))
  info.script.AppendExtra(
        ('package_extract_file("flash_image", "/tmp/flash_image");\n'
         'set_metadata("/tmp/flash_image", "uid", 0, "gid", 0, "mode", 0777);'))
  info.script.AppendExtra(
        ('package_extract_file("erase_image", "/tmp/erase_image");\n'
         'set_metadata("/tmp/erase_image", "uid", 0, "gid", 0, "mode", 0777);'))
  info.script.AppendExtra(
        ('package_extract_file("bml_over_mtd", "/tmp/bml_over_mtd");\n'
         'set_metadata("/tmp/bml_over_mtd", "uid", 0, "gid", 0, "mode", 0777);'))
  info.script.AppendExtra(
        ('package_extract_file("bml_over_mtd.sh", "/tmp/bml_over_mtd.sh");\n'
         'set_metadata("/tmp/bml_over_mtd.sh", "uid", 0, "gid", 0, "mode", 0777);'))

  info.script.AppendExtra('package_extract_file("boot.img", "/tmp/boot.img");')

  if TARGET_DEVICE == "p1c":
    info.script.AppendExtra('assert(run_program("/tmp/updater.sh", "cdma") == 0);')
  else:
    if TARGET_DEVICE == "p1":
      info.script.AppendExtra('package_extract_file("boot_p1ln.img", "/tmp/boot_p1ln.img");')
      info.script.AppendExtra('assert(run_program("/tmp/p1ln.sh") == 0);')

    info.script.AppendExtra('assert(run_program("/tmp/updater.sh") == 0);')

def FullOTA_InstallEnd(info):
  # Remove writing boot.img from script (we do it in updater.sh)
  info.script.script = [cmd for cmd in info.script.script if not "write_raw_image" in cmd]
