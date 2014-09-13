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
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceManager;

public class ZramDiskSize implements OnPreferenceChangeListener {

    private static final String FILE = "/data/misc/zram/disksize";
    private static final String FILE_DRIVER = "/sys/block/zram0/dev";

    public static boolean isSupported() {
        return (Utils.fileExists(FILE) && Utils.fileExists(FILE_DRIVER));
    }

    public static void restore(Context context) {
        if (!isSupported()) {
            return;
        }

        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        Utils.writeValue(FILE, sharedPrefs.getString(DeviceSettings.KEY_ZRAM_DISK_SIZE, "128M"));
    }

    public boolean onPreferenceChange(Preference preference, Object newValue) {
        Utils.writeValue(FILE, (String) newValue);
        updateSummary((ListPreference) preference, newValue.toString());
        return true;
    }

    public static void updateSummary(ListPreference preference, String value) {
        final CharSequence[] entries = preference.getEntries();
        final CharSequence[] values = preference.getEntryValues();
        int best = 0;
        for (int i = 0; i < values.length; i++) {
            String summaryValue = values[i].toString();
            if (value.equals(summaryValue)) {
                best = i;
            }
        }
        preference.setSummary(entries[best].toString());
    }
}
