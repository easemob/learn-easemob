package com.t.emlearn;

import android.content.Context;
import android.os.Process;
import android.util.Log;

import androidx.multidex.MultiDex;
import androidx.multidex.MultiDexApplication;
import com.hyphenate.util.EMLog;
import com.tencent.smtt.sdk.QbSdk;

public class EmLearnApplication extends MultiDexApplication implements Thread.UncaughtExceptionHandler{
	private static final String TAG = "application";
	public static Context applicationContext;
	private static EmLearnApplication instance;

	@Override
	public void onCreate() {
		MultiDex.install(this);
		super.onCreate();
        applicationContext = this;
        instance = this;


		//init demo helper
        EmLearnHelper.getInstance().init(applicationContext);

        addErrorListener();

		//搜集本地tbs内核信息并上报服务器，服务器返回结果决定使用哪个内核。
		QbSdk.PreInitCallback cb = new QbSdk.PreInitCallback() {
			@Override
			public void onViewInitFinished(boolean arg0) {
				// TODO Auto-generated method stub
				//x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
				Log.d("app", " onViewInitFinished is " + arg0);
			}

			@Override
			public void onCoreInitFinished() {
				// TODO Auto-generated method stub
			}
		};
		//x5内核初始化接口
		QbSdk.initX5Environment(getApplicationContext(),  cb);
	}

	public static EmLearnApplication getInstance() {
		return instance;
	}

	private void addErrorListener() {
		Thread.setDefaultUncaughtExceptionHandler(this);
	}

	@Override
	protected void attachBaseContext(Context base) {
		super.attachBaseContext(base);
		MultiDex.install(this);
	}

	@Override
	public void uncaughtException(Thread t, Throwable e) {
		e.printStackTrace();
		EMLog.e("uncaughtException : ", e.getMessage());
		System.exit(1);
		Process.killProcess(Process.myPid());
	}
}

