package com.t.emlearn.ui.view.chat.adapter;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.widget.ImageView;
import android.widget.TextView;

import com.hyphenate.chat.EMMessage;
import com.hyphenate.util.EMLog;
import com.t.emlearn.R;

import java.lang.ref.WeakReference;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by Mao Jiqing on 2016/9/29.
 */
public class ChatRecyclerAdapter extends
        RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private String TAG = "ChatRecyclerAdapter";
    private Context context;
    private LayoutInflater inflater;
    private List<EMMessage> userList = new ArrayList<EMMessage>();
    public static final int FROM_USER_MSG = 0;//接收消息类型
    public static final int TO_USER_MSG = 1;//发送消息类型
    public static final int FROM_USER_IMG = 2;//接收消息类型
    public static final int TO_USER_IMG = 3;//发送消息类型
    public static final int FROM_USER_VOICE = 4;//接收消息类型
    public static final int TO_USER_VOICE = 5;//发送消息类型
    private int mMinItemWith;// 设置对话框的最大宽度和最小宽度
    private int mMaxItemWith;
    public MyHandler handler;
    private Animation an;
    private SendErrorListener sendErrorListener;
    public List<String> unReadPosition = new ArrayList<String>();
    private LayoutInflater mLayoutInflater;
    private boolean isGif = true;
    public boolean isPicRefresh = true;

    public interface SendErrorListener {
        public void onClick(int position);
    }

    public void setSendErrorListener(SendErrorListener sendErrorListener) {
        this.sendErrorListener = sendErrorListener;
    }

    public ChatRecyclerAdapter(Context context, List<EMMessage> userList) {
        this.context = context;
        this.userList = userList;
        mLayoutInflater = LayoutInflater.from(context);
        this.inflater = mLayoutInflater.from(context);
        // 获取系统宽度
        WindowManager wManager = (WindowManager) context
                .getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics outMetrics = new DisplayMetrics();
        wManager.getDefaultDisplay().getMetrics(outMetrics);
        mMaxItemWith = (int) (outMetrics.widthPixels * 0.5f);
        mMinItemWith = (int) (outMetrics.widthPixels * 0.15f);
        handler = new MyHandler(this);
    }

    public static class MyHandler extends Handler {
        private final WeakReference<ChatRecyclerAdapter> mTbAdapter;

        public MyHandler(ChatRecyclerAdapter tbAdapter) {
            mTbAdapter = new WeakReference<ChatRecyclerAdapter>(tbAdapter);
        }

        @Override
        public void handleMessage(Message msg) {
            ChatRecyclerAdapter tbAdapter = mTbAdapter.get();

            if (tbAdapter != null) {
            }
        }
    }

    public void setIsGif(boolean isGif) {
        this.isGif = isGif;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getItemCount() {
        if(userList == null){
            return 0;
        }
        EMLog.d(TAG, "--- getItemCount, " + userList.size());
        return userList.size();
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

    /**
     * @param parent
     * @param viewType
     * @return
     */
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        EMLog.d(TAG, "--- onCreateViewHolder, " + viewType);
        View view = null;
        RecyclerView.ViewHolder holder = null;
        switch (viewType) {
            case FROM_USER_MSG:
                view = inflater.inflate(R.layout.view_chat_msgfrom_list_item, parent, false);
                holder = new FromUserMsgViewHolder(view);
                break;
            case TO_USER_MSG:
                view = inflater.inflate(R.layout.view_chat_msgto_list_item, parent, false);
                holder = new ToUserMsgViewHolder(view);
                break;
        }
        return holder;
    }

    /**
     * @param holder
     * @param position
     */
    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {

        final EMMessage tbub = (EMMessage)getItem(position);
        EMLog.d(TAG, "--- onBindViewHolder, " + position + ", " + tbub.toString());

        try {
            if (holder instanceof FromUserMsgViewHolder) {
                fromMsgUserLayout((FromUserMsgViewHolder) holder, tbub, position);
            }else
            if (holder instanceof ToUserMsgViewHolder) {
                toMsgUserLayout((ToUserMsgViewHolder) holder, tbub, position);
            }

        } catch (Exception e) {
            EMLog.e(TAG, e.getMessage());
        } catch (OutOfMemoryError eom) {
            EMLog.e(TAG, eom.getMessage());
        }
    }


    private void fromMsgUserLayout(final FromUserMsgViewHolder holder, final EMMessage tbub, final int position) {
        holder.headicon.setBackgroundResource(R.drawable.chat_tongbao_hiv);
        /* time */
        if (position != 0) {
            String showTime = getTime(tbub.getMsgTime());
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
        holder.content.setText( tbub.getBody().toString());
//        holder.content.setSpanText(handler, tbub.getBody().toString(), isGif);
    }

    private void toMsgUserLayout(final ToUserMsgViewHolder holder, final EMMessage tbub, final int position) {
        holder.headicon.setBackgroundResource(R.drawable.chat_tongbao_hiv);
        /* time */
        if (position != 0) {
            String showTime = getTime(tbub.getMsgTime());
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
        holder.content.setText(tbub.getBody().toString());
//        holder.content.setText(handler, tbub.getBody().toString(), isGif);
    }

    class FromUserMsgViewHolder extends RecyclerView.ViewHolder {
        private ImageView headicon;
        private TextView chat_time;
        private TextView content;
//        private GifTextView content;

        public FromUserMsgViewHolder(View view) {
            super(view);
            headicon = (ImageView) view
                    .findViewById(R.id.tb_other_user_icon);
            chat_time = (TextView) view.findViewById(R.id.chat_time);
            content = (TextView) view.findViewById(R.id.content);
//            content = (GifTextView) view.findViewById(R.id.content);
        }
    }
//
//    class FromUserImageViewHolder extends RecyclerView.ViewHolder {
//        private ImageView headicon;
//        private TextView chat_time;
//        private BubbleImageView image_Msg;
//
//        public FromUserImageViewHolder(View view) {
//            super(view);
//            headicon = (ImageView) view
//                    .findViewById(R.id.tb_other_user_icon);
//            chat_time = (TextView) view.findViewById(R.id.chat_time);
//            image_Msg = (BubbleImageView) view
//                    .findViewById(R.id.image_message);
//        }
//    }


    class ToUserMsgViewHolder extends RecyclerView.ViewHolder {
        private ImageView headicon;
        private TextView chat_time;
        private TextView content;
//        private GifTextView content;
        private ImageView sendFailImg;

        public ToUserMsgViewHolder(View view) {
            super(view);
            headicon = (ImageView) view
                    .findViewById(R.id.tb_my_user_icon);
            chat_time = (TextView) view
                    .findViewById(R.id.mychat_time);
            content = (TextView) view
                    .findViewById(R.id.mycontent);
//            content = (GifTextView) view
//                    .findViewById(R.id.mycontent);
            sendFailImg = (ImageView) view
                    .findViewById(R.id.mysend_fail_img);
        }
    }

    public String getTime(long time){
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(time);
    }

}
