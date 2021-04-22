package com.t.emlearn.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.animation.AlphaAnimation;
import com.hyphenate.chat.EMClient;
import com.t.emlearn.R;

/**
 * 启动页面
 */
public class SplashActivity extends BaseActivity {

    private static final int sleepTime = 2000;

    protected void onCreate(Bundle arg0) {
		setContentView(R.layout.activity_splash);
		super.onCreate(arg0);

		AlphaAnimation animation = new AlphaAnimation(0.3f, 1.0f);
		animation.setDuration(1500);
	}



	@Override
	protected void onStart() {
		super.onStart();
		new Thread(new Runnable() {
			public void run() {
//				if (EmLearnHelper.getInstance().isLoggedIn()) {
//					// auto login mode, make sure all group and conversation is loaed before enter the main screen
//					long start = System.currentTimeMillis();
//					EMClient.getInstance().chatManager().loadAllConversations();
//					EMClient.getInstance().groupManager().loadAllGroups();
//					long costTime = System.currentTimeMillis() - start;
//					//wait
//					if (sleepTime - costTime > 0) {
//						try {
//							Thread.sleep(sleepTime - costTime);
//						} catch (InterruptedException e) {
//							e.printStackTrace();
//						}
//					}
////					String topActivityName = EasyUtils.getTopActivityName(EMClient.getInstance().getContext());
////					if (topActivityName != null && (topActivityName.equals(VideoCallActivity.class.getName()) || topActivityName.equals(VoiceCallActivity.class.getName()) || topActivityName.equals(ConferenceActivity.class.getName()))) {
////						// nop
////						// avoid main screen overlap Calling Activity
////					} else {
//						//enter main screen
//						startActivity(new Intent(SplashActivity.this, OneMainActivity.class));
////					}
//					finish();
//				}else {
//					try {
//						Thread.sleep(sleepTime);
//					} catch (InterruptedException e) {
//					}
//					startActivity(new Intent(SplashActivity.this, LoginActivity.class));
//					finish();
//				}
				startActivity(new Intent(SplashActivity.this, LoginActivity.class));
				finish();
			}
		}).start();

	}

	/**
	 * get sdk version
	 */
	private String getVersion() {
	    return EMClient.getInstance().VERSION;
	}
}
