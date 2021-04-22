package com.t.emlearn.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;

import android.widget.LinearLayout;

import android.widget.ListView;
import com.t.emlearn.R;
import com.t.emlearn.ui.BaseMainActivity;


public class OperListView extends LinearLayout {
    private final String TAG = this.getClass().getSimpleName();

    private Context context;
    private OperListViewAdapter operListViewAdapter;

    public OperListView(Context context) {
        this(context, null);
    }

    public OperListView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public OperListView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;

        LayoutInflater.from(context).inflate(R.layout.view_oper_list, this);

        ListView operList = (ListView) findViewById(R.id.oper_list);

        operListViewAdapter = new OperListViewAdapter(context, BaseMainActivity.userMap);
        operList.setAdapter(operListViewAdapter);

        operListViewAdapter.notifyDataSetChanged();

        init();
    }

    private void init() {

    }

    public OperListViewAdapter getOperListViewAdapter(){
        return operListViewAdapter;
    }
}
