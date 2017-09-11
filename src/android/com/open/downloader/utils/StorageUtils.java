package com.open.downloader.utils;

import android.os.Environment;
import android.os.StatFs;
import android.util.Log;
import java.io.File;
import java.io.IOException;

public class StorageUtils {
	public static boolean isSdCardWrittenable() {
		if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
			return true;
		}
		return false;
	}

	public static long getAvailableStorage() {
		String storageDirectory = null;
		storageDirectory = Environment.getExternalStorageDirectory().toString();

		try {
			StatFs stat = new StatFs(storageDirectory);
			long avaliableSize = ((long) stat.getAvailableBlocks() * (long) stat.getBlockSize());
			return avaliableSize;
		} catch (RuntimeException ex) {
			return 0;
		}
	}
	
    static public long getTotalStorage() {
        File path = Environment.getDataDirectory();//Gets the Android data directory
        StatFs stat = new StatFs(path.getPath());
        long blockSize = stat.getBlockSize();      //每个block 占字节数
        long totalBlocks = stat.getBlockCount();   //block总数
        return totalBlocks * blockSize;
    }

	public static boolean isSDCardPresent() {
		return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
	}

	public static void mkdir(String dir) throws IOException {
		File root = new File(dir);
		if (!root.exists() || !root.isDirectory())
			root.mkdir();
	}

	public static boolean delete(File path) {
		boolean result = true;
		if (path.exists()) {
			if (path.isDirectory()) {
				for (File child : path.listFiles()) {
					result &= delete(child);
				}
				result &= path.delete(); // Delete empty directory.
			}
			if (path.isFile()) {
				result &= path.delete();
			}
			if (!result) {
				Log.e(null, "Delete failed;");
			}
			return result;
		} else {
			Log.e(null, "File does not exist.");
			return false;
		}
	}
}
