package com.mymobilerobots.rk1data.app;

import android.os.Bundle;
import android.preference.PreferenceActivity;

/**
 * Created by evangelosgeorgiou on 09/03/2014.
 */
public class UserSettingsActivity extends PreferenceActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        addPreferencesFromResource(R.xml.settings);

    }
}
