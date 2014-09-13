/*
 * Copyright (C) 2013 The OmniROM Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.omnirom.device;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.CheckBoxPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceManager;

public class ZramDisable implements OnPreferenceChangeListener {

    private static final String FILE = "/data/misc/zram/num_devices";
    private static final String FILE_DRIVER = "/sys/block/zram0/dev";

    public static boolean isSupported() {
        return (Utils.fileExists(FILE) && Utils.fileExists(FILE_DRIVER));
    }

    public static void restore(Context context) {
        if (!isSupported()) {
            return;
        }

        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        Utils.writeValue(FILE, (sharedPrefs.getBoolean(DeviceSettings.KEY_ZRAM_DISABLE, false) ? "0" : "1"));
    }

    public boolean onPreferenceChange(Preference preference, Object newValue) {
        Utils.writeValue(FILE, ((CheckBoxPreference)preference).isChecked() ? "1" : "0");
        return true;
    }

}
