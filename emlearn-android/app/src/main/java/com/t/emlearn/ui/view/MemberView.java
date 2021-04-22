package com.t.emlearn.ui.view;


import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConferenceStream;
import com.hyphenate.chat.EMStreamParam;
import com.hyphenate.media.EMCallSurfaceView;
import com.hyphenate.util.EMLog;
import com.superrtc.sdk.VideoView;
import com.t.emlearn.Constant;
import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.R;
import com.t.emlearn.ui.BaseMainActivity;
import com.t.emlearn.ui.model.UserInfo;
import com.t.emlearn.utils.PreferenceManager;

import java.lang.reflect.Member;

import static com.t.emlearn.R.mipmap.ic_student;
import static com.t.emlearn.R.mipmap.ic_teacher;
/**
 * 成员显示
 */
public class MemberView extends RelativeLayout {
    private final String TAG = this.getClass().getSimpleName();

    private EMCallSurfaceView surfaceView;
    private ImageView avatarView;
    private ImageView imgVideo, imgAudio;
    private Context context;
    private TextView tvName;
    private EMStreamParam normalParam = null;
    private MemberView selfView;
    private boolean isLocal = false;
    private boolean isReady = false;
    private String streamId;
    private String name;
    private String key;
    private boolean isTeacher;
    private Member student;
    private boolean isUserTeacher;
    private String userName;

    public MemberView(Context context) {
        this(context, null);
    }

    public MemberView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MemberView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        LayoutInflater.from(context).inflate(R.layout.view_member, this);

        normalParam = new EMStreamParam();
        normalParam.setStreamType(EMConferenceStream.StreamType.NORMAL);
        String CameraResolution = PreferenceManager.getInstance().getCallFrontCameraResolution();
        if (CameraResolution.equals("360P")) {
            normalParam.setVideoWidth(480);
            normalParam.setVideoHeight(360);
        } else if (CameraResolution.equals("(Auto)480P")) {
            normalParam.setVideoWidth(720);
            normalParam.setVideoHeight(480);
        } else if (CameraResolution.equals("720P")) {
            normalParam.setVideoWidth(1280);
            normalParam.setVideoHeight(720);
        }
        if(EmLearnHelper.getInstance().getConferenceSession().getRoleType().equals(Constant.ROLE_TEACHER)){
            isUserTeacher = true;
        }else{
            isUserTeacher = false;
        }

        init();
    }

    private void init() {
        selfView = this;
        surfaceView = (EMCallSurfaceView) findViewById(R.id.item_surface_view);
        surfaceView.setScaleMode(VideoView.EMCallViewScaleMode.EMCallViewScaleModeAspectFill);
        surfaceView.setZOrderOnTop(false);
        surfaceView.setZOrderMediaOverlay(false);
        avatarView =(ImageView) findViewById(R.id.img_call_avatar);
        imgAudio = (ImageView) findViewById(R.id.icon_audio);
        imgVideo = (ImageView) findViewById(R.id.icon_video);
        tvName = (TextView) findViewById(R.id.tv_name);
        tvName.setText("");
        setAudioStatus(false);
        setVideoStatus(false);

        this.setOnAudioClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                EMLog.d(TAG, " --- audioSwitch ");
                UserInfo ui = BaseMainActivity.userMap.get(userName);
                if (normalParam.isAudioOff()) {
                    selfView.setAudioStatus(false);
                    if(!isLocal()){
                        if(isUserTeacher && ui != null && ui.key != null){
                            EMClient.getInstance().conferenceManager().muteMember(ui.key);
                        }

                    }else{
                        EMClient.getInstance().conferenceManager().closeVoiceTransfer();
                    }

                } else {
                    selfView.setAudioStatus(true);
                    if(!isLocal()){
                        if(isUserTeacher&& ui != null && ui.key != null){
                            EMClient.getInstance().conferenceManager().unmuteMember(ui.key);
                        }

                    }else{
                        EMClient.getInstance().conferenceManager().openVoiceTransfer();
                    }

                }
            }
        });
        this.setOnVideoClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!isLocal()){
                    return;
                }
                EMLog.d(TAG, " --- videoSwitch ");
                if (normalParam.isVideoOff()) {
                    selfView.setVideoStatus(false);
                    EMClient.getInstance().conferenceManager().closeVideoTransfer();
                } else {
                    selfView.setVideoStatus(true);
                    EMClient.getInstance().conferenceManager().openVideoTransfer();

                }
            }
        });
//        talkingLayout = (RelativeLayout) findViewById(R.id.talking_layout);
//        surfaceView.setScaleMode(VideoView.EMCallViewScaleMode.EMCallViewScaleModeAspectFill);
    }
    public ImageView getImgVideo(){
        return imgVideo;
    }

    public ImageView getImgAudio() {
        return imgAudio;
    }

    public boolean isReady(){
        return this.isReady;
    }
    public void setReady(){
        this.isReady = true;
    }
    public void setUserName(String userName){
        this.userName = userName;
    }
    /**
     * 更新静音状态
     */
    public void setAudioStatus(boolean state) {
        ((Activity)context).runOnUiThread(new Runnable(){

            @Override
            public void run() {
                if (state) {
                    imgAudio.setImageDrawable(context.getResources().getDrawable(R.mipmap.ic_audio));

                } else {
                    imgAudio.setImageDrawable(context.getResources().getDrawable(R.mipmap.ic_audio_disable));

                }
                normalParam.setAudioOff(state);
            }
        });


    }
    public EMStreamParam getStreamParam(){
        return normalParam;
    }

    public boolean isTeacher() {
        return isTeacher;
    }

    public void setTeacher() {
        isTeacher = true;
        avatarView.setImageResource(ic_teacher);
    }
    public void setStudent(){
        avatarView.setImageResource(ic_student);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
        if(tvName != null) {
            tvName.setText("" + name);
        }
    }


    public String getKey(){
        return key;
    }
    public void setKey(String key){
        this.key = key;
    }

    public boolean isAudioOff() {
        return normalParam.isAudioOff();
    }

    public boolean isVideoOff() {
        return normalParam.isVideoOff();
    }
    /**
     * 更新视频显示状态
     */
    public void setVideoStatus(boolean state) {
        ((Activity)context).runOnUiThread(new Runnable(){

            @Override
            public void run() {
                if (state) {

                    avatarView.setVisibility(View.GONE);
                    surfaceView.setVisibility(View.VISIBLE);;
                    imgVideo.setImageDrawable(context.getResources().getDrawable(R.mipmap.ic_video));

                } else {
                    surfaceView.setVisibility(View.GONE);
                    avatarView.setVisibility(View.VISIBLE);
                    imgVideo.setImageDrawable(context.getResources().getDrawable(R.mipmap.ic_video_disable));

                }
                normalParam.setVideoOff(state);
            }
        });

    }
    public void setOnAudioClickListener(View.OnClickListener onClickListener)
    {
        imgAudio.setOnClickListener(onClickListener);
    }

    public void setOnVideoClickListener(View.OnClickListener onClickListener)
    {
        imgVideo.setOnClickListener(onClickListener);
    }
    /**
     * 设置当前控件显示的 Stream Id
     */
    public void setStreamId(String streamId) {
        this.streamId = streamId;
    }

    public String getStreamId() {
        return streamId;
    }

    public EMCallSurfaceView getSurfaceView() {
        return surfaceView;
    }



    public void setLocal(){
        this.isLocal = true;
    }

    public boolean isLocal(){
        return this.isLocal;
    }
}
