package com.jernung.plugins.audio;

import android.content.res.AssetFileDescriptor;
import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.SystemClock;
import android.util.Log;

import java.io.IOException;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

public class AudioPlugin extends CordovaPlugin {

    private static final String PLUGIN_NAME = "AudioPlugin";

    private String mMediaPath = "";
    private MediaPlayer mMediaPlayer;

    @Override
    public boolean execute (String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if ("play".equals(action)) {
            playAudio(args.getString(0), args.getInt(1), args.getDouble(2));
            callbackContext.success();
            return true;
        }

        if ("release".equals(action)) {
            releaseAudio();
            callbackContext.success();
            return true;
        }

        return false;
    }

    private void playAudio (final String path, final Integer start, final Double duration) {
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                try {
                    // only prepare audio if needed
                    if (!path.equals(mMediaPath)) {
                        AssetFileDescriptor dataDescriptor = cordova.getActivity().getAssets().openFd(path);

                        // attempt to release old audio
                        releaseAudio();

                        // prepare new audio to be played
                        Log.d(PLUGIN_NAME, "Preparing: " + path);
                        mMediaPlayer = new MediaPlayer();
                        mMediaPlayer.setDataSource(dataDescriptor.getFileDescriptor(), dataDescriptor.getStartOffset(), dataDescriptor.getLength());
                        mMediaPlayer.prepare();
                        mMediaPath = path;
                    }

                    Log.d(PLUGIN_NAME, "Path: " + path + " Start: " + start + " Duration: " + duration);

                    // move to start position and play audio
                    mMediaPlayer.seekTo(start);
                    mMediaPlayer.start();

                    // stop audio after duration if needed
                    if (duration > 0) {
                        SystemClock.sleep(Double.valueOf(duration).longValue());
                        mMediaPlayer.pause();
                    }
                } catch (IOException error) {
                    Log.d(PLUGIN_NAME, error.getMessage());
                }
            }
        });
    }

    private void releaseAudio () {
        if (mMediaPlayer != null) {
            mMediaPlayer.release();
            mMediaPlayer = null;
            mMediaPath = "";
        } else {
            Log.d(PLUGIN_NAME, "No media to release.");
        }
    }

}
