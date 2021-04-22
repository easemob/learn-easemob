package com.t.emlearn.ui.view;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;

import com.hyphenate.util.EMLog;
import com.t.emlearn.R;

import com.t.emlearn.utils.SysUtil;

import java.util.*;

public class MemberListViewAdapter extends BaseAdapter {

    private final String TAG = this.getClass().getSimpleName();
    private final Context mContext;
    private LayoutInflater inflater;

    private LinkedHashMap<String,MemberView> memberViewMap;
    private int selectPos = 0;
    private int wHight = 1000;
    private int wWidth = 2100;
    private int wOneWidth = 300;
    private int wOneHeight = 0;
    private int viewSize = 6;

    @SuppressWarnings("unchecked")
    public MemberListViewAdapter(Context context) {
        this.mContext = context;
        this.memberViewMap = new LinkedHashMap<String,MemberView>();

        inflater = (LayoutInflater) mContext
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);

        wWidth = SysUtil.getW(mContext);
        wHight = SysUtil.getH(mContext);
        Log.d(TAG, " --- wWidth:" + wWidth + ", wHight:" + wHight);
        if(wHight > wWidth){
            wWidth += wHight;
            wHight = wWidth - wHight;
            wWidth -= wHight;
        }
        int tmpPaddingOne = SysUtil.dip2px(mContext, 2);
        wOneWidth = wWidth/viewSize - tmpPaddingOne;
        wOneHeight = SysUtil.dip2px(mContext, 80);
        Log.d(TAG, " --- wWidth: " + wWidth + ", wHight: " + wHight + ", wOneWidth: " + wOneWidth);
        selectPos = 0;
//        if(pos < list.size())
//            selectPos = pos;
//        else

    }

    public void setPos(int pos){
        selectPos = pos;
    }

    public void addMemberView(MemberView mv){
        this.memberViewMap.put(mv.getKey(),mv);

    }

    public MemberView getItem(String key){
        return this.memberViewMap.get(key);
    }
    @Override
    public int getCount() {
      return this.memberViewMap.size();
//        return list == null || list.size()< 7 ? 7 : list.size();
    }

    @Override
    public Object getItem(int position) {
        return this.memberViewMap.values().toArray()[position];
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

//
//    /**
//     * 添加一个展示远端画面的 view
//     */
//    protected void addConferenceView(String streamId, EMConferenceStream stream, MemberView memberView) {
//        Log.d(TAG, " --- addConferenceView");
//        if (memberView.isLocal()){
//            EMCallSurfaceView surfaceView = memberView.getSurfaceView();
//            EMClient.getInstance().conferenceManager().setLocalSurfaceView(surfaceView);
//            Log.d(TAG, "add conference view local -end-");
//        }else{
//            subscribe(stream, memberView);
//            Log.d(TAG, "add conference view -end-" + stream.getMemberName());
//        }
//        memberView.setReady();
//        memberView.setStreamId(streamId);
//
//    }
//    /**
//     * 订阅指定成员 stream
//     */
//    protected void subscribe(EMConferenceStream stream, final MemberView memberView) {
//        Log.d(TAG, " --- subscribe");
//        memberView.setAudioStatus(!stream.isAudioOff());
//        memberView.setVideoStatus(!stream.isVideoOff());
//        EMClient.getInstance().conferenceManager().subscribe(stream, memberView.getSurfaceView(), new EMValueCallBack<String>() {
//            @Override
//            public void onSuccess(String value) {
//                Log.d(TAG, " --- subscribe, onSuccess: " + value);
//            }
//
//            @Override
//            public void onError(int error, String errorMsg) {
//                Log.d(TAG, " --- subscribe, onError(" + error + "): " + errorMsg);
//            }
//        });
//    }

    @Override
    public View getView(int position, View convertView, ViewGroup viewGroup) {
        MemberView item = (MemberView) getItem(position);
//        MemberView memberView = item.getMemberView();

        ViewHolder holder = new ViewHolder();

        if (convertView == null) {
            convertView = inflater.inflate(R.layout.view_memberlist, null);
            holder.vAll = (RelativeLayout) convertView.findViewById(R.id.layout_all);
            holder.vBlank = (RelativeLayout) convertView.findViewById(R.id.v_blank);
            holder.vMemberView = (RelativeLayout) convertView.findViewById(R.id.v_memberview);
//            item.setMemberView(holder.vMemberView);

            convertView.setTag(holder);
        }
        try{
            holder = (ViewHolder)convertView.getTag();

            RelativeLayout.LayoutParams lpView = new RelativeLayout.LayoutParams(
                    wOneWidth, wOneHeight);
            lpView.addRule(RelativeLayout.CENTER_IN_PARENT);
            Log.d(TAG, " --- MemberViewAdapter getView: " + item.getStreamId());
            holder.vMemberView.setVisibility(View.VISIBLE);
            holder.vBlank.setVisibility(View.GONE);
            holder.vMemberView.setLayoutParams(lpView);
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT);
            try{
                holder.vMemberView.addView(item, params);
            }catch (Exception e){
//                    e.printStackTrace();
                try{
                    if(item.getParent() != null) {
                        ((ViewGroup)item.getParent()).removeView(item); // <- fix
                        holder.vMemberView.addView(item, params);
                    }
                }catch (Exception e2){
                    e2.printStackTrace();
                }
            }

//            if(item.isBlank()){
//                // 显示空位置
//                holder.vBlank.setLayoutParams(lpView);
//                holder.vMemberView.setVisibility(View.GONE);
//                holder.vBlank.setVisibility(View.VISIBLE);
//            }else {
                // 显示MemberView
//                holder.vMemberView = item.getMemberView();// (MemberView) convertView.findViewById(R.id.memberview);
//                holder.vMemberView.setLocal(item.isSelf());

//            }

        }catch(Exception e){
            EMLog.e(TAG, e.getMessage());
        }

        return convertView;
    }

    class ViewHolder {
        public RelativeLayout vAll;
        public RelativeLayout vBlank;
        public RelativeLayout vMemberView;
//        public MemberView vMemberView;
    }
}