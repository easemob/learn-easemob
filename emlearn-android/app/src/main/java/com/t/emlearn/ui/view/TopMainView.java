package com.t.emlearn.ui.view;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.telephony.TelephonyManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.fragment.app.FragmentActivity;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConference;
import com.hyphenate.chat.EMConferenceManager;
import com.hyphenate.util.EMLog;
import com.hyphenate.util.NetUtils;
import com.superrtc.mediamanager.ScreenCaptureManager;
import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.R;
import com.t.emlearn.ui.BaseMainActivity;
import com.t.emlearn.ui.LoginActivity;
import com.t.emlearn.ui.model.EaseCompat;
import com.t.emlearn.utils.PreferenceManager;
import com.t.emlearn.utils.StringUtils;

import java.io.File;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.TimeZone;

import static com.t.emlearn.utils.ease.ConferenceAttributeOption.WHITE_BOARD;
/**
 * 顶部头
 */
public class TopMainView extends RelativeLayout {
    private final String TAG = this.getClass().getSimpleName();

    private Context context;
    private TextView roomNameText;
    private TextView roomTimeText;
    private ImageView logout;
    private ImageView upload;
    private ImageView network;
    private TimeHandler timeHandler;
    private TelephonyManager telephonyManager;

    public TopMainView(Context context) {
        this(context, null);
    }

    public TopMainView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public TopMainView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        LayoutInflater.from(context).inflate(R.layout.view_top_main, this);

