#
# Copyright (C) 2011 Pawit Pornkitprasan
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

The proprietary daemon "tvoutserver" expects the system to tell it
when the frames should be refreshed. Samsung implemented this by
integrating TV Out in surfaceflinger and other graphic services.
However, we will just run a daemon that brute sends the signal every
150 ms.
