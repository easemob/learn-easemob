package com.t.emlearn.ui.view;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import com.t.emlearn.R;
import com.t.emlearn.utils.X5WebView;
import com.tencent.smtt.export.external.interfaces.ConsoleMessage;
import com.tencent.smtt.export.external.interfaces.PermissionRequest;
import com.tencent.smtt.sdk.ValueCallback;
import com.tencent.smtt.sdk.WebChromeClient;
import com.tencent.smtt.sdk.WebSettings;
import com.tencent.smtt.sdk.WebView;
import com.tencent.smtt.sdk.WebViewClient;
/**
 * 白板
 */
public class WhiteBoardView extends RelativeLayout {
    private Context context;
    private X5WebView mWebView;

    public ValueCallback<Uri[]> mUploadMessage;
    public final static int FIREHOUSE_RESULT_CODE = 1;

    public WhiteBoardView(Context context) {
        this(context, null);
    }

    public WhiteBoardView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public WhiteBoardView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        LayoutInflater.from(context).inflate(R.layout.view_whiteboard, this);

        init();
    }


    private void init() {
        mWebView = (X5WebView)findViewById(R.id.whiteboard_webview);



        WebSettings webSetting = mWebView.getSettings();
        webSetting.setJavaScriptEnabled(true);
        webSetting.setAppCacheEnabled(false);
        webSetting.setDomStorageEnabled(true);
        webSetting.setCacheMode(WebSettings.LOAD_NO_CACHE);
        // 设置可以支持缩放
        webSetting.setSupportZoom(false);
        // 设置出现缩放工具
        webSetting.setBuiltInZoomControls(true);
        //扩大比例的缩放
        webSetting.setUseWideViewPort(true);
        //自适应屏幕
        webSetting.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);

        webSetting.setJavaScriptCanOpenWindowsAutomatically(true);
        webSetting.setAllowFileAccess(true);

        webSetting.setSupportMultipleWindows(true);

        webSetting.setGeolocationEnabled(true);

        webSetting.setCacheMode(WebSettings.LOAD_NO_CACHE);


        mWebView.setWebViewClient(new WebViewClient(){
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                view.loadUrl(url);
                return true;
            }
        });




        mWebView.setWebChromeClient(new WebChromeClient(){
            @Override
            public void onPermissionRequest(final PermissionRequest request) {
                ((Activity)context).runOnUiThread(new Runnable(){
                    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
                    @Override
                    public void run() {
                        request.grant(request.getResources());
                    }
                });
            }
            @Override
            public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                Log.d("MyApplication", consoleMessage.message() + " -- From line "
                        + consoleMessage.lineNumber() + " of "
                        + consoleMessage.sourceId());
                return true;
            }

            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> uploadMsg, FileChooserParams fileChooserParams) {
                WhiteBoardView.this.openFileChooser(uploadMsg, fileChooserParams);
                return true;
            }
        });
    }

    private void openFileChooser(ValueCallback<Uri[]> uploadMsg, WebChromeClient.FileChooserParams fileChooserParams) {
        mUploadMessage = uploadMsg;
//        Intent intent = fileChooserParams.createIntent();
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("image/*");
        ((Activity)context).startActivityForResult(intent, FIREHOUSE_RESULT_CODE);
    }

    public X5WebView getWebView(){
        return this.mWebView;
    }

    public void loadUrl(String roomUrl){
        mWebView.loadUrl(roomUrl);
    }
}
