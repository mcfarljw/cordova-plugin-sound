package com.jernung.plugins.sound;

import android.content.Context;
import android.media.AudioManager;
import android.media.SoundPool;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.File;
import java.io.IOException;

public class SoundPlugin extends CordovaPlugin {

    private static final String PLUGIN_NAME = "SoundPlugin";

    private SoundPool mSoundPool;

    private float mSoundRate = 1.0f;
    private float mSoundVolume = 1.0f;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        this.loadSoundPool();
    }

    @Override
    public boolean execute (String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if ("play".equals(action)) {
            play(args.getString(0));

            callbackContext.success();

            return true;
        }

        if ("release".equals(action)) {
            release();

            callbackContext.success();

            return true;
        }

        return false;
    }

    private void loadSoundPool () {
        if (mSoundPool != null) {
            mSoundPool.release();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mSoundPool = new SoundPool.Builder().setMaxStreams(4).build();
        } else {
            mSoundPool = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);
        }

        mSoundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            @Override
            public void onLoadComplete(SoundPool soundPool, int soundId, int status) {
                soundPool.play(soundId, mSoundVolume, mSoundVolume, 1, 0, mSoundRate);
            }
        });
    }

    private void play (final String path) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                String trimmedPath = path.replace("^/+", "");
                Context context = cordova.getActivity().getApplicationContext();
                File file = new File(Uri.parse(path).getPath());

                if (file.exists()) {
                    mSoundPool.load(file.getPath(), 1);
                } else {
                    try {
                        mSoundPool.load(context.getAssets().openFd("www/" + trimmedPath), 1);
                    } catch (IOException error) {
                        Log.d(PLUGIN_NAME, "not found: " + error.getMessage());
                    }
                }

            }
        });
    }

    private void release () {
        this.loadSoundPool();
    }
}
