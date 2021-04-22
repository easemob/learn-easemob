package com.t.emlearn.ui.view.chat.adapter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.chat.EMTextMessageBody;
import com.hyphenate.exceptions.HyphenateException;
import com.hyphenate.util.EMLog;
import com.t.emlearn.R;
import com.t.emlearn.ui.view.chat.widget.GifTextView;
import com.t.emlearn.ui.view.chat.widget.MediaManager;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Mao Jiqing on 2016/9/28.
 */
public class ChatListViewAdapter extends BaseAdapter {
    private String TAG = "ChatListViewAdapter";
    private Context context;
    private List<EMMessage> userList = new ArrayList<EMMessage>();
    private ArrayList<String> imageList = new ArrayList<String>();
    private HashMap<Integer,Integer> imagePosition = new HashMap<Integer,Integer>();
    public static final int FROM_USER_MSG = 0;//接收消息类型
    public static final int TO_USER_MSG = 1;//发送消息类型
    public static final int FROM_USER_IMG = 2;//接收消息类型
    public static final int TO_USER_IMG = 3;//发送消息类型
    public static final int FROM_USER_VOICE = 4;//接收消息类型
    public static final int TO_USER_VOICE = 5;//发送消息类型
    private int mMinItemWith;// 设置对话框的最大宽度和最小宽度
    private int mMaxItemWith;
//    public MyHandler handler;
    private Animation an;
    private SendErrorListener sendErrorListener;
    private VoiceIsRead voiceIsRead;
    public List<String> unReadPosition = new ArrayList<String>();
    private int voicePlayPosition = -1;
    private LayoutInflater mLayoutInflater;
    private boolean isGif = true;
    public boolean isPicRefresh = true;

    public interface SendErrorListener {
        public void onClick(int position);
    }

    public void setSendErrorListener(SendErrorListener sendErrorListener) {
        this.sendErrorListener = sendErrorListener;
    }

    public interface VoiceIsRead {
        public void voiceOnClick(int position);
    }

    public void setVoiceIsReadListener(VoiceIsRead voiceIsRead) {
        this.voiceIsRead = voiceIsRead;
    }

    public ChatListViewAdapter(Context context, List<EMMessage> userList) {
        this.userList = userList;
        this.context = context;
        mLayoutInflater = LayoutInflater.from(context);
        // 获取系统宽度
        WindowManager wManager = (WindowManager) context
                .getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics outMetrics = new DisplayMetrics();
        wManager.getDefaultDisplay().getMetrics(outMetrics);
        mMaxItemWith = (int) (outMetrics.widthPixels * 0.5f);
        mMinItemWith = (int) (outMetrics.widthPixels * 0.15f);
//        handler = new MyHandler(this);
    }

//    public static class MyHandler extends Handler {
//        private final WeakReference<ChatListViewAdapter> mTbAdapter;
//
//        public MyHandler(ChatListViewAdapter tbAdapter) {
//            mTbAdapter = new WeakReference<ChatListViewAdapter>(tbAdapter);
//        }
//
//        @Override
//        public void handleMessage(Message msg) {
//            ChatListViewAdapter tbAdapter = mTbAdapter.get();
//
//            if (tbAdapter != null) {
//            }
//        }
//    }

    public void setIsGif(boolean isGif) {
        this.isGif = isGif;
    }

    public void setUserList(List<EMMessage> userList) {
        this.userList = userList;
    }

    public void setImageList(ArrayList<String> imageList) {
        this.imageList = imageList;
    }
    public void setImagePosition(HashMap<Integer,Integer> imagePosition) {
        this.imagePosition = imagePosition;
    }

