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
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.preference.PreferenceScreen;
import android.util.Log;

import org.omnirom.device.R;

public class ZramFragmentActivity extends PreferenceFragment {

    private static final String PREF_ENABLED = "1";
    private static final String TAG = "DeviceSettings_Zram";

    private CheckBoxPreference mZramDisable;
    private ListPreference mZramMaxCompStream;
    private ListPreference mZramCompAlgorithm;
    private ListPreference mZramDiskSize;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        addPreferencesFromResource(R.xml.zram_preferences);

        PreferenceScreen prefSet = getPreferenceScreen();

        mZramDisable = (CheckBoxPreference) findPreference(DeviceSettings.KEY_ZRAM_DISABLE);
        mZramDisable.setEnabled(ZramDisable.isSupported());
        mZramDisable.setOnPreferenceChangeListener(new ZramDisable());

        mZramMaxCompStream = (ListPreference) findPreference(DeviceSettings.KEY_ZRAM_COMP_STREAM);
        mZramMaxCompStream.setEnabled(ZramCompStream.isSupported());
        mZramMaxCompStream.setOnPreferenceChangeListener(new ZramCompStream());
        ZramCompStream.updateSummary(mZramMaxCompStream,
                Integer.parseInt(mZramMaxCompStream.getValue()));

        mZramCompAlgorithm = (ListPreference) findPreference(DeviceSettings.KEY_ZRAM_COMP_ALGORITHM);
        mZramCompAlgorithm.setEnabled(ZramCompAlgorithm.isSupported());
        mZramCompAlgorithm.setOnPreferenceChangeListener(new ZramCompAlgorithm());
        ZramCompAlgorithm.updateSummary(mZramCompAlgorithm, mZramCompAlgorithm.getValue());

        mZramDiskSize = (ListPreference) findPreference(DeviceSettings.KEY_ZRAM_DISK_SIZE);
        mZramDiskSize.setEnabled(ZramDiskSize.isSupported());
        mZramDiskSize.setOnPreferenceChangeListener(new ZramDiskSize());
        ZramDiskSize.updateSummary(mZramDiskSize, mZramDiskSize.getValue());
    }

    public static void restore(Context context) {
        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
    }
}
