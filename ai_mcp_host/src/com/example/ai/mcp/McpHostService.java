package com.example.ai.mcp;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;

/**
 * A stub foreground service that represents an MCP host on
 * Android Automotive.  Real implementations should register tool
 * providers and expose a local IPC interface (for example, via
 * Binder or a Unix domain socket) that your on‑device LLM can
 * call into.  For now this service simply logs its lifecycle.
 */
public class McpHostService extends Service {

    private static final String TAG = "McpHostService";

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "AI MCP Host service created");
        // TODO: Initialise your tool registry and start a socket/Binder server here.
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "AI MCP Host service started");
        // Returning START_STICKY requests the system to recreate the
        // service after it has been killed (for example, due to memory
        // pressure).
        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        // This stub service doesn't support binding yet.  Replace this
        // with an implementation that returns a Binder interface.
        return null;
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "AI MCP Host service destroyed");
        super.onDestroy();
    }
}
