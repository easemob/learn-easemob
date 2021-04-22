package com.t.emlearn.utils;//package com.t.easemob.utils;
//import android.content.BroadcastReceiver;
//import android.content.Context;
//import android.content.Intent;
////由于需要使用广播进行操作，这个类需要继承BroadcastReceiver并重写onReceive方法，
//// 需要导入三个包：android.content.BroadcastReceiver、android.content.Contextandroid.content.Intent
//
//import android.net.ConnectivityManager;
//import android.net.Network;
//import android.net.NetworkInfo;
//import android.os.Build;
//import android.widget.Toast;
//
//public class NetWorkStatus extends BroadcastReceiver {
//
//    @Override
//    public void onReceive(Context context, Intent intent) {
//        ConnectivityManager connMgr = (ConnectivityManager) context.getSystemService((Context.CONNECTIVITY_SERVICE));
//        if(android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP){
//            //创建一个Network数组，调用connMgr.getAllNetworks()方法把当前网络信息赋值给它
//            Network[] networks = connMgr.getAllNetworks();
//            //由于保存网络信息的数据长度无法确定，所以可用StringBuilder来创建一个字符串，再通过循环遍历network数组的方式得到每一个网络连接状态的信息，再用append方法增长字符串的长度
//            StringBuilder sb = new StringBuilder();
//            for(int i=0;i<networks.length;i++){
//                NetworkInfo networkInfo = connMgr.getNetworkInfo(networks[i]);
//                sb.append(networkInfo.getTypeName() + " -> " + networkInfo.isConnected());
//            }
//            //最后用一个toast来输出网络连接信息，注意StringBuilder类型不能直接输出，需要调用.toString()方法转化为字符串再输出
//            Toast.makeText(context,sb.toString(),Toast.LENGTH_SHORT).show();
//        }
//    }
//}

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;

import com.t.emlearn.R;

import androidx.fragment.app.FragmentActivity;

/**
 *
 * @author cj 判断网络工具类
 *
 */
class NetUtil {
    /**
     * 没有连接网络
     */
    private static final int NETWORK_NONE = -1;
    /**
     * 移动网络
     */
    private static final int NETWORK_MOBILE = 0;
    /**
     * 无线网络
     */
    private static final int NETWORK_WIFI = 1;

    public static int getNetWorkState(Context context) {
        // 得到连接管理器对象
        ConnectivityManager connectivityManager = (ConnectivityManager) context
                .getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetworkInfo = connectivityManager
                .getActiveNetworkInfo();
        if (activeNetworkInfo != null && activeNetworkInfo.isConnected()) {

            if (activeNetworkInfo.getType() == (ConnectivityManager.TYPE_WIFI)) {
                return NETWORK_WIFI;
            } else if (activeNetworkInfo.getType() == (ConnectivityManager.TYPE_MOBILE)) {
                return NETWORK_MOBILE;
            }
        } else {
            return NETWORK_NONE;
        }
        return NETWORK_NONE;
    }
}



/**
 * 自定义检查手机网络状态是否切换的广播接受器
 *
 * @author cj
 *
 */
class NetBroadcastReceiver extends BroadcastReceiver {

    public NetEvevt evevt = BaseActivity.evevt;

    @Override
    public void onReceive(Context context, Intent intent) {
        // TODO Auto-generated method stub
        // 如果相等的话就说明网络状态发生了变化
        if (intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
            int netWorkState = NetUtil.getNetWorkState(context);
            // 接口回调传过去状态的类型
            evevt.onNetChange(netWorkState);
        }
    }

    // 自定义接口
    public interface NetEvevt {
        public void onNetChange(int netMobile);
    }
}




abstract class BaseActivity extends FragmentActivity implements NetBroadcastReceiver.NetEvevt {

    public static NetBroadcastReceiver.NetEvevt evevt;
    /**
     * 网络类型
     */
    private int netMobile;

    @Override
    protected void onCreate(Bundle arg0) {
        // TODO Auto-generated method stub
        super.onCreate(arg0);
        evevt = (NetBroadcastReceiver.NetEvevt) this;
        inspectNet();
    }


    /**
     * 初始化时判断有没有网络
     */

    public boolean inspectNet() {
        this.netMobile = NetUtil.getNetWorkState(BaseActivity.this);
        return isNetConnect();

        // if (netMobile == 1) {
        // System.out.println("inspectNet：连接wifi");
        // } else if (netMobile == 0) {
        // System.out.println("inspectNet:连接移动数据");
        // } else if (netMobile == -1) {
        // System.out.println("inspectNet:当前没有网络");
        //
        // }
    }

    /**
     * 网络变化之后的类型
     */
    @Override
    public void onNetChange(int netMobile) {
        // TODO Auto-generated method stub
        this.netMobile = netMobile;
        isNetConnect();

    }

    /**
     * 判断有无网络 。
     *
     * @return true 有网, false 没有网络.
     */
    public boolean isNetConnect() {
        if (netMobile == 1) {
            return true;
        } else if (netMobile == 0) {
            return true;
        } else if (netMobile == -1) {
            return false;

        }
        return false;
    }

}


class MainActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_one_main);

    }

    @Override
    public void onNetChange(int netMobile) {
        // TODO Auto-generated method stub
        //在这个判断，根据需要做处理
    }




}