    @Override
    public int getCount() {
        if(userList == null){
            return 0;
        }
        EMLog.d(TAG, "--- getCount, " + userList.size());
        return userList.size();
    }
    public int getItemCount() {
        return getCount();
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    public Object getItem(int position) {
        if(userList == null){
            return null;
        }
        return userList.get(position);
    }
    /**
     * 返回所有的layout的数量
     *
     * */
    @Override
    public int getViewTypeCount() {
        EMLog.d(TAG, "--- getViewTypeCount");
        return 2;
    }
    @Override
    public int getItemViewType(int position) {
        // TODO Auto-generated method stub
        EMMessage emMessage = userList.get(position);

        EMLog.d(TAG, "--- getItemViewType, " + position + ", " + emMessage.toString());


        int ret = FROM_USER_MSG;
        if(emMessage !=  null) {
            if (emMessage.direct() == EMMessage.Direct.RECEIVE) {
                // 接收
                switch (emMessage.getType()) {
                    case TXT:
                        ret = FROM_USER_MSG;
                        break;
                    case IMAGE:
                        ret = FROM_USER_IMG;
                        break;
                }
            } else {
                // 发送
                switch (emMessage.getType()) {
                    case TXT:
                        ret = TO_USER_MSG;
                        break;
                    case IMAGE:
                        ret = TO_USER_IMG;
                        break;
                }
            }
            EMLog.d(TAG, "--- matchType(" + emMessage.getType() + " " + ret + "), " + (emMessage.direct() == EMMessage.Direct.RECEIVE ? "接收" : "发送") + ", " + emMessage.toString());
        }
        return ret;
    }

    @SuppressLint("InflateParams")
    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {
        EMMessage tbub = userList.get(i);
        switch (getItemViewType(i)) {
            case FROM_USER_MSG:
                FromUserMsgViewHolder holder;
                if (view == null) {
                    holder = new FromUserMsgViewHolder();
                    view = mLayoutInflater.inflate(R.layout.view_chat_msgfrom_list_item, null);
//                    holder.headicon = (ImageView) view
//                            .findViewById(R.id.tb_other_user_icon);
                    holder.chat_time = (TextView) view.findViewById(R.id.chat_time);
                    holder.content = (GifTextView) view.findViewById(R.id.content);
                    holder.nickName = (TextView) view.findViewById(R.id.headname);
                    try {
                        String nickName = tbub.getStringAttribute("nickName");
                        holder.nickName.setText(nickName);
                    } catch (HyphenateException e) {
                        e.printStackTrace();
                    }

                    view.setTag(holder);
                } else {
                    holder = (FromUserMsgViewHolder) view.getTag();
                }
                fromMsgUserLayout((FromUserMsgViewHolder) holder, tbub, i);
                break;
            case TO_USER_MSG:
                ToUserMsgViewHolder holder3;
                if (view == null) {
                    holder3 = new ToUserMsgViewHolder();
                    view = mLayoutInflater.inflate(R.layout.view_chat_msgto_list_item, null);
//                    holder3.headicon = (ImageView) view
//                            .findViewById(R.id.tb_my_user_icon);
                    holder3.chat_time = (TextView) view
                            .findViewById(R.id.mychat_time);
                    holder3.content = (GifTextView) view
                            .findViewById(R.id.mycontent);
                    holder3.sendFailImg = (ImageView) view
                            .findViewById(R.id.mysend_fail_img);
                    holder3.nickName = (TextView) view.findViewById(R.id.headname);
                    view.setTag(holder3);
                } else {
                    holder3 = (ToUserMsgViewHolder) view.getTag();
                }
                toMsgUserLayout((ToUserMsgViewHolder) holder3, tbub, i);
                break;
        }

        return view;
    }

    public class FromUserMsgViewHolder {
        public ImageView headicon;
        public TextView chat_time;
        public GifTextView content;
        public TextView nickName;
    }
    public class ToUserMsgViewHolder {
        public ImageView headicon;
        public TextView chat_time;
        public GifTextView content;
        public ImageView sendFailImg;
        public TextView nickName;
    }
    private void fromMsgUserLayout(final FromUserMsgViewHolder holder, final EMMessage tbub, final int position) {
//        holder.headicon.setBackgroundResource(R.mipmap.tongbao_hiv);
        /* time */
        if (position != 0) {
            String showTime = getTime(userList.get(position - 1).getMsgTime());
            if (showTime != null) {
                holder.chat_time.setVisibility(View.VISIBLE);
                holder.chat_time.setText(showTime);
            } else {
                holder.chat_time.setVisibility(View.GONE);
            }
        } else {
            String showTime = getTime(tbub.getMsgTime());
            holder.chat_time.setVisibility(View.VISIBLE);
            holder.chat_time.setText(showTime);
        }
        holder.content.setVisibility(View.VISIBLE);
        EMTextMessageBody body = (EMTextMessageBody)tbub.getBody();
        holder.content.setText(body.getMessage() );
//        holder.content.setSpanText(handler, tbub.getBody().toString(), isGif);
    }

    private void toMsgUserLayout(final ToUserMsgViewHolder holder, final EMMessage tbub, final int position) {
//        holder.headicon.setBackgroundResource(R.mipmap.grzx_tx_s);
//        holder.headicon.setImageDrawable(context.getResources()
//                .getDrawable(R.mipmap.grzx_tx_s));
        /* time */
        if (position != 0) {
            String showTime = getTime(userList.get(position - 1).getMsgTime());
            if (showTime != null) {
                holder.chat_time.setVisibility(View.VISIBLE);
                holder.chat_time.setText(showTime);
            } else {
                holder.chat_time.setVisibility(View.GONE);
            }
        } else {
            String showTime = getTime(tbub.getMsgTime());
            holder.chat_time.setVisibility(View.VISIBLE);
            holder.chat_time.setText(showTime);
        }

        holder.content.setVisibility(View.VISIBLE);
        EMTextMessageBody body = (EMTextMessageBody)tbub.getBody();
        holder.content.setText(body.getMessage());
//        holder.content.setSpanText(handler, tbub.getBody().toString(), isGif);
        holder.nickName.setText("我");
    }

    @SuppressLint("SimpleDateFormat")
    public String getTime(String time, String before) {
        String show_time = null;
        if (before != null) {
            try {
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                java.util.Date now = df.parse(time);
                java.util.Date date = df.parse(before);
                long l = now.getTime() - date.getTime();
                long day = l / (24 * 60 * 60 * 1000);
                long hour = (l / (60 * 60 * 1000) - day * 24);
                long min = ((l / (60 * 1000)) - day * 24 * 60 - hour * 60);
                if (min >= 1) {
                    show_time = time.substring(11);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            show_time = time.substring(11);
        }
        String getDay = getDay(time);
        if (show_time != null && getDay != null)
            show_time = getDay + " " + show_time;
        return show_time;
    }

    @SuppressLint("SimpleDateFormat")
    public static String returnTime() {
        SimpleDateFormat sDateFormat = new SimpleDateFormat(
                "yyyy-MM-dd HH:mm:ss");
        String date = sDateFormat.format(new java.util.Date());
        return date;
    }

    @SuppressLint("SimpleDateFormat")
    public String getDay(String time) {
        String showDay = null;
        String nowTime = returnTime();
        try {
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date now = df.parse(nowTime);
            java.util.Date date = df.parse(time);
            long l = now.getTime() - date.getTime();
            long day = l / (24 * 60 * 60 * 1000);
            if (day >= 365) {
                showDay = time.substring(0, 10);
            } else if (day >= 1 && day < 365) {
                showDay = time.substring(5, 10);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return showDay;
    }

    public void stopPlayVoice() {
        if (voicePlayPosition != -1) {
            View voicePlay = (View) ((Activity) context)
                    .findViewById(voicePlayPosition);
            if (voicePlay != null) {
                if (getItemViewType(voicePlayPosition) == FROM_USER_VOICE) {
                    voicePlay
                            .setBackgroundResource(R.drawable.chat_receiver_voice_node_playing003);
                } else {
                    voicePlay.setBackgroundResource(R.drawable.chat_adj);
                }
            }
            MediaManager.pause();
            voicePlayPosition = -1;
        }
    }

    public String getTime(long time){
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(time);
    }

}
