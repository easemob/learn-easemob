package com.t.emlearn.ui.view.chat;


import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.Spannable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.hyphenate.EMMessageListener;
import com.hyphenate.EMValueCallBack;
import com.hyphenate.chat.EMChatRoom;
import com.hyphenate.chat.EMClient;
import com.hyphenate.chat.EMMessage;
import com.hyphenate.util.EMLog;
import com.t.emlearn.Constant;
import com.t.emlearn.EmLearnHelper;
import com.t.emlearn.R;
import com.t.emlearn.ui.view.MemberView;
import com.t.emlearn.ui.view.chat.adapter.ChatListViewAdapter;
import com.t.emlearn.ui.view.chat.adapter.DataAdapter;
import com.t.emlearn.ui.view.chat.adapter.ExpressionAdapter;
import com.t.emlearn.ui.view.chat.adapter.ExpressionPagerAdapter;
import com.t.emlearn.ui.view.chat.utils.KeyBoardUtils;
import com.t.emlearn.ui.view.chat.utils.ScreenUtil;
import com.t.emlearn.ui.view.chat.utils.SmileUtils;
import com.t.emlearn.ui.view.chat.widget.ChatBottomView;
import com.t.emlearn.ui.view.chat.widget.ExpandGridView;
import com.t.emlearn.ui.view.chat.widget.HeadIconSelectorView;
import com.t.emlearn.ui.view.chat.widget.pulltorefresh.PullToRefreshLayout;
import com.t.emlearn.ui.view.chat.widget.pulltorefresh.PullToRefreshListView;
import com.t.emlearn.ui.view.chat.widget.pulltorefresh.WrapContentLinearLayoutManager;
import com.t.emlearn.ui.view.chat.widget.pulltorefresh.base.PullToRefreshView;
import com.t.emlearn.utils.ease.ConferenceSession;

import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.viewpager.widget.ViewPager;

public class ChatView extends RelativeLayout {
    private final String TAG = this.getClass().getSimpleName();

    private Context context;

    public static final int SEND_OK = 0x1110;
    public static final int REFRESH = 0x0011;
    public static final int RECERIVE_OK = 0x1111;
    public static final int PULL_TO_REFRESH_DOWN = 0x0111;

    private Handler mMessageHandler;

    private boolean CAN_WRITE_EXTERNAL_STORAGE = true;
    private List<String> reslist;
    public PullToRefreshLayout pullList;
    public View activityRootView;
    public EditText mEditTextContent;
    public TextView send_emoji_icon;
    //    public ImageView emoji;
    public Button mess_iv;
    //    public ImageView voiceIv;
    public ListView mess_lv;
    public ViewPager expressionViewpager;
    public LinearLayout emoji_group;
    //    public AudioRecordButton voiceBtn;
    public ChatBottomView tbbv;
    private DataAdapter adapter;
    public int position; //加载滚动刷新位置
    public int bottomStatusHeight = 0;
    public int listSlideHeight = 0;//滑动距离
    public int page = 0;
    public int number = 10;
    private PullToRefreshListView myList;
    public List<EMMessage> tblist = new ArrayList<EMMessage>();
    private ChatListViewAdapter tbAdapter;
    private ImageView chatMessageBut;
    private boolean isChatMessage = true;
    protected EMMessageListener mEMMessageListener;
    public static boolean isChat = true;

    public ChatView(Context context) {
        this(context, null);
    }

    public ChatView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ChatView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        LayoutInflater.from(context).inflate(R.layout.view_chat, this);

        initView();
        initpop();
        init();

        mEMMessageListener = new EMMessageListener() {
            @Override
            public void onMessageReceived(List<EMMessage> messages) {
                if(!isChat){
                    Toast.makeText(context, "已禁言", Toast.LENGTH_SHORT).show();
                    return;
                }
                EMLog.d(TAG, " --- onMessageReceived: messages:" + (messages != null ? messages.size() : "null"));
                for (EMMessage m : messages) {
                    tblist.add(m);
//                    tbAdapter.notifyItemInserted(tblist
//                            .size() - 1);
//                    myList.smoothScrollToPosition(tbAdapter.getItemCount() - 1);
                }
                mMessageHandler.sendEmptyMessage(RECERIVE_OK);

            }

            @Override
            public void onCmdMessageReceived(List<EMMessage> messages) {

            }

            @Override
            public void onMessageRead(List<EMMessage> messages) {

            }

            @Override
            public void onMessageDelivered(List<EMMessage> messages) {

            }

            @Override
            public void onMessageRecalled(List<EMMessage> messages) {

            }

            @Override
            public void onMessageChanged(EMMessage message, Object change) {

            }
        };
        EMClient.getInstance().chatManager().addMessageListener(mEMMessageListener);

