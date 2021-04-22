package com.t.emlearn.ui;
//import com.t.easemob.utils.NetWorkStatus;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;
import android.content.BroadcastReceiver;
import androidx.fragment.app.FragmentActivity;
import com.t.emlearn.utils.HttpHelper;
import org.json.JSONException;
import org.json.JSONObject;

public class BaseActivity extends Activity {

    public interface CallBack{
        void finish(JSONObject result) throws JSONException;
    }

    private BroadcastReceiver receiver;

    public static String SERVER_URL = "";
    protected String EASEMOB_SERVER_URL = "";
    protected String EASEMOB_ORG = "";
    protected String EASEMOB_APP = "";
    protected String EASEMOB_APPKEY = "";
    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);

        //创建这个方法，开启广播
        registerBroadrecevicer();

        try {
            ApplicationInfo appInfo = getPackageManager().getApplicationInfo(getPackageName(),
                PackageManager.GET_META_DATA);
            SERVER_URL=appInfo.metaData.getString("SERVER_URL");
            EASEMOB_SERVER_URL=appInfo.metaData.getString("EASEMOB_SERVER_URL");
            EASEMOB_ORG=appInfo.metaData.getString("EASEMOB_ORGA");
            EASEMOB_ORG = EASEMOB_ORG.replace("ORG_","");
            EASEMOB_APP=appInfo.metaData.getString("EASEMOB_APP");
            EASEMOB_APPKEY=appInfo.metaData.getString("EASEMOB_APPKEY");
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

    }
    protected void EmHttpPost(String url,String data,CallBack call){
        new Thread(new Runnable() {
            @Override
            public void run() {
                String host = String.format("%s/%s/%s/%s",EASEMOB_SERVER_URL,EASEMOB_ORG,EASEMOB_APP,url);
                String retStr = HttpHelper.post(host,data);
                try {
                    JSONObject result = new JSONObject(retStr);
                    call.finish(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }
    protected void EmHttpGet(String url,CallBack call){
        new Thread(new Runnable() {
            @Override
            public void run() {
                String host = String.format("%s/%s/%s/%",EASEMOB_SERVER_URL,EASEMOB_ORG,EASEMOB_APP,url);
                String retStr = HttpHelper.get(host);
                try {
                    JSONObject result = new JSONObject(retStr);
                    call.finish(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }

    protected void httpPost(String url,String data,CallBack call){
        new Thread(new Runnable() {
            @Override
            public void run() {
                String retStr = HttpHelper.post(SERVER_URL+url,data);
                try {
                    JSONObject result = new JSONObject(retStr);
                    call.finish(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }

    protected void httpGet(String url,CallBack call){
        new Thread(new Runnable() {
            @Override
            public void run() {
                String retStr = HttpHelper.get(SERVER_URL+url);
                try {
                    JSONObject result = new JSONObject(retStr);
                    call.finish(result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    private void registerBroadrecevicer() {
        //获取广播对象
        receiver = new IntenterBoradCastReceiver();
        Log.i("","receiver:  "+receiver);
        //创建意图过滤器
        IntentFilter filter=new IntentFilter();
        //添加动作，监听网络
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        registerReceiver(receiver, filter);
    }
    //监听网络状态变化的广播接收器
    public class IntenterBoradCastReceiver extends BroadcastReceiver {

        private ConnectivityManager mConnectivityManager;
        private NetworkInfo netInfo;

        @Override
        public void onReceive(Context context, Intent intent) {
            // TODO Auto-generated method stub
            String action = intent.getAction();
            if (action.equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
                mConnectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
                netInfo = mConnectivityManager.getActiveNetworkInfo();
                if (netInfo != null && netInfo.isAvailable()) {

                    /////////////网络连接
                    String name = netInfo.getTypeName();

                    if (netInfo.getType() == ConnectivityManager.TYPE_WIFI) {
                        /////WiFi网络

                    } else if (netInfo.getType() == ConnectivityManager.TYPE_ETHERNET) {
                        /////有线网络

                    } else if (netInfo.getType() == ConnectivityManager.TYPE_MOBILE) {
                        /////////3g网络

                    }
                } else {
                    ////////网络断开
                    Toast.makeText(getApplicationContext(),"无网络",Toast.LENGTH_SHORT).show();
                }
            }

        }
    }

    /** 判断网络是否连接 */
    private boolean isConnectIsNomarl() {
        ConnectivityManager connectivityManager = (ConnectivityManager) this.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = connectivityManager.getActiveNetworkInfo();
        if (info != null && info.isAvailable()) {
            String intentName = info.getTypeName();
            //Toast.makeText(BaseActivity.this,"当前网络名称"+intentName,Toast.LENGTH_SHORT).show();
//            Log.i("通了没！", "当前网络名称：" + intentName);
            return true;
        } else {
//            Log.i("通了没！", "没有可用网络");
            //Toast.makeText(BaseActivity.this,"当前网络名称",Toast.LENGTH_SHORT).show();
            return false;
        }
    }
    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        //解除广播
        if(receiver!=null){
            unregisterReceiver(receiver);
            receiver=null;
        }

    }
}

