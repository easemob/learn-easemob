package com.t.emlearn.ui.view;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import com.hyphenate.chat.EMClient;
import com.t.emlearn.R;
import com.t.emlearn.ui.model.UserInfo;

import java.util.LinkedHashMap;

public class OperListViewAdapter extends BaseAdapter {
    private final String TAG = this.getClass().getSimpleName();
    private Context context;

    private LinkedHashMap<String,UserInfo> operMap;

    public OperListViewAdapter(Context context,LinkedHashMap<String,UserInfo> operMap) {
		super();
		this.context = context;
		this.operMap = operMap;
	}

    @Override
    public int getCount() {
        return this.operMap.size();
    }

    @Override
    public Object getItem(int position) {
        return this.operMap.values().toArray()[position];
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
		if (convertView == null) {
			holder = new ViewHolder();
			convertView = LayoutInflater.from(context)
					.inflate(R.layout.view_oper_list_item, null);
			holder.tvName = (TextView) convertView
					.findViewById(R.id.tv_name);
            holder.imgWhiteBorad = (ImageView) convertView
                    .findViewById(R.id.img_whiteborad);

            holder.imgAudio = (ImageView) convertView
                    .findViewById(R.id.img_audio);
            holder.imgVideo = (ImageView) convertView
                    .findViewById(R.id.img_video);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}

		try {
            UserInfo user = (UserInfo)getItem(position);
            holder.tvName.setText(user.nickname);
            if (user.IsWhiteborad) {
                holder.imgWhiteBorad.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_white_on));
            } else {
                holder.imgWhiteBorad.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_white_off));
            }

            if (user.IsAudio) {
                holder.imgAudio.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_audio_on));
            } else {
                holder.imgAudio.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_audio_off));
            }
            if (user.IsVideo) {
                holder.imgVideo.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_video_on));
            } else {
                holder.imgVideo.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_video_off));
            }

            holder.imgWhiteBorad.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "holder.imgWhiteBorad.setOnClickListener:" + position);
                    if (user.IsWhiteborad) {
                        ((Activity)context).runOnUiThread(new Runnable() {
                              @Override
                              public void run() {
                                  holder.imgWhiteBorad.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_white_off));
                              }
                          });

                    } else {
                        ((Activity)context).runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                holder.imgWhiteBorad.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_white_on));
                            }
                        });

                    }
                    user.IsWhiteborad = !user.IsWhiteborad;
                }
            });

            holder.imgAudio.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "holder.imgAudio.setOnClickListener:" + position);
                    if(user.IsAudio){
                        EMClient.getInstance().conferenceManager().muteMember(user.key);
                        ((Activity)context).runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                holder.imgAudio.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_audio_off));
                            }
                        });

                    }else{
                        EMClient.getInstance().conferenceManager().unmuteMember(user.key);
                        ((Activity)context).runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                holder.imgAudio.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_audio_on));
                            }
                        });

                    }
                    user.IsAudio = !user.IsAudio;

                }
            });
            holder.imgVideo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d(TAG, "holder.imgVideo.setOnClickListener:" + position);
                    if (user.IsVideo) {
                        holder.imgVideo.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_video_off));
                    } else {
                        holder.imgVideo.setImageDrawable(context.getResources().getDrawable(R.drawable.oper_video_on));
                    }
                    user.IsVideo = !user.IsVideo;

                }
            });
        }catch (Exception e){
		    e.printStackTrace();
        }

		return convertView;
    }
    class ViewHolder {

		TextView tvName;
		ImageView imgWhiteBorad;
        ImageView imgChat;
        ImageView imgAudio;
        ImageView imgVideo;
	}
}