        mMessageHandler = new Handler(Looper.myLooper()) {

            @Override
            public void handleMessage(Message msg) {
                switch (msg.what) {
                    case REFRESH:
                        EMLog.d(TAG, " --- handleMessage: msg REFRESH");
                        tbAdapter.isPicRefresh = true;
                        tbAdapter.notifyDataSetChanged();
                        int position = tbAdapter.getItemCount() - 1 < 0 ? 0 : tbAdapter.getItemCount() - 1;
                        myList.smoothScrollToPosition(position);
                        break;
                    case SEND_OK:
                        EMLog.d(TAG, " --- handleMessage: msg SEND_OK");
                        mEditTextContent.setText("");
                        tbAdapter.isPicRefresh = true;
                        tbAdapter.notifyDataSetChanged();
//                        tbAdapter.notifyItemInserted(tblist
//                                .size() - 1);
                        myList.smoothScrollToPosition(tbAdapter.getItemCount() - 1);
                        break;
                    case RECERIVE_OK:
                        EMLog.d(TAG, " --- handleMessage: msg RECERIVE_OK");
                        tbAdapter.isPicRefresh = true;
                        tbAdapter.notifyDataSetChanged();
//                        tbAdapter.notifyItemInserted(tblist
//                                .size() - 1);
                        myList.smoothScrollToPosition(tbAdapter.getItemCount() - 1);
                        break;
//                case PULL_TO_REFRESH_DOWN:
//                    pullList.refreshComplete();
//                    tbAdapter.notifyDataSetChanged();
//                    myList.smoothScrollToPosition(position - 1);
//                    isDown = false;
//                    break;
                    default:
                        break;
                }
            }
        };
    }

    protected void initView() {
        pullList = (PullToRefreshLayout) findViewById(R.id.content_lv);
        activityRootView = findViewById(R.id.layout_tongbao_rl);
        mEditTextContent = (EditText) findViewById(R.id.mess_et);
        mess_iv = (Button) findViewById(R.id.mess_iv);
        mess_iv.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v) {
                if(!isChat){
                    Toast.makeText(context, "已禁言", Toast.LENGTH_SHORT).show();
                    return;
                }
            }
        });
//        emoji = (ImageView) findViewById(R.id.emoji);
//        voiceIv = (ImageView) findViewById(R.id.voice_iv);
        expressionViewpager = (ViewPager) findViewById(R.id.vPager);
