package com.t.emlearn.ui;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.media.AudioManager;
import android.media.projection.MediaProjectionManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.hyphenate.EMCallBack;
import com.hyphenate.EMChatRoomChangeListener;
import com.hyphenate.EMConferenceListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.*;
import com.hyphenate.media.EMCallSurfaceView;
import com.hyphenate.util.EMLog;
import com.superrtc.mediamanager.ScreenCaptureManager;
import com.t.emlearn.Constant;
import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.R;
import com.t.emlearn.service.CaptureScreenService;
import com.t.emlearn.ui.model.UserInfo;
import com.t.emlearn.ui.view.MemberView;
import com.t.emlearn.ui.view.OperListView;
import com.t.emlearn.ui.view.TopMainView;
import com.t.emlearn.ui.view.WhiteBoardView;
import com.t.emlearn.ui.view.chat.ChatView;
import com.t.emlearn.utils.PreferenceManager;
import com.t.emlearn.utils.ServerHttpHelper;
import com.t.emlearn.utils.ease.ConferenceSession;

import android.os.Handler;
import android.os.Message;
import android.widget.Toast;
import org.json.JSONException;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Queue;
import java.util.Set;
import java.util.TimeZone;
import java.util.concurrent.LinkedBlockingQueue;
/**
 * 主活动
 */
public class BaseMainActivity extends BaseActivity implements EMConferenceListener{
    private final String TAG = this.getClass().getSimpleName();

    protected EMWaterMarkOption watermark;
    protected ConferenceSession conferenceSession;
    private EMConference conference;
    private AudioManager audioManager;
    private MediaProjectionManager projectionManager;
    private TopMainView topMainView;
    private WhiteBoardView whiteBoardView;
    private MemberView shareDesktop;
    public static LinkedHashMap<String, UserInfo> userMap = new LinkedHashMap<String, UserInfo>();
    public static Queue notifyQueue = new LinkedBlockingQueue();
    private ImageView whiteBut;
    private LinearLayout whiteButGroup;
    private EMWhiteboard whiteBoard = null;
    private boolean isWhite = true;
    private ImageView shareBut;
    private boolean isShare = false;
    public ImageView chatBut;
    public OperListView operListView = null;
    private BaseMainActivity activity;
    private static Set<String> streamSet = new HashSet<String>();
    @Override
    protected void onStart() {
        super.onStart();
        notifyHandler();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        conferenceSession = EmLearnHelper.getInstance().getConferenceSession();
        conference = conferenceSession.getConference();

        EmLearnHelper.getInstance().removeGlobalListeners();
        EMClient.getInstance().conferenceManager().addConferenceListener(this);
        audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Log.i("base main","get service");
            projectionManager = (MediaProjectionManager)getSystemService(Context.MEDIA_PROJECTION_SERVICE);
//            activity.startActivityForResult(this.projectionManager.createScreenCaptureIntent(), 1000);
        }
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            try{
                ServerHttpHelper.OperRole(conferenceSession.getUserName(),7);
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        EMClient.getInstance().chatroomManager().addChatRoomChangeListener(new EMChatRoomChangeListener() {
            @Override
            public void onChatRoomDestroyed(String roomId, String roomName) {

            }

            @Override
            public void onMemberJoined(String roomId, String participant) {

            }

            @Override
            public void onMemberExited(String roomId, String roomName, String participant) {

            }

            @Override
            public void onRemovedFromChatRoom(int reason, String roomId, String roomName, String participant) {

            }

            @Override
            public void onMuteListAdded(String chatRoomId, List<String> mutes, long expireTime) {

                for (String mute: mutes){
                    UserInfo user = userMap.get(mute);
                    if (user != null){
                        user.IsChat =false;
                        if(operListView != null){
                            BaseMainActivity.this.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    operListView.getOperListViewAdapter().notifyDataSetChanged();
                                }
                            });

                        }
                    }
                    if(mute == EmLearnHelper.getInstance().getConferenceSession().getUserName()){
                        ChatView.isChat = false;
                    }
                }

            }

