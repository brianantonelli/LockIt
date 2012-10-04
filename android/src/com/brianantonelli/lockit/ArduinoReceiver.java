package com.brianantonelli.lockit;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import at.abraxas.amarino.AmarinoIntent;

public class ArduinoReceiver extends BroadcastReceiver{
	private static final String TAG = "LockItArduinoReceiver";

	@Override
	public void onReceive(Context context, Intent intent) {
		Log.d(TAG, "*-rx-*");
    	String data = null;
    	final String address = intent.getStringExtra(AmarinoIntent.EXTRA_DEVICE_ADDRESS);
    	
    	
    	final int dataType = intent.getIntExtra(AmarinoIntent.EXTRA_DATA_TYPE, -1);
		
    	Log.d(TAG, "Received Event From: " + address + " with data type = " + dataType);
    	
    	if(dataType == AmarinoIntent.STRING_EXTRA){
    		data = intent.getStringExtra(AmarinoIntent.EXTRA_DATA);
    		Log.d(TAG, data);
    	}		
	}

}