//        voiceBtn = (AudioRecordButton) findViewById(R.id.voice_btn);
        emoji_group = (LinearLayout) findViewById(R.id.emoji_group);
        send_emoji_icon = (TextView) findViewById(R.id.send_emoji_icon);
        tbbv = (ChatBottomView) findViewById(R.id.other_lv);

        pullList.setSlideView(new PullToRefreshView(context).getSlideView(PullToRefreshView.LISTVIEW));
        myList = (PullToRefreshListView) pullList.returnMylist();
        chatMessageBut = findViewById(R.id.chat_message_but);
        ConferenceSession conferenceSession = EmLearnHelper.getInstance().getConferenceSession();
        if(conferenceSession.getRoleType().equals(Constant.ROLE_STUDENT)){
            chatMessageBut.setVisibility(View.GONE);
        }
        chatMessageBut.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isChatMessage) {

                    EMClient.getInstance().chatroomManager().muteAllMembers(
                            EmLearnHelper.getInstance().getConferenceSession().getChatId(), new EMValueCallBack<EMChatRoom>() {
                        @Override
                        public void onSuccess(EMChatRoom value) {
                            EMLog.i(TAG,"mute all");
                            ((Activity)context).runOnUiThread(new Runnable() {
                                  @Override
                                  public void run() {
                                      chatMessageBut.setImageDrawable(context.getResources().getDrawable(R.drawable.chat_message_off));
                                      isChat = false;
                                  }
                            });

                        }

                        @Override
                        public void onError(int error, String errorMsg) {
                            EMLog.e(TAG,errorMsg);
                        }
                    });
                } else {
                    EMClient.getInstance().chatroomManager().unmuteAllMembers(
                            EmLearnHelper.getInstance().getConferenceSession().getChatId(), new EMValueCallBack<EMChatRoom>() {
                        @Override
                        public void onSuccess(EMChatRoom value) {
                            EMLog.i(TAG,"un mute all");
                            ((Activity)context).runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    chatMessageBut.setImageDrawable(context.getResources().getDrawable(R.drawable.chat_message_on));
                                    isChat = true;
                                }
                            });
                        }

                        @Override
                        public void onError(int error, String errorMsg) {
                            EMLog.e(TAG,errorMsg);
                        }
                    });

                }
                isChatMessage = !isChatMessage;
            }
        });
        if(EmLearnHelper.getInstance().getConferenceSession().getRoleType().equals(Constant.ROLE_STUDENT)){
            chatMessageBut.setVisibility(View.GONE);
        }
    }

    public String item[] = {"你好!", "我正忙着呢,等等", "有啥事吗？", "有时间聊聊吗", "再见！"};
    private void initpop() {
        mess_lv = (ListView) findViewById(R.id.mess_lv);
        adapter = new DataAdapter(this.getContext(), item);
        mess_lv.setAdapter(adapter);
    }

    private View.OnKeyListener onKeyListener = new View.OnKeyListener() {

        @Override
        public boolean onKey(View v, int keyCode, KeyEvent event) {
            if(!isChat){
                Toast.makeText(context, "已禁言", Toast.LENGTH_SHORT).show();
                return false;
            }
            if (keyCode == KeyEvent.KEYCODE_ENTER
                    && event.getAction() == KeyEvent.ACTION_DOWN) {

                String mesg = mEditTextContent.getText().toString();
                String from  = EmLearnHelper.getInstance().getConferenceSession().getUserName();
                final EMMessage message = EMMessage.createTxtSendMessage(mesg,from);
                if(message != null) {
                    message.setChatType(EMMessage.ChatType.ChatRoom);
                    message.setStatus(EMMessage.Status.INPROGRESS);
                    message.setTo(EmLearnHelper.getInstance().getConferenceSession().getChatId());
                    message.setDirection(EMMessage.Direct.SEND);
                    message.setAttribute("nickName",EmLearnHelper.getInstance().getConferenceSession().getNickName());
                    EMClient.getInstance().chatManager().sendMessage(message);
                    tblist.add(message);
                    mMessageHandler.sendEmptyMessage(SEND_OK);
//                    tbAdapter.notifyDataSetChanged();
//                    tbAdapter.notifyItemInserted(tblist
//                            .size() - 1);
//                    myList.smoothScrollToPosition(tbAdapter.getItemCount() - 1);
//                    pullList.refreshComplete();
                }
                mEditTextContent.setText("");
                KeyBoardUtils.hideKeyBoard(context,
                        mEditTextContent);
//                sendMessage();
                return true;
            }
            return false;
        }
    };
    private void controlKeyboardLayout(final View root, final View needToScrollView) {
        root.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {

            private Rect r = new Rect();

            @Override
            public void onGlobalLayout() {
                //获取当前界面可视部分
//                RecyclerViewChatActivity.this.getWindow().getDecorView().getWindowVisibleDisplayFrame(r);
                //获取屏幕的高度
                int screenHeight = ChatView.this.getLayoutParams().height;
                //此处就是用来获取键盘的高度的， 在键盘没有弹出的时候 此高度为0 键盘弹出的时候为一个正数
                int heightDifference = screenHeight - r.bottom;
                int recyclerHeight = 0;
                if (wcLinearLayoutManger != null) {
                    recyclerHeight = wcLinearLayoutManger.getRecyclerHeight();
                }
                if (heightDifference == 0 || heightDifference == bottomStatusHeight) {
                    needToScrollView.scrollTo(0, 0);
                } else {
                    if (heightDifference < recyclerHeight) {
                        int contentHeight = wcLinearLayoutManger == null ? 0 : wcLinearLayoutManger.getHeight();
                        if (recyclerHeight < contentHeight) {
                            listSlideHeight = heightDifference - (contentHeight - recyclerHeight);
                            needToScrollView.scrollTo(0, listSlideHeight);
                        } else {
                            listSlideHeight = heightDifference;
                            needToScrollView.scrollTo(0, listSlideHeight);
                        }
                    } else {
                        listSlideHeight = 0;
                    }
                }
            }
        });
    }
    private WrapContentLinearLayoutManager wcLinearLayoutManger;
    protected void init() {
        tbAdapter = new ChatListViewAdapter(context, tblist);
        wcLinearLayoutManger = new WrapContentLinearLayoutManager(context, LinearLayoutManager.VERTICAL, false);
//        myList.setLayoutManager(wcLinearLayoutManger);
//        myList.setItemAnimator(new SlideInOutBottomItemAnimator(myList));
        myList.setAdapter(tbAdapter);
        tbAdapter.isPicRefresh = true;
        tbAdapter.notifyDataSetChanged();
        tbAdapter.setSendErrorListener(new ChatListViewAdapter.SendErrorListener() {

            @Override
            public void onClick(int position) {
                // TODO Auto-generated method stub
                EMMessage tbub = tblist.get(position);
                if (tbub.getType() == EMMessage.Type.VOICE) {
//                    sendVoice(tbub.getUserVoiceTime(), tbub.getUserVoicePath());
                    tblist.remove(position);
                } else if (tbub.getType() == EMMessage.Type.IMAGE) {
//                    sendImage(tbub.getImageLocal());
                    tblist.remove(position);
                }
            }

        });
//        tbAdapter.setVoiceIsReadListener(new ChatListViewAdapter.VoiceIsRead() {
//
//            @Override
//            public void voiceOnClick(int position) {
//                // TODO Auto-generated method stub
//                for (int i = 0; i < tbAdapter.unReadPosition.size(); i++) {
//                    if (tbAdapter.unReadPosition.get(i).equals(position + "")) {
//                        tbAdapter.unReadPosition.remove(i);
//                        break;
//                    }
//                }
//            }
//
//        });
//        voiceBtn.setAudioFinishRecorderListener(new AudioRecordButton.AudioFinishRecorderListener() {
//
//            @Override
//            public void onFinished(float seconds, String filePath) {
//                // TODO Auto-generated method stub
////                sendVoice(seconds, filePath);
//            }
//
//            @Override
//            public void onStart() {
//                // TODO Auto-generated method stub
//                tbAdapter.stopPlayVoice();
//            }
//        });
        myList.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                switch (scrollState) {
//                    case RecyclerView.SCROLL_STATE_IDLE:
//                        tbAdapter.handler.removeCallbacksAndMessages(null);
//                        tbAdapter.setIsGif(true);
//                        tbAdapter.isPicRefresh = false;
//                        tbAdapter.notifyDataSetChanged();
//                        break;
//                    case RecyclerView.SCROLL_STATE_DRAGGING:
//                        tbAdapter.handler.removeCallbacksAndMessages(null);
//                        tbAdapter.setIsGif(false);
//                        tbAdapter.isPicRefresh = true;
////                        reset();
//                        KeyBoardUtils.hideKeyBoard(context,
//                                mEditTextContent);
//                        break;
                    default:
                        pullList.refreshComplete();
                        break;
                }
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
            }
        });
