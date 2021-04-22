package com.t.emlearn.ui;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConference;
import com.hyphenate.chat.EMConferenceStream;
import com.hyphenate.media.EMCallSurfaceView;
import com.hyphenate.util.EMLog;
import com.t.emlearn.Constant;
import com.t.emlearn.R;
import com.t.emlearn.ui.model.UserInfo;
import com.t.emlearn.ui.view.MemberView;
import com.t.emlearn.ui.view.WhiteBoardView;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * 1v1页面
 */

public class OneMainActivity extends BaseMainActivity {
    private final String TAG = this.getClass().getSimpleName();


    private ImageView chatCloseBut;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_one_main);

        publish();

        super.initView();
        MemberView upView = (MemberView)findViewById(R.id.upMember);
        upView.setTeacher();
        MemberView downView = (MemberView)findViewById(R.id.downMember);
        downView.setStudent();
        chatBut = (ImageView)findViewById(R.id.chat_but);
        chatBut.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                LinearLayout chatZone = (LinearLayout)findViewById(R.id.chat_zone);
                chatZone.setVisibility(View.VISIBLE);
                chatBut.setVisibility(View.GONE);
            }
        } );
        chatCloseBut = (ImageView)findViewById(R.id.chat_zone_close);
        chatCloseBut.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                LinearLayout chatZone = (LinearLayout)findViewById(R.id.chat_zone);
                chatZone.setVisibility(View.GONE);
                chatBut.setVisibility(View.VISIBLE);
            }
        } );
    }

    public MemberView getLocalView(){
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            return (MemberView)findViewById(R.id.upMember);
        }else{
            return (MemberView)findViewById(R.id.downMember);
        }
    }
    public void onInnerMute(boolean isMute){
        MemberView addView;
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            addView = (MemberView)findViewById(R.id.upMember);
        }else{
            addView =  (MemberView)findViewById(R.id.downMember);
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                addView.setAudioStatus(!isMute);
                if(isMute){
                    EMClient.getInstance().conferenceManager().closeVoiceTransfer();
                }else{
                    EMClient.getInstance().conferenceManager().openVoiceTransfer();
                }
            }
        });
    }
    protected void onStreamAdd(EMConferenceStream stream){
        String nickName;
        JSONObject ret;
        String ext = stream.getExtension();
        try {
            ret = new JSONObject(ext);
            nickName = (String)ret.get("nickName");
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }
        MemberView addView;
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            addView = (MemberView)findViewById(R.id.downMember);
        }else{
            addView = (MemberView)findViewById(R.id.upMember);
        }
        addView.setName(nickName);
        addConferenceView(stream.getUsername(),stream.getStreamId(),stream,addView);
    }
    protected void onStreamRemove(EMConferenceStream stream){
        MemberView addView;
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            addView = (MemberView)findViewById(R.id.downMember);
        }else{
            addView = (MemberView)findViewById(R.id.upMember);
        }
        addView.setVideoStatus(false);
        unsubscribe(stream);
    }
    protected void onMemberChange(UserInfo u){
        MemberView addView;
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            addView = (MemberView)findViewById(R.id.downMember);
        }else{
            addView = (MemberView)findViewById(R.id.upMember);
        }
        addView.setAudioStatus(u.IsAudio);
        addView.setVideoStatus(u.IsVideo);
    }

    @Override
    protected void onStart() {
        super.onStart();

    }

    @Override
    protected void onDestroy() {
		super.onDestroy();
	}
}
