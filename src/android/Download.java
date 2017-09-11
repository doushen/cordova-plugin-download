package cordova.plugins;

import android.util.Log;

import com.liulishuo.filedownloader.BaseDownloadTask;
import com.liulishuo.filedownloader.FileDownloadListener;
import com.liulishuo.filedownloader.FileDownloader;
import com.open.downloader.utils.StorageUtils;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class Download extends CordovaPlugin
{
  public static final String ACTIONS_START = "start";
  public static final String ACTIONS_PAUSE = "pause";
  public static final String ACTIONS_ABORT = "abort";
  public static final String ACTIONS_PROGRESS = "progress";
  private Map<String,Integer> downloadIdMap = new HashMap<String,Integer>();
  private Map<String,String> downloadTargetFilePathMap = new HashMap<String,String>();
  private CallbackContext _callbackContext;
  private final FileDownloadListener queueTarget = new FileDownloadListener() {
    @Override
    protected void pending(BaseDownloadTask task, int soFarBytes, int totalBytes) {

    }

    @Override
    protected void connected(BaseDownloadTask task, String etag, boolean isContinue, int soFarBytes, int totalBytes) {

    }

    @Override
    protected void progress(BaseDownloadTask task, int soFarBytes, int totalBytes) {
      long availableStorage = StorageUtils.getAvailableStorage();
      long totalStorage = StorageUtils.getTotalStorage();
      PluginResult progressResult = null;

      try {
        Log.i("Downloading", task.getSpeed()+"");
        progressResult = new PluginResult(PluginResult.Status.OK, new JSONObject("{data:{isCompletd:false,freeDisk:" + availableStorage + "," + "totalDisk:" + totalStorage + "," + "loaded:" + soFarBytes + "," + "total:" + totalBytes + "," + "speed:" + task.getSpeed()*1024 + "}}"));

        progressResult.setKeepCallback(true);
        Download.this._callbackContext.sendPluginResult(progressResult);
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }

    @Override
    protected void blockComplete(BaseDownloadTask task) {
    }

    @Override
    protected void retry(final BaseDownloadTask task, final Throwable ex, final int retryingTimes, final int soFarBytes) {
    }

    @Override
    protected void completed(BaseDownloadTask task) {
      PluginResult progressResult = null;
      try {
        progressResult = new PluginResult(PluginResult.Status.OK, new JSONObject("{data:{isCompletd:true}}"));
        Download.this._callbackContext.sendPluginResult(progressResult);
      } catch (JSONException e) {
        e.printStackTrace();
      }

    }

    @Override
    protected void paused(BaseDownloadTask task, int soFarBytes, int totalBytes) {
    }

    @Override
    protected void error(BaseDownloadTask task, Throwable e) {
      PluginResult progressResult = null;
      try {
        progressResult = new PluginResult(PluginResult.Status.OK, new JSONObject("{data:{error:\"" + task.getUrl() + "\"}}"));
        Download.this._callbackContext.sendPluginResult(progressResult);
      } catch (JSONException e1) {
        e1.printStackTrace();
      }
    }

    @Override
    protected void warn(BaseDownloadTask task) {
    }

    @Override
    protected void started(BaseDownloadTask task) {

    }
  };

  public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
    throws JSONException
  {

    return actionsRoute(action, args, callbackContext);
  }

  private boolean actionsRoute(String action, JSONArray args, CallbackContext callbackContext)
    throws JSONException
  {
    if (action.equals("start")) {
      String downloadUrl = args.getString(0);
      String targetPath = args.getString(1);
      JSONObject options = args.optJSONObject(2);
      start(downloadUrl, targetPath, options, args, callbackContext);
      return true;
    }
    if (action.equals("pause")) {
      String downloadUrl = args.getString(0);
      JSONObject options = args.optJSONObject(1);
      pause(downloadUrl, options, args, callbackContext);
      return true;
    }
    if (action.equals("abort")) {
      String downloadUrl = args.getString(0);
      JSONObject options = args.optJSONObject(1);
      abort(downloadUrl, options, args, callbackContext);
      return true;
    }
    if (action.equals("progress")) {
      String downloadUrl = args.getString(0);
      JSONObject options = args.optJSONObject(1);
      progress(downloadUrl, options, args, callbackContext);
      return true;
    }
    return false;
  }

  private void start(String downloadUrl, String targetPath, JSONObject options, JSONArray args, CallbackContext callbackContext)
    throws JSONException
  {
    Log.i("Download", "开始下载......");
    Log.i("Download", "downloadUrl:" + downloadUrl);
    Log.i("Download", "targetPath:" + targetPath);
    Log.i("Download", "options:" + options);

    PluginResult progressResult = null;
    try {
      progressResult = new PluginResult(PluginResult.Status.OK, new JSONObject("{success:\"start success\"}"));
      callbackContext.sendPluginResult(progressResult);
    } catch (JSONException e) {
      e.printStackTrace();
    }
    BaseDownloadTask task = FileDownloader.getImpl().create(downloadUrl)
            .setPath(targetPath)
            .setCallbackProgressTimes(3000)
            .setListener(this.queueTarget);
    downloadIdMap.put(task.getUrl(),task.getId());
    downloadTargetFilePathMap.put(task.getUrl(),task.getTargetFilePath());
    task.start();

  }

  private void pause(String downloadUrl, JSONObject options, JSONArray args, CallbackContext callbackContext)
    throws JSONException
  {
    Log.i("Download", "暂停下载......");
    Log.i("Download", "downloadUrl:" + downloadUrl);
    Log.i("Download", "options:" + options);

    PluginResult progressResult = null;
    try {
      progressResult = new PluginResult(PluginResult.Status.OK, new JSONObject("{success:\"pause success\"}"));
      callbackContext.sendPluginResult(progressResult);
    } catch (JSONException e) {
      e.printStackTrace();
    }

    FileDownloader.getImpl().pause(downloadIdMap.get(downloadUrl));
  }

  private void abort(String downloadUrl, JSONObject options, JSONArray args, CallbackContext callbackContext)
    throws JSONException
  {
    Log.i("Download", "终止下载......");
    Log.i("Download", "downloadUrl:" + downloadUrl);
    Log.i("Download", "options:" + options);

    PluginResult progressResult = null;
    try {
      progressResult = new PluginResult(PluginResult.Status.OK, new JSONObject("{success:\"abort success\"}"));
      callbackContext.sendPluginResult(progressResult);
    } catch (JSONException e) {
      e.printStackTrace();
    }

    FileDownloader.getImpl().clear(downloadIdMap.get(downloadUrl),downloadTargetFilePathMap.get(downloadUrl));
  }

  public void onDestroy() {
    //this.cordova.getActivity().unregisterReceiver(this._progressReceiver);
  }

  private void progress(String downloadUrl, JSONObject options, JSONArray args, CallbackContext callbackContext)
  {
    Log.i("Download", "下载进度......");
    Log.i("Download", "downloadUrl:" + downloadUrl);
    Log.i("Download", "options:" + options);

    this._callbackContext = callbackContext;
  }
}