//        myList.setOnScrollListener(new RecyclerView.OnScrollListener() {
//
//            @Override
//            public void onScrollStateChanged(RecyclerView view, int scrollState) {
//                // TODO Auto-generated method stub
//                switch (scrollState) {
//                    case RecyclerView.SCROLL_STATE_IDLE:
//                        tbAdapter.handler.removeCallbacksAndMessages(null);
//                        tbAdapter.setIsGif(true);
//                        tbAdapter.isPicRefresh = false;
//                        tbAdapter.notifyDataSetChanged();
//                        break;
//                    case RecyclerView.SCROLL_STATE_DRAGGING:
//                        tbAdapter.handler.removeCallbacksAndMessages(null);
//                        tbAdapter.setIsGif(false);
//                        tbAdapter.isPicRefresh = true;
////                        reset();
//                        KeyBoardUtils.hideKeyBoard(context,
//                                mEditTextContent);
//                        break;
//                    default:
//                        break;
//                }
//            }
//
//            @Override
//            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
//                super.onScrolled(recyclerView, dx, dy);
//            }
//        });
        controlKeyboardLayout(activityRootView, pullList);

        mEditTextContent.setOnKeyListener(onKeyListener);
        PullToRefreshLayout.pulltorefreshNotifier pullNotifier = new PullToRefreshLayout.pulltorefreshNotifier() {
            @Override
            public void onPull() {
                // TODO Auto-generated method stub
//                downLoad();
            }
        };
        pullList.setpulltorefreshNotifier(pullNotifier);

        send_emoji_icon.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                // TODO Auto-generated method stub
                String mesg = mEditTextContent.getText().toString();
                String from  = EmLearnHelper.getInstance().getConferenceSession().getNickName();
                final EMMessage message = EMMessage.createTxtSendMessage(mesg,from);
                if(message != null) {
                    message.setChatType(EMMessage.ChatType.ChatRoom);
                    message.setStatus(EMMessage.Status.INPROGRESS);
                    message.setTo(EmLearnHelper.getInstance().getConferenceSession().getChatId());
                    message.setAttribute("nickName",EmLearnHelper.getInstance().getConferenceSession().getNickName());
                    EMClient.getInstance().chatManager().sendMessage(message);
                }
