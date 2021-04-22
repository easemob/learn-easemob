package com.t.emlearn.ui;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;
import com.hyphenate.EMCallBack;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMConferenceStream;
import com.hyphenate.media.EMCallSurfaceView;
import com.hyphenate.util.EMLog;
import com.t.emlearn.Constant;
import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.R;
import com.t.emlearn.runtimepermissions.PermissionsManager;
import com.t.emlearn.runtimepermissions.PermissionsResultAction;
import com.t.emlearn.ui.model.UserInfo;
import com.t.emlearn.ui.view.MemberListView;
import com.t.emlearn.ui.view.MemberView;
import com.t.emlearn.ui.view.OperListView;
import com.t.emlearn.ui.view.chat.ChatView;

import org.json.JSONException;
import org.json.JSONObject;
/**
 * 小班课页面
 */
public class SmallMainActivity extends BaseMainActivity {

    private MemberListView memberListView;

    private ImageView operBut;
    private ImageView closeBut;

    private LinearLayout cZone;
    private RelativeLayout operTitle;
    private RelativeLayout chatTitle;
    private ChatView chatView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_small_main);
        memberListView = (MemberListView)findViewById(R.id.member_list);
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            memberListView.addTeacherMemberView(true);
        }else{
            memberListView.addTeacherMemberView(false);
            memberListView.addLocalMemberView();
        }

        publish();
        super.initView();
        cZone = (LinearLayout)findViewById(R.id.c_zone);
        operTitle = (RelativeLayout)findViewById(R.id.v_title_oper);
        chatTitle = (RelativeLayout)findViewById(R.id.v_title_chat);
        chatView = (ChatView)findViewById(R.id.chat_view);
        operListView = (OperListView)findViewById(R.id.oper_view);

        chatBut = (ImageView)findViewById(R.id.chat_but);
        chatBut.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                openCzone(true);
            }
        } );
        closeBut = (ImageView)findViewById(R.id.title_zone_close);
        closeBut.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                closeCzone();
            }
        } );


        operBut = (ImageView)findViewById(R.id.oper_but);
        operBut.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                openCzone(false);
            }
        } );
        if(conferenceSession.getRoleType().equals(Constant.ROLE_STUDENT)){
            operBut.setVisibility(View.GONE);
        }
    }

    public void openCzone(boolean isChat){
        cZone.setVisibility(View.VISIBLE);
        if(isChat){
            chatTitle.setVisibility(View.VISIBLE);
            chatView.setVisibility(View.VISIBLE);
            chatBut.setVisibility(View.GONE);
            if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
                operTitle.setVisibility(View.GONE);
                operListView.setVisibility(View.GONE);
                operBut.setVisibility(View.VISIBLE);
            }
        }else{
            chatTitle.setVisibility(View.GONE);
            chatView.setVisibility(View.GONE);
            chatBut.setVisibility(View.VISIBLE);
            if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
                operTitle.setVisibility(View.VISIBLE);
                operListView.setVisibility(View.VISIBLE);
                operBut.setVisibility(View.GONE);
            }

        }
    }

    public void closeCzone(){
        cZone.setVisibility(View.GONE);
        chatBut.setVisibility(View.VISIBLE);
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            operBut.setVisibility(View.VISIBLE);
        }
    }

    public MemberView getLocalView(){
        MemberView addView;
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            addView =  memberListView.getMemberView(Constant.KEY_MEMBER_LIST);
        }else{
            addView =  memberListView.getMemberView(EmLearnHelper.getInstance().getConferenceSession().getUserName());
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                memberListView.getAdapter().notifyDataSetChanged();
            }
        });
        return addView;
    }
    public void onInnerMute(boolean isMute){
        MemberView addView;
        if(conferenceSession.getRoleType().equals(Constant.ROLE_TEACHER)){
            addView =  memberListView.getMemberView(Constant.KEY_MEMBER_LIST);
        }else{
            addView =  memberListView.getMemberView(EmLearnHelper.getInstance().getConferenceSession().getUserName());
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
        MemberView addView;
        JSONObject ret;
        String nickName;
        String ext = stream.getExtension();
        try {
            ret = new JSONObject(ext);
            nickName = (String)ret.get("nickName");
        } catch (JSONException e) {
            e.printStackTrace();
            return;
        }
        if(stream.getUsername().endsWith(".tea")){
            addView = memberListView.getMemberView(Constant.KEY_MEMBER_LIST);
        }else{
            addView = new MemberView(this);
            addView.setKey(stream.getUsername());
            addView.setStudent();
            memberListView.addMemberView(addView);
        }
        addView.setName(nickName);

        addConferenceView(stream.getUsername(),stream.getStreamId(),stream,addView);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                memberListView.getAdapter().notifyDataSetChanged();
            }
        });
    }
    protected void onStreamRemove(EMConferenceStream stream){
        MemberView addView;
        if(stream.getUsername().endsWith(".tea")){
            addView = memberListView.getMemberView(Constant.KEY_MEMBER_LIST);
        }else{
            addView = memberListView.getMemberView(stream.getUsername());
        }
        addView.setVideoStatus(false);
        unsubscribe(stream);
    }
    protected void onMemberChange(UserInfo u){
        MemberView addView;
        if(u.name.endsWith(".tea")){
            addView = memberListView.getMemberView(Constant.KEY_MEMBER_LIST);
        }else{
            addView = memberListView.getMemberView(u.name);
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
