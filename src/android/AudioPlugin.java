package com.jernung.plugins.audio;

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

public class AudioPlugin extends CordovaPlugin {

    private static final String PLUGIN_NAME = "AudioPlugin";

    private SoundPool mSoundPool;

    private int mSoundId = 0;
    private float mSoundRate = 1.0f;
    private float mSoundVolume = 1.0f;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mSoundPool = new SoundPool.Builder().setMaxStreams(1).build();
        } else {
            mSoundPool = new SoundPool(1, AudioManager.STREAM_MUSIC, 0);
        }

        mSoundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            @Override
            public void onLoadComplete(SoundPool soundPool, int soundId, int status) {
                soundPool.play(soundId, mSoundVolume, mSoundVolume, 1, 0, mSoundRate);
            }
        });
    }

    @Override
    public boolean execute (String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if ("play".equals(action)) {
            unload();

            setRate(args.getDouble(2));

            setVolume(args.getDouble(1));

            play(args.getString(0));

            callbackContext.success();

            return true;
        }

        if ("release".equals(action)) {
            unload();

            callbackContext.success();

            return true;
        }

        return false;
    }

    private void play (final String path) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                File file = new File(Uri.parse(path).getPath());

                if (file.exists()) {
                    mSoundId = mSoundPool.load(file.getPath(), 1);
                } else {
                    try {
                        mSoundId = mSoundPool.load(cordova.getActivity().getAssets().openFd(path), 1);
                    } catch (IOException error) {
                        Log.d(PLUGIN_NAME, "Not found: " + error.getMessage());
                    }
                }

            }
        });
    }

    private void setRate (double rate) {
        mSoundRate = (float) rate;
    }

    private void setVolume (double volume) {
        mSoundVolume = (float) volume;
    }

    private void unload () {
        if (mSoundId > 0) {
            mSoundPool.stop(mSoundId);
            mSoundPool.unload(mSoundId);

            mSoundId = 0;
        }
    }
}
