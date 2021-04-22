package com.t.emlearn.utils;

import android.os.Message;
import android.util.Log;


import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.ui.BaseActivity;

import org.json.JSONException;
import org.json.JSONObject;

import static com.t.emlearn.ui.BaseActivity.SERVER_URL;

public class ServerHttpHelper {
    private static final String TAG = ServerHttpHelper.class.getSimpleName();

    public static void SetWhiteStatus(String confrId,int isOpen) throws JSONException {
        JSONObject jo = new JSONObject();
//        jo.put("UserNames",new JsonArray());
        jo.put("confrId",confrId);
        jo.put("isOpen",isOpen);
        httpPost("/Conference/SetWhiteStatus" , jo.toString(), new BaseActivity.CallBack() {
            @Override
            public void finish(JSONObject result) throws JSONException {
                String code = (String) result.get("code");
                if (code.equals("1")) {
                    // 更新列表
                    return;
                }
            }
        });
    }
    public interface GetNickNameCallBack{
        void finish(String userName,String nickName) throws JSONException;
    }
    public static void GetNickName(String confrKey,String userName,GetNickNameCallBack callBack) throws JSONException {
        String[] userNames = userName.split("_");
        String retUserName;
        if (userNames.length > 1){
            retUserName = userNames[1];
        }else{
            retUserName = userNames[0];
        }

        httpGet("/User/GetNickName?confrKey="+confrKey+"&userName="+retUserName ,  new BaseActivity.CallBack() {
            @Override
            public void finish(JSONObject result) throws JSONException {
                String code = (String) result.get("code");
                if (code.equals("1")) {
                    String data = (String) result.get("data");
                    callBack.finish(retUserName,data);
                    return;
                }else{
                    String mess = (String)result.get("message");
                    Log.e(TAG, mess);
                }
            }
        });
    }

    public static void OperRole(String userName,int role) throws JSONException {
        String[] userNames = userName.split("_");
        String retUserName;
        if (userNames.length > 1){
            retUserName = userNames[1];
        }else{
            retUserName = userNames[0];
        }
        JSONObject jo = new JSONObject();
        jo.put("confrId", EmLearnHelper.getInstance().getConferenceSession().getConfrId());
        jo.put("userName",retUserName);
        jo.put("role",role);
        httpPost("/Conference/Role" ,jo.toString(),  new BaseActivity.CallBack() {
            @Override
            public void finish(JSONObject result) throws JSONException {
                String code = (String) result.get("code");
                if (code.equals("1")) {
                    String data = (String) result.get("data");
                    Log.i(TAG,"change member pass");
                    return;
                }else{
                    String mess = (String)result.get("message");
                    Log.e(TAG, mess);
                }
            }
        });
    }

    protected static void httpPost(String url, String data, BaseActivity.CallBack call){
        httpPost(url,data,"",call);
    }
    protected static void httpPost(String url, String data, String contentType, BaseActivity.CallBack call){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String retStr = HttpHelper.post(SERVER_URL+url,data,contentType);
                    JSONObject result = new JSONObject(retStr);
                    call.finish(result);
                } catch (Exception e) {
                    e.printStackTrace();
                    JSONObject result = new JSONObject();
                    try {
                        result.put("code", "-1");
                        result.put( "message", "连接失败");
                        call.finish(result);
                    } catch (JSONException jsonException) {
                        jsonException.printStackTrace();
                    }
                }

            }
        }).start();
    }

    protected static void httpGet(String url, BaseActivity.CallBack call){
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
}
