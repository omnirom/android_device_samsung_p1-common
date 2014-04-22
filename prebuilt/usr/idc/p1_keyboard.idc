# Copyright (C) 2010 The Android Open Source Project
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

# The following input device configuration properties are used for keyboards.

# Specifies the name of the key layout file associated with the input device,
# excluding the .kl extension. If this file is not found, the input system will
# use the default key layout instead.
keyboard.layout = p1_keyboard

# The keyboard is internal because it is part of the device.
device.internal = 0

# The keyboard is the default built-in keyboard so it should be assigned
# an id of 0.
keyboard.builtIn = 0

# The keyboard includes a DPad which is mounted on the device.  As the device
# is rotated the orientation of the DPad rotates along with it, so the DPad must
# be aware of the display orientation.  This ensures that pressing 'up' on the
# DPad always means 'up' from the perspective of the user, even when the entire
# device has been rotated.
keyboard.orientationAware = 0