            @Override
            public void onMuteListRemoved(String chatRoomId, List<String> mutes) {
                for (String mute: mutes){
                    UserInfo user = userMap.get(mute);
                    if (user != null){
                        user.IsChat =true;
                        if(operListView != null){
                            BaseMainActivity.this.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    operListView.getOperListViewAdapter().notifyDataSetChanged();
                                }
                            });

                        }
                    }
                    if(mute == EmLearnHelper.getInstance().getConferenceSession().getUserName()){
                        ChatView.isChat = true;
                    }
                }
            }

            @Override
            public void onWhiteListAdded(String chatRoomId, List<String> whitelist) {

            }

            @Override
            public void onWhiteListRemoved(String chatRoomId, List<String> whitelist) {

            }

            @Override
            public void onAllMemberMuteStateChanged(String chatRoomId, boolean isMuted) {
                if(conferenceSession.getChatId().equals(chatRoomId)){
                    ChatView.isChat = !isMuted;
                }
            }

            @Override
            public void onAdminAdded(String chatRoomId, String admin) {

            }

            @Override
            public void onAdminRemoved(String chatRoomId, String admin) {

            }

            @Override
            public void onOwnerChanged(String chatRoomId, String newOwner, String oldOwner) {

            }

            @Override
            public void onAnnouncementChanged(String chatRoomId, String announcement) {

            }
        });