        init();
    }

    private void init() {
        timeHandler = new TimeHandler();
        timeHandler.startTime();

        roomNameText = (TextView)findViewById(R.id.mainTopRoomName);

        roomTimeText = (TextView)findViewById(R.id.mainTopRoomTime);

        network = (ImageView)findViewById(R.id.mainTopNetwork);

        upload = (ImageView)findViewById(R.id.mainTopUpload);
        upload.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                sendLogThroughMail();
//                Toast.makeText(TopMainView.this.context.getApplicationContext(), "12355", Toast.LENGTH_SHORT).show();
            }
        });
        logout = (ImageView)findViewById(R.id.mainTopClose);
        logout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                final AlertDialog.Builder normalDialog =
                        new AlertDialog.Builder(context);
                normalDialog.setMessage("确定离开房间");
                normalDialog.setPositiveButton("确定",
                    new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        exitConference();
                    }
                });
                normalDialog.setNegativeButton("关闭",
                    new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                    }
                });
                // 显示
                normalDialog.show();
            }
        });

    }
    void sendLogThroughMail() {
        String logPath = "";
        try {
            logPath = EMClient.getInstance().compressLogs();
        } catch (Exception e) {
            e.printStackTrace();
            ((Activity)context).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(context, "compress logs failed", Toast.LENGTH_LONG).show();
                }
            });
            return;
        }
        File f = new File(logPath);
        File storage = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        if (f.exists() && f.canRead()) {
            try {
                storage.mkdirs();
                File temp = File.createTempFile("videocall-android", ".log.tar", storage);
                if (!temp.canWrite()) {
                    return;
                }
                boolean result = f.renameTo(temp);
                if (result == false) {
                    return;
                }
                Intent intent = new Intent(Intent.ACTION_SEND_MULTIPLE);
                intent.setData(Uri.parse("mailto:1051824353@qq.com"));
                intent.putExtra(Intent.EXTRA_SUBJECT, "log");
                intent.putExtra(Intent.EXTRA_TEXT, "log in attachment: " + temp.getAbsolutePath());

                intent.setType("application/octet-stream");
                ArrayList<Uri> uris = new ArrayList<>();
                uris.add(EaseCompat.getUriForFile(getContext(), temp));
                intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM,uris);
                ((Activity)context).startActivity(intent);
            } catch (final Exception e) {
                e.printStackTrace();
                ((Activity)context).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(getContext(), e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                    }
                });
            }
        }
    }
    public void exitConference() {
        EmLearnHelper.getInstance().getConferenceSession().setSysToken("");
        EMClient.getInstance().conferenceManager().
        deleteConferenceAttribute(WHITE_BOARD, new EMValueCallBack<Void>() {
            @Override
            public void onSuccess(Void value) {
                EMLog.i(TAG, "deleteConferenceAttribute WHITE_BOARD success");

            }
            @Override
            public void onError(int error, String errorMsg) {
                EMLog.i(TAG, "deleteConferenceAttribute WHITE_BOARD failed: "
                        + error + ""  + errorMsg);
            }
        });
        BaseMainActivity.userMap.clear();
        ScreenCaptureManager.getInstance().stop();
        EMClient.getInstance().conferenceManager().stopMonitorSpeaker();
        timeHandler.stopTime();
        EMClient.getInstance().conferenceManager().exitConference(new EMValueCallBack() {
            @Override
            public void onSuccess(Object value) {
                ((Activity)context).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(context, "您已成功退出当前会议！", Toast.LENGTH_SHORT).show();
                    }
                });
                EMLog.i(TAG, "start  LoginActivity");
                ((Activity)context).finish();
                Intent intent = new Intent(TopMainView.this.context, LoginActivity.class);
                TopMainView.this.context.startActivity(intent);
            }

            @Override
            public void onError(int error, String errorMsg) {

            }
        });
    }

    public void SetRoomName(String roomName){
        roomNameText.setText(StringUtils.tolongNickName(roomName,14));
    }

    /**
     * 定时更新通话时间
     * @param time
     */
    private void updateConferenceTime(String time) {
        roomTimeText.setText(time);
        updateWifiState();
    }

    public void updateWifiState() {
        NetUtils.Types type = NetUtils.getNetworkTypes( this.context);
        if (type == NetUtils.Types.WIFI) {
            WifiManager mWifiManager = (WifiManager) this.context.getSystemService(Context.WIFI_SERVICE);
            WifiInfo mWifiInfo = mWifiManager.getConnectionInfo();
            int wifi = mWifiInfo.getRssi();//获取wifi信号强度
            if (wifi > -50 && wifi < 0) {//最强
                network.setBackgroundResource(R.drawable.networkinfo);
            } else if (wifi > -70 && wifi < -50) {//较强

                network.setBackgroundResource(R.drawable.networkinfo4);
            } else if (wifi > -80 && wifi < -70) {//较弱

                network.setBackgroundResource(R.drawable.networkinfo3);
            } else if (wifi > -100 && wifi < -80) {//微弱

                network.setBackgroundResource(R.drawable.networkinfo2);
            }
        } else if(type == NetUtils.Types.MOBILE){
            //是手机网络信号
            telephonyManager = (TelephonyManager) this.context
                    .getSystemService(Context.TELEPHONY_SERVICE);
            if(telephonyManager.getNetworkType() == TelephonyManager.NETWORK_TYPE_LTE){
                //4G网络 最佳范围   >-90dBm 越大越好

                network.setBackgroundResource(R.drawable.networkinfo);
            }else if(telephonyManager.getNetworkType() == TelephonyManager.NETWORK_TYPE_HSDPA ||
                    telephonyManager.getNetworkType() == TelephonyManager.NETWORK_TYPE_HSPA ||
                    telephonyManager.getNetworkType() == TelephonyManager.NETWORK_TYPE_HSUPA ||
                    telephonyManager.getNetworkType() == TelephonyManager.NETWORK_TYPE_UMTS){
                //3G网络最佳范围  >-90dBm  越大越好  ps:中国移动3G获取不

                network.setBackgroundResource(R.drawable.networkinfo4);
            }else{
                //2G网络最佳范围>-90dBm 越大越好

                network.setBackgroundResource(R.drawable.networkinfo3);
            }
        }else{
            //无连接
            network.setBackgroundResource(R.drawable.networkinfo0);
        }
    }

    private class TimeHandler extends Handler {
        private final int MSG_TIMER = 0;
        private DateFormat dateFormat = null;
        private int timePassed = 0;

        public TimeHandler() {
            dateFormat = new SimpleDateFormat("HH:mm:ss");
            dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        }

        public void startTime() {
            sendEmptyMessageDelayed(MSG_TIMER, 1000);
        }

        public void stopTime() {
            removeMessages(MSG_TIMER);
        }

        @Override
        public void handleMessage(Message msg) {
            if (msg.what == MSG_TIMER) {
                // TODO: update calling time.
                timePassed++;
                String time = dateFormat.format(timePassed * 1000);
                updateConferenceTime(time);
                sendEmptyMessageDelayed(MSG_TIMER, 1000);
                return;
            }
            super.handleMessage(msg);
        }
    }
}
