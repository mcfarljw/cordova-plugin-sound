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
import java.util.HashMap;

public class SoundPlugin extends CordovaPlugin {

    private static final String PLUGIN_NAME = "SoundPlugin";

    private SoundPool mSoundPool;

    private HashMap<String, HashMap<String, Integer>> audioTracks = new HashMap<>();
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
            play(args.getString(0), args.getString(1));

            callbackContext.success();

            return true;
        }

        if ("stop".equals(action)) {
            stop(args.getString(0));

            callbackContext.success();

            return true;
        }

        if ("stopAll".equals(action)) {
            stopAll();

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

        SoundPool.OnLoadCompleteListener listener = (SoundPool soundPool, int soundId, int status) -> {
            soundPool.play(soundId, mSoundVolume, mSoundVolume, 1, 0, mSoundRate);
        };

        mSoundPool.setOnLoadCompleteListener(listener);
    }

    private void play (final String path, final String track) {
        final Context context = cordova.getActivity().getApplicationContext();
        final String trimmedPath = path.replaceAll("^/+", "");
        final String absolutePath = context.getFilesDir().getAbsolutePath() + "/files/" + trimmedPath;
        final String parsedPath = Uri.parse(absolutePath).getPath();

        if (!audioTracks.containsKey(track)) {
            audioTracks.put(track, new HashMap<>());
        }

        Runnable thread = () -> {
            final File file = new File(parsedPath);
            int soundId;

            if (file.exists()) {
                soundId = mSoundPool.load(file.getPath(), 1);
                audioTracks.get(track).put(trimmedPath, soundId);
            } else {
                try {
                    soundId = mSoundPool.load(context.getAssets().openFd("www/" + trimmedPath), 1);
                    audioTracks.get(track).put(trimmedPath, soundId);
                } catch (IOException error) {
                    Log.d(PLUGIN_NAME, "not found: " + error.getMessage());
                }
            }
        };

        if (audioTracks.get(track).containsKey(trimmedPath)) {
            mSoundPool.play(audioTracks.get(track).get(trimmedPath), mSoundVolume, mSoundVolume, 1, 0, mSoundRate);
        } else {
            cordova.getThreadPool().execute(thread);
        }
    }

    private void stop (final String track) {
        if (!audioTracks.containsKey(track)) {
            return;
        }

        try {
            for (HashMap.Entry<String, Integer> entry : audioTracks.get(track).entrySet()) {
                mSoundPool.unload(entry.getValue());
            }

            audioTracks.remove(track);
        } catch (NullPointerException error) {
            Log.i(PLUGIN_NAME, "Unable to stop audio track!");
        }

    }

    private void stopAll () {
        try {
            for (HashMap.Entry<String, HashMap<String, Integer>> entry : audioTracks.entrySet()) {
                stop(entry.getKey());
            }
        } catch (NullPointerException error) {
            Log.i(PLUGIN_NAME, "Unable to stop audio tracks!");
        }
    }
}