//        registerBroadReceiverMain();
        EMClient.getInstance().conferenceManager().enableStatistics(true);
        EMClient.getInstance().conferenceManager().startMonitorSpeaker(300);
        activity = this;
    }
    protected void initView(){
        /* top */
        topMainView = (TopMainView) findViewById(R.id.topView);
        topMainView.SetRoomName(conferenceSession.getRoomName());

        shareDesktop = (MemberView)findViewById(R.id.shareDesktop);
        /*white board*/
        whiteBoardView = (WhiteBoardView)findViewById(R.id.whiteboard);
        String userName = conferenceSession.getUserName();
        String emAccessToken = EMClient.getInstance().getAccessToken();
        String roomName = conferenceSession.getRoomName();
        String roomPass = conferenceSession.getConfrPwd();
        String chatRoomId = conferenceSession.getChatId();
        EMClient.getInstance().conferenceManager().joinWhiteboardRoomWithName(
                userName,
                emAccessToken,
                roomName,
                roomPass,
                new EMValueCallBack<EMWhiteboard>() {
                    @Override
                    public void onSuccess(EMWhiteboard value) {
                        whiteBoardView.loadUrl(value.getRoomUrl());
                        whiteBoard = value;
                    }

                    @Override
                    public void onError(int error, String errorMsg) {
                        EMClient.getInstance().conferenceManager().createWhiteboardRoom(userName
                                , emAccessToken, roomName, roomPass,true,
                                new EMValueCallBack<EMWhiteboard>() {
                                    @Override
                                    public void onSuccess(EMWhiteboard value) {
                                        runOnUiThread(new Runnable() {

                                          @Override
                                          public void run() {
                                              whiteBoardView.loadUrl(value.getRoomUrl());
                                              whiteBoard = value;
                                          }
                                      });

                                    }
                                    @Override
                                    public void onError(int error, String errorMsg) {
                                        runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                EMLog.i(TAG, "createWhiteboardRoom failed, error: " + error + " - " + errorMsg);
                                                Toast.makeText(getApplicationContext(), "创建白板  " + conferenceSession.getRoomName() + "失败: " + errorMsg + " !",
                                                        Toast.LENGTH_SHORT).show();
                                            }
                                        });
                                    }
                                }
                        );
                    }
                });

        EMClient.getInstance().chatroomManager().joinChatRoom(chatRoomId, new EMValueCallBack<EMChatRoom>() {
            @Override
            public void onSuccess(EMChatRoom value) {
                EMLog.i(TAG, "joinChatRoom suc");

            }

            @Override
            public void onError(int error, String errorMsg) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        EMLog.i(TAG, "joinChatRoom failed, error: " + error + " - " + errorMsg);
                        Toast.makeText(getApplicationContext(), "加入聊天室  " + chatRoomId + "失败: " + errorMsg + " !",
                                Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });
        whiteButGroup = (LinearLayout)findViewById(R.id.white_but_group);
        if(conferenceSession.getRoleType().equals(Constant.ROLE_STUDENT)){
            whiteButGroup.setVisibility(View.GONE);
        }
        whiteBut =(ImageView)findViewById(R.id.white_but) ;
        whiteBut.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                if(whiteBoard == null){
                    Toast.makeText(getApplicationContext(), "未启动白板",
                            Toast.LENGTH_SHORT).show();
                    return;
                }
                if(isWhite){
                    whiteBut.setImageDrawable(getBaseContext().getResources().getDrawable(R.drawable.white_but_off));
                }else{
                    whiteBut.setImageDrawable(getBaseContext().getResources().getDrawable(R.drawable.white_but_on));
                }
                isWhite=!isWhite;
                ConferenceSession conferenceSession = EmLearnHelper.getInstance().getConferenceSession();
                List aServentIds = new ArrayList();
                aServentIds.add(conferenceSession.getUserId());

                EMClient.getInstance().conferenceManager().updateWhiteboardRoomWithRoomId(
                        conferenceSession.getUserName(),
                        whiteBoard.getRoomId(),
                        conferenceSession.getAccessToken(),isWhite,aServentIds,true, new EMCallBack() {
                            @Override
                            public void onSuccess() {
                                EMLog.i(TAG,"success");
                            }

                            @Override
                            public void onError(int code, String error) {
                                EMLog.i(TAG,"code:"+code+" err:"+error);
                            }

                            @Override
                            public void onProgress(int progress, String status) {
                                EMLog.i(TAG,"progress");
                            }
                        }
                        );

            }
        } );

        shareBut =(ImageView)findViewById(R.id.share_but) ;
        shareBut.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                if(!isShare){
                    if(userMap.size()== 0){
                        Toast.makeText(getApplicationContext(), "无加入用户", Toast.LENGTH_SHORT).show();
                        return;
                    }
                    shareDesktop.setVideoStatus(true);
                    shareDesktop.setAudioStatus(true);
                    EMStreamParam desktopParam = shareDesktop.getStreamParam();

                    desktopParam.setStreamType(EMConferenceStream.StreamType.DESKTOP);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        desktopParam.setShareView(null);
                    } else {
                        desktopParam.setShareView(BaseMainActivity.this.getWindow().getDecorView());
                    }
                    DisplayMetrics dm = getResources().getDisplayMetrics();
                    int screenWidth = dm.widthPixels;
                    int screenHeight = dm.heightPixels;
                    EMClient.getInstance().callManager().getCallOptions().setVideoResolution(screenWidth, screenHeight);
                    desktopParam.setAudioOff(false);
                    EMClient.getInstance().conferenceManager().publish(desktopParam, new EMValueCallBack<String>() {
                        @Override
                        public void onSuccess(String value) {
                            conference.setPubStreamId(value, EMConferenceStream.StreamType.DESKTOP);
                            shareDesktop.setStreamId(value);
                            startScreenCapture();
                            BaseMainActivity.this.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    shareBut.setImageDrawable(getBaseContext().getResources().getDrawable(R.drawable.white_share_on));
                                }
                            });
                            isShare=!isShare;
                        }

                        @Override
                        public void onError(int error, String errorMsg) {
                            Toast.makeText(getApplicationContext(), "共享桌面失败", Toast.LENGTH_SHORT).show();
                        }
                    });

                }else{
                    if (ScreenCaptureManager.getInstance().state == ScreenCaptureManager.State.RUNNING) {
                        ScreenCaptureManager.getInstance().stop();
                        //关闭服务
                        Intent service = new Intent(BaseMainActivity.this, CaptureScreenService.class);
                        stopService(service);
                    }
                    String streamId = shareDesktop.getStreamId();
                    EMClient.getInstance().conferenceManager().unpublish(streamId, new EMValueCallBack<String>() {
                        @Override
                        public void onSuccess(String value) {
                            shareDesktop.setStreamId("");
                            BaseMainActivity.this.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    shareBut.setImageDrawable(getBaseContext().getResources().getDrawable(R.drawable.white_share_off));
                                }
                            });
                            isShare=!isShare;
                        }

                        @Override
                        public void onError(int error, String errorMsg) {
                            Toast.makeText(getApplicationContext(), "取消共享桌面失败", Toast.LENGTH_SHORT).show();
                        }
                    });

                }

            }
        } );

    }

    private void startScreenCapture() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if(ScreenCaptureManager.getInstance().state == ScreenCaptureManager.State.IDLE) {
                ScreenCaptureManager.getInstance().init(activity);
                ScreenCaptureManager.getInstance().setScreenCaptureCallback(new ScreenCaptureManager.ScreenCaptureCallback() {
                    @Override
                    public void onBitmap(Bitmap bitmap) {
                        EMClient.getInstance().conferenceManager().inputExternalVideoData(bitmap);
                    }
                });
            }
        }
    }

    protected MemberView getLocalView(){
        return null;
    }

    protected void onStreamAdd(EMConferenceStream stream){

    }
    protected void onStreamRemove(EMConferenceStream stream){

    }
    protected void onMemberChange(UserInfo u){

    }
    protected void onInnerMute(boolean isMute){ }
    /**
     * 开始推自己的数据
     */
    protected void publish() {

        MemberView localMemberView = getLocalView();
        localMemberView.setLocal();
        localMemberView.setName(conferenceSession.getNickName());
        addConferenceView(conferenceSession.getUserName(),"",null,localMemberView);
        //推流时设置水印图片
        if(PreferenceManager.getInstance().isWatermarkResolution()){
            //推流时设置水印图片
            EMClient.getInstance().conferenceManager().setWaterMark(watermark);
        }
        try{
            EMClient.getInstance().callManager().getCallOptions().setClarityFirst(true);
            EMStreamParam streamParam = localMemberView.getStreamParam();
            streamParam.setExtension("{\"nickName\":\""+conferenceSession.getNickName()+"\"}");
            EMClient.getInstance().conferenceManager().publish(streamParam, new EMValueCallBack<String>() {
                @Override
                public void onSuccess(String value) {
                    Log.i(TAG,"publish ok");
                    conference.setPubStreamId(value, EMConferenceStream.StreamType.NORMAL);
                    localMemberView.setStreamId(value);
                    localMemberView.setVideoStatus(true);
                    localMemberView.setAudioStatus(true);
                    getLocalView();
                    EMClient.getInstance().conferenceManager().openVideoTransfer();
                    EMClient.getInstance().conferenceManager().openVoiceTransfer();
                }

                @Override
                public void onError(int error, String errorMsg) {
                    EMLog.e(TAG, "publish failed: error=" + error + ", msg=" + errorMsg);
                }
            });
        }catch (Exception ex){
            ex.printStackTrace();
        }

    }


    /**
     * 订阅指定成员 stream
     */
    protected void subscribe(EMConferenceStream stream, final MemberView memberView) {
        EMClient.getInstance().conferenceManager().subscribe(stream, memberView.getSurfaceView(), new EMValueCallBack<String>() {
            @Override
            public void onSuccess(String value) {
                Log.i(TAG,"subscribe suc");
            }

            @Override
            public void onError(int error, String errorMsg) {
                Log.e(TAG,"subscribe err");
            }
        });
    }
    protected void unsubscribe(EMConferenceStream stream) {
        EMClient.getInstance().conferenceManager().unsubscribe(stream, new EMValueCallBack<String>() {
            @Override
            public void onSuccess(String value) {
                Log.i(TAG,"unsubscribe suc");
            }

            @Override
            public void onError(int error, String errorMsg) {
                Log.e(TAG,"unsubscribe err");
            }
        });
    }
    /**
     * 添加一个展示远端画面的 view
     */
    public void addConferenceView(String userName,String streamId,EMConferenceStream stream,MemberView memberView) {
        if (memberView.isLocal()){
            EMCallSurfaceView surfaceView = memberView.getSurfaceView();
            EMClient.getInstance().conferenceManager().setLocalSurfaceView(surfaceView);
            EMLog.d(TAG, "add conference view local -end-");
        }else{
            subscribe(stream,memberView);
            EMLog.d(TAG, "add conference view -end-" + stream.getMemberName()+" id:"+stream.getStreamId()+" type:"+stream.getStreamType());
        }
        memberView.setStreamId(streamId);
        memberView.setUserName(userName);

        if(stream != null){
            memberView.setAudioStatus(!stream.isAudioOff());
            memberView.setVideoStatus(!stream.isVideoOff());
        }

    }




    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data){
        super.onActivityResult(requestCode, resultCode, data);
        EMLog.i(TAG, "onActivityResult: " + requestCode + ", result code: " + resultCode);
        if (resultCode == RESULT_OK) {
            if (requestCode == ScreenCaptureManager.RECORD_REQUEST_CODE) {
                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    //启动前台服务
                    Intent service = new Intent(this, CaptureScreenService.class);
                    service.putExtra("code", resultCode);
                    service.putExtra("data", data);
                    startForegroundService(service);
                }else {
                    ScreenCaptureManager.getInstance().start(resultCode, data);
                }

//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//                    ScreenCaptureManager.getInstance().start(resultCode, data);
//                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        try {

            conference = null;
        } catch (Exception e) {
        }
    }

    /*confr*/
    public void notifyHandler(){
        while (true){
            if(notifyQueue.size() > 0){
                Object notifyObj = notifyQueue.poll();
                if(notifyObj instanceof EMConferenceMember){
                    onMemberJoined((EMConferenceMember)notifyObj);
                }else if(notifyObj instanceof EMConferenceStream){
                    onStreamAdd((EMConferenceStream)notifyObj);
                }
            }else{
                break;
            }
        }

    }
    @Override
    public void onMemberJoined(EMConferenceMember emConferenceMember) {
        EMLog.i(TAG,emConferenceMember.memberName + " member add!");

        try {
            ServerHttpHelper.GetNickName(
                    conferenceSession.getConfrId(),
                    emConferenceMember.memberName,
                    new ServerHttpHelper.GetNickNameCallBack() {
                        @Override
                        public void finish(String userName,String nickName) throws JSONException {
                            UserInfo u = new UserInfo();
                            u.key = emConferenceMember.memberId;
                            u.name = userName;
                            u.nickname = nickName;
                            u.IsVideo = true;
                            u.IsAudio = true;
                            u.IsWhiteborad = true;
                            u.IsChat = true;
                            userMap.put(u.name,u);
                            if(operListView != null){
                                BaseMainActivity.this.runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        operListView.getOperListViewAdapter().notifyDataSetChanged();
                                    }
                                });

                            }
                        }
                    }
            );
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @Override
    public void onMemberExited(EMConferenceMember emConferenceMember) {
        EMLog.i(TAG,emConferenceMember.memberName + " member del!");
        userMap.remove(emConferenceMember.memberId);
        if(operListView != null){
            BaseMainActivity.this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    operListView.getOperListViewAdapter().notifyDataSetChanged();
                }
            });

        }
    }

    @Override
    public void onStreamAdded(EMConferenceStream stream) {
        if (stream.getStreamId().equals("")){
            return;
        }
        if(streamSet.contains(stream.getStreamId())){
            Log.i("stream","id is handler:"+stream.getStreamId());
            return;
        }else{
            streamSet.add(stream.getStreamId());
            Log.i("stream","streamSet len:"+streamSet.size());
        }
        if(stream.getStreamType() == EMConferenceStream.StreamType.DESKTOP){
            runOnUiThread(new Runnable() {
                  @Override
                  public void run() {
                      shareDesktop.setVideoStatus(true);
                      shareDesktop.setAudioStatus(true);
                      shareDesktop.getImgAudio().setVisibility(View.GONE);
                      shareDesktop.getImgVideo().setVisibility(View.GONE);
                      shareDesktop.setVisibility(View.VISIBLE);
                      whiteButGroup.setVisibility(View.GONE);
                      chatBut.setVisibility(View.GONE);
                      whiteBoardView.getWebView().setVisibility(View.GONE);
                      addConferenceView(stream.getUsername(),stream.getStreamId(),stream,shareDesktop);
                  }
              });

        }else{
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    EMLog.i(TAG,stream.getUsername() + " stream add!");
                    onStreamAdd(stream);
                }
            });
        }

    }

    @Override
    public void onStreamRemoved(EMConferenceStream stream) {
        if(stream.getStreamType() == EMConferenceStream.StreamType.DESKTOP){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    shareDesktop.setVideoStatus(false);
                    shareDesktop.setAudioStatus(false);
                    shareDesktop.setVisibility(View.GONE);
                    if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
                        whiteButGroup.setVisibility(View.VISIBLE);
                    }
                    chatBut.setVisibility(View.VISIBLE);
                    whiteBoardView.getWebView().setVisibility(View.VISIBLE);
//                    unsubscribe(stream);
                }
            });
        }else{
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    EMLog.i(TAG,stream.getUsername() + " stream remove!");
                    onStreamRemove(stream);
                }
            });
        }
    }

    @Override
    public void onStreamUpdate(EMConferenceStream emConferenceStream) {

        UserInfo user = userMap.get(emConferenceStream.getUsername());
        if (user != null){
            user.IsAudio =!emConferenceStream.isAudioOff();
            user.IsVideo = !emConferenceStream.isVideoOff();
            if(operListView != null){
                BaseMainActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        operListView.getOperListViewAdapter().notifyDataSetChanged();
                    }
                });

            }
            if(emConferenceStream.getStreamType() != EMConferenceStream.StreamType.DESKTOP){
                onMemberChange(user);
            }
        }
    }
    @Override
    public void onStreamStateUpdated(String streamId,StreamState state){
        Log.i(TAG,"stream state:"+streamId+" state:"+state.name());
    }
    @Override
    public void onPassiveLeave(int i, String s) {

    }

    public void onMute(String adminId, String memId){
        EMLog.i(TAG, "onSetMute, memName: " + memId + "  adminId:" + adminId);
        onInnerMute(true);
    }

    /**
     * \~chinese
     * 被取消静音通知
     *
     * \~english
     * Be unmuted notification
     */
    public void onUnMute(String adminId, String memId){
        EMLog.i(TAG, "onSetMute, memName: " + memId + "  adminId:" + adminId);
        onInnerMute(false);
    }

    /**
     * \~chinese
     * 被全体静音 取消全体静音通知
     *
     * \~english
     * Be or cancel all muted  notification
     */
    public void onMuteAll(boolean mute){
        onInnerMute(mute);
    }

    @Override
    public void onConferenceState(ConferenceState conferenceState) {

    }

    @Override
    public void onStreamStatistics(EMStreamStatistics emStreamStatistics) {

    }

    @Override
    public void onStreamSetup(String s) {

    }

    @Override
    public void onSpeakers(List<String> list) {

    }

    @Override
    public void onReceiveInvite(String s, String s1, String s2) {

    }

    @Override
    public void onRoleChanged(EMConferenceManager.EMConferenceRole emConferenceRole) {

    }
}
