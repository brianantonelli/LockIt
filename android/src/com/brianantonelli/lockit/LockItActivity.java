package com.brianantonelli.lockit;

import android.app.Activity;
import android.content.Context;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import at.abraxas.amarino.Amarino;
import at.abraxas.amarino.AmarinoIntent;

public class LockItActivity extends Activity {
	// BT's MAC on Arduino
	private static final String DEVICE_ADDRESS = "00:06:66:08:E7:60";
	private static final String TAG = "LockIt";
	
	private Button lockButton;
	private Button unlockButton;
	private ArduinoReceiver receiver;
	
    public static final char FLAG_LOCK = 'l';
    public static final char FLAG_UNLOCK = 'u';
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        lockButton = (Button) findViewById(R.id.LockButton);
        unlockButton = (Button) findViewById(R.id.UnlockButton);
        
        final Context that = this;
        lockButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Amarino.sendDataToArduino(that, DEVICE_ADDRESS, FLAG_LOCK, 0);
			}
		});
        
        unlockButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Amarino.sendDataToArduino(that, DEVICE_ADDRESS, FLAG_UNLOCK, 0);
			}
		});
    }

    @Override
    public void onStart(){
    	super.onStart();
    	
    	// Register our receiver so we can receive broadcasts
    	Log.d(TAG, "Registering receiver");
    	registerReceiver(receiver, new IntentFilter(AmarinoIntent.ACTION_RECEIVED));
    	registerReceiver(receiver, new IntentFilter(AmarinoIntent.ACTION_CONNECTED));
    	
    	// Connect to the device
    	Log.d(TAG, "Connecting to Arduino");
    	Amarino.connect(this, DEVICE_ADDRESS);
    }
        
    @Override
    public void onStop(){
    	super.onStop();
    	
    	// Always disconnect the Arduino when exiting the app
    	Log.d(TAG, "Disconnecting from Arduino");
    	Amarino.disconnect(this, DEVICE_ADDRESS);
    	
//    	// And un-register
    	Log.d(TAG, "Unregistering receiver");
    	unregisterReceiver(receiver);
    }
}