//                sendMessage();
            }

        });

        // 表情list
        reslist = getExpressionRes(40);
        // 初始化表情viewpager
        List<View> views = new ArrayList<View>();
        View gv1 = getGridChildView(1);
        View gv2 = getGridChildView(2);
        views.add(gv1);
        views.add(gv2);
        expressionViewpager.setAdapter(new ExpressionPagerAdapter(views));

        mEditTextContent.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                // TODO Auto-generated method stub
                emoji_group.setVisibility(View.GONE);
                tbbv.setVisibility(View.GONE);
                mess_lv.setVisibility(View.GONE);
//                emoji.setBackgroundResource(R.mipmap.emoji);
//                mess_iv.setBackgroundResource(R.mipmap.tb_more);
//                voiceIv.setBackgroundResource(R.mipmap.voice_btn_normal);
            }

        });

        mess_lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
                                    long arg3) {
                // TODO Auto-generated method stub
                mEditTextContent.setText(item[arg2]);
//                sendMessage();
            }

        });
//        controlKeyboardLayout(activityRootView, pullList);
        bottomStatusHeight = ScreenUtil.getNavigationBarHeight(context);
        //加载本地聊天记录
//        page = (int) mChatDbManager.getPages(number);
    }

    /**
     * 获取表情的gridview的子view
     *
     * @param i
     * @return
     */
    private View getGridChildView(int i) {
        View view = View.inflate(context, R.layout.view_chat_expression_gridview, null);
        ExpandGridView gv = (ExpandGridView) view.findViewById(R.id.gridview);
        List<String> list = new ArrayList<String>();
        if (i == 1) {
            List<String> list1 = reslist.subList(0, 20);
            list.addAll(list1);
        } else if (i == 2) {
            list.addAll(reslist.subList(20, reslist.size()));
        }
        list.add("delete_expression");
        final ExpressionAdapter expressionAdapter = new ExpressionAdapter(context,
                1, list);
        gv.setAdapter(expressionAdapter);
        gv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
                String filename = expressionAdapter.getItem(position);
                try {
                    // 文字输入框可见时，才可输入表情
                    // 按住说话可见，不让输入表情
                    if (filename != "delete_expression") { // 不是删除键，显示表情
                        // 这里用的反射，所以混淆的时候不要混淆SmileUtils这个类
                        @SuppressWarnings("rawtypes")
                        Class clz = Class
                                .forName("com.maxi.chatdemo.utils.SmileUtils");
                        Field field = clz.getField(filename);
                        String oriContent = mEditTextContent.getText()
                                .toString();
                        int index = Math.max(
                                mEditTextContent.getSelectionStart(), 0);
                        StringBuilder sBuilder = new StringBuilder(oriContent);
                        Spannable insertEmotion = SmileUtils.getSmiledText(
                                context,
                                (String) field.get(null));
                        sBuilder.insert(index, insertEmotion);
                        mEditTextContent.setText(sBuilder.toString());
                        mEditTextContent.setSelection(index
                                + insertEmotion.length());
                    } else { // 删除文字或者表情
                        if (!TextUtils.isEmpty(mEditTextContent.getText())) {

                            int selectionStart = mEditTextContent
                                    .getSelectionStart();// 获取光标的位置
                            if (selectionStart > 0) {
                                String body = mEditTextContent.getText()
                                        .toString();
                                String tempStr = body.substring(0,
                                        selectionStart);
                                int i = tempStr.lastIndexOf("[");// 获取最后一个表情的位置
                                if (i != -1) {
                                    CharSequence cs = tempStr.substring(i,
                                            selectionStart);
                                    if (SmileUtils.containsKey(cs.toString()))
                                        mEditTextContent.getEditableText()
                                                .delete(i, selectionStart);
                                    else
                                        mEditTextContent.getEditableText()
                                                .delete(selectionStart - 1,
                                                        selectionStart);
                                } else {
                                    mEditTextContent.getEditableText().delete(
                                            selectionStart - 1, selectionStart);
                                }
                            }
                        }

                    }
                } catch (Exception e) {
                }

            }
        });
        return view;
    }
    public List<String> getExpressionRes(int getSum) {
        List<String> reslist = new ArrayList<String>();
        for (int x = 1; x <= getSum; x++) {
            String filename = "f" + x;
            reslist.add(filename);
        }
        return reslist;

    }

    /**
     * 销毁时，父级调用
     */
    public void destory(){
        if(mEMMessageListener != null){
//            记得在不需要的时候移除listener，如在activity的onDestroy()时
            EMClient.getInstance().chatManager().removeMessageListener(mEMMessageListener);
        }
    }
}
