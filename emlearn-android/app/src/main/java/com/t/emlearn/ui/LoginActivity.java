package com.t.emlearn.ui;

//1.引入所需组件

import android.Manifest;
import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.*;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.*;
import com.hyphenate.util.EMLog;
import com.t.emlearn.Constant;
import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.R;
import com.t.emlearn.runtimepermissions.PermissionsManager;
import com.t.emlearn.runtimepermissions.PermissionsResultAction;

import com.t.emlearn.ui.view.LoadingDialog;
import com.t.emlearn.utils.ease.ConferenceSession;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * 登录页面
 */
public class LoginActivity extends BaseActivity {
    private final String TAG = this.getClass().getSimpleName();
    //2.声明组件类型
    private EditText roomName;
    private EditText roomPassword;
    private EditText nickName;
    private Button login;
    private Spinner confrTypeSpinner;
    private ArrayAdapter<String> confrTypeAdapter;
    private List<String> confrTypeList = new ArrayList<String>();
    private String confrType = "";
    private String roleType = Constant.ROLE_TEACHER;
    private RadioGroup roleRadio;
    private ConferenceSession conferenceSession;
    private EMConferenceManager.EMConferenceRole conferenceRole;

    private boolean autoLogin = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_login);
        roomName = (EditText) findViewById(R.id.roomName);
        roomPassword = (EditText) findViewById(R.id.roomPassword);
        nickName = (EditText) findViewById(R.id.nickName);
        login = (Button) findViewById(R.id.login);
        login.setOnClickListener(loginButtonListener);


        confrTypeList.add("1v1");
        confrTypeList.add("小班课");
        confrTypeSpinner = (Spinner) findViewById(R.id.confrTypeSpinner);
        confrTypeAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, confrTypeList);
        confrTypeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        confrTypeSpinner.setAdapter(confrTypeAdapter);
        confrTypeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
             @Override
             public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                 if(confrTypeList.get(position).equals("1v1")){
                     confrType = Constant.CLASS_TYPE_1V1;
                 }else if(confrTypeList.get(position).equals("小班课")){
                     confrType = Constant.CLASS_TYPE_SMALL;
                 }
                 EMLog.i(TAG,confrType);
             }
             @Override
             public void onNothingSelected(AdapterView<?> parent) {
             }
         });

        roleRadio= (RadioGroup) findViewById(R.id.roleGroup);
        RadioButton teacherRadio = (RadioButton) findViewById(R.id.teacherRadio);
        RadioButton studentRadio = (RadioButton) findViewById(R.id.studentRadio);
        roleRadio.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                if (checkedId == teacherRadio.getId()) {
                    conferenceRole = EMConferenceManager.EMConferenceRole.Talker;
                    roleType = Constant.ROLE_TEACHER;

                } else if(checkedId == studentRadio.getId()){
                    conferenceRole = EMConferenceManager.EMConferenceRole.Audience;
                    roleType = Constant.ROLE_STUDENT;
                }
            }
        });

        conferenceSession = EmLearnHelper.getInstance().getConferenceSession();


        requestPermissions();
        checkCamera();
        checkStorage();
        checkReadLog();
    }

    @TargetApi(23)
    private void requestPermissions() {
		PermissionsManager.getInstance().requestAllManifestPermissionsIfNecessary(this, new PermissionsResultAction() {
			@Override
			public void onGranted() {
//				Toast.makeText(MainActivity.this, "All permissions have been granted", Toast.LENGTH_SHORT).show();
			}

			@Override
			public void onDenied(String permission) {
				//Toast.makeText(MainActivity.this, "Permission " + permission + " has been denied", Toast.LENGTH_SHORT).show();
			}
		});
	}
    private void checkCamera(){
        if (ContextCompat.checkSelfPermission(LoginActivity.this,
                Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            EMLog.e("--------->", "camera 没有权限");
            //申请授权
            ActivityCompat.requestPermissions(LoginActivity.this, new String[]{Manifest.permission.CAMERA}, 1);

        } else {

            EMLog.e("--------->", "camera 已经被授权");
        }
    }
    private void checkStorage(){
        if (ContextCompat.checkSelfPermission(LoginActivity.this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED||
            ContextCompat.checkSelfPermission(LoginActivity.this,
                    Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            EMLog.e("--------->", "storage 没有权限");
            //申请授权
            ActivityCompat.requestPermissions(LoginActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
            ActivityCompat.requestPermissions(LoginActivity.this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
        } else {

            EMLog.e("--------->", "storage 已经被授权");
        }
    }

    private void checkReadLog(){
        if (ContextCompat.checkSelfPermission(LoginActivity.this,
                Manifest.permission.READ_LOGS) != PackageManager.PERMISSION_GRANTED) {
            EMLog.e("--------->", "logs 没有权限");
            //申请授权
            ActivityCompat.requestPermissions(LoginActivity.this, new String[]{Manifest.permission.READ_LOGS}, 1);
        } else {

            EMLog.e("--------->", "logs 已经被授权");
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode,permissions,grantResults);
        PermissionsManager.getInstance().notifyPermissionsChange(permissions, grantResults);
    }

    Button.OnClickListener loginButtonListener = new Button.OnClickListener() {
        @Override
        public void onClick(View v) {

            String roomNameVal = roomName.getText().toString();
            String roomPasswordVal = roomPassword.getText().toString();
            String nickNameVal = nickName.getText().toString();

            if (roomNameVal.length() == 0) {
                Toast.makeText(LoginActivity.this, "房间名", Toast.LENGTH_SHORT).show();
                return;
            } else if (nickNameVal.length() == 0) {
                Toast.makeText(LoginActivity.this, "用户昵称", Toast.LENGTH_SHORT).show();
                return;
            } else {
                Log.i("", "房间名" + roomNameVal);
                Log.i("", "用户昵称" + nickNameVal);
            }
            ConnectivityManager connectionManager = (ConnectivityManager) LoginActivity.this.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo networkInfo = connectionManager.getActiveNetworkInfo();
            if (networkInfo != null && networkInfo.isAvailable()) {

            }else{
                Toast.makeText(LoginActivity.this, "网络不可用", Toast.LENGTH_SHORT).show();
                return;
            }
            LoadingDialog.show(LoginActivity.this,"加载中");
            httpPost("/Conference/Entry",
                    "name=" + roomNameVal + "&username=" + nickNameVal + "&password=" + roomPasswordVal+"&role="+roleType+"&confrType="+confrType, new CallBack() {
                @Override
                public void finish(JSONObject result) throws JSONException {
                    String code = (String)result.get("code");
                    if(!code.equals( "1")){
                        LoadingDialog.close();
                        String message = (String)result.get("message");
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Toast.makeText(LoginActivity.this, message, Toast.LENGTH_SHORT).show();
                            }
                        });
                        return;
                    }
                    JSONObject data = (JSONObject)result.get("data");
                    String accessToken = data.get("EmToken").toString();
                    String username = data.get("EmName").toString();
                    String userId = data.get("EmUserId").toString();
                    String confrId = data.get("EmconfrId").toString();
                    String chatId = data.get("EmChatId").toString();
                    String sysToken = data.get("SysToken").toString();
                    conferenceSession.setChatId(chatId);
                    conferenceSession.setUserId(userId);
                    conferenceSession.setConfrPwd(roomPasswordVal);
                    conferenceSession.setRoomName(roomNameVal);
                    conferenceSession.setConfrId(confrId);
                    conferenceSession.setAccessToken(accessToken);
                    conferenceSession.setRoleType(roleType);
                    conferenceSession.setSysToken(sysToken);

                    if(EmLearnHelper.getInstance().isLoggedIn()){
                        EmLearnHelper.getInstance().logout(true,new EMCallBack(){

                            @Override
                            public void onSuccess() {
                                EMClient.getInstance().login(username, "1", new EMCallBack() {
                                    @Override
                                    public void onSuccess() {
                                        Log.d(TAG, "login: onSuccess");

                                        joinRoom(accessToken,username,nickNameVal);
                                    }

                                    @Override
                                    public void onProgress(int progress, String status) {
                                        Log.d(TAG, "login: onProgress");
                                        LoadingDialog.close();
                                        runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
                                            }
                                        });
                                    }

                                    @Override
                                    public void onError(final int code, final String message) {
                                        Log.d(TAG, "login: onError: " + code+" mess:"+message);
                                        LoadingDialog.close();
                                        runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
                                            }
                                        });
                                    }
                                });
                            }

                            @Override
                            public void onError(int code, String error) {
                                EMClient.getInstance().login(username, "1", new EMCallBack() {
                                    @Override
                                    public void onSuccess() {
                                        Log.d(TAG, "login: onSuccess");

                                        joinRoom(accessToken,username,nickNameVal);
                                    }

                                    @Override
                                    public void onProgress(int progress, String status) {
                                        Log.d(TAG, "login: onProgress");
                                        LoadingDialog.close();
                                        runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
                                            }
                                        });
                                    }

                                    @Override
                                    public void onError(final int code, final String message) {
                                        Log.d(TAG, "login: onError: " + code+" mess:"+message);
                                        LoadingDialog.close();
                                        runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
                                            }
                                        });
                                    }
                                });
                            }

                            @Override
                            public void onProgress(int progress, String status) {
                                Log.d(TAG, "logout: progress: " + progress+" status:"+status);
                            }
                        });
                    }else{
                        EMClient.getInstance().login(username, "1", new EMCallBack() {
                            @Override
                            public void onSuccess() {
                                Log.d(TAG, "login: onSuccess");

                                joinRoom(accessToken,username,nickNameVal);
                            }

                            @Override
                            public void onProgress(int progress, String status) {
                                Log.d(TAG, "login: onProgress");
                                LoadingDialog.close();
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
                                    }
                                });
                            }

                            @Override
                            public void onError(final int code, final String message) {
                                Log.d(TAG, "login: onError: " + code+" mess:"+message);
                                LoadingDialog.close();
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
                                    }
                                });
                            }
                        });
                    }

                }
            });
        }
    };





    private void joinRoom(String accessToken,String username,String nickname) {
        if(conferenceSession.getConferenceProfiles() != null){
            conferenceSession.getConferenceProfiles().clear();
        }
        EmLearnHelper.getInstance().setGlobalListeners();
        EMClient.getInstance().conferenceManager().set(accessToken,EASEMOB_APPKEY,username);
        EMClient.getInstance().conferenceManager().joinConference(conferenceSession.getConfrId(),
                conferenceSession.getConfrPwd(), new EMValueCallBack<EMConference>() {
            @Override
            public void onSuccess(EMConference value) {
                EMLog.i(TAG, "join  conference success");


                EMLog.i(TAG, "Get ConferenceId:"+ value.getConferenceId() + "conferenceRole :"+  conferenceRole + " role：" + value.getConferenceRole());
                conferenceSession.setConfrId(value.getConferenceId());
                conferenceSession.setConfrPwd(value.getPassword());
                conferenceSession.setUserName(username);
                conferenceSession.setNickName(nickname);
                conferenceSession.setConference(value);
                conferenceSession.setConfrType(confrType);
                LoadingDialog.close();
                if (confrType.equals(Constant.CLASS_TYPE_1V1)) {
                    Intent intent = new Intent(LoginActivity.this, OneMainActivity.class);
                    startActivity(intent);
                }else if (confrType.equals(Constant.CLASS_TYPE_SMALL)) {
                    Intent intent = new Intent(LoginActivity.this, SmallMainActivity.class);
                    startActivity(intent);
                }

                finish();
            }
            @Override
            public void onError(final int error, final String errorMsg) {
                LoadingDialog.close();
                Toast.makeText(LoginActivity.this, "登录错误", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
