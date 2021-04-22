package com.t.emlearn.utils;

import android.content.Context;
import android.util.DisplayMetrics;
import android.view.WindowManager;

public class SysUtil {

    /**
     * 获取分辨率的宽度
     */
    public static int getW(Context context) {
        try {
            DisplayMetrics dm = new DisplayMetrics();
            WindowManager windowMgr = (WindowManager) context
                    .getApplicationContext().getSystemService(
                            Context.WINDOW_SERVICE);
            windowMgr.getDefaultDisplay().getMetrics(dm);
            return dm.widthPixels;
        } catch (Exception e) {
            return 1080;
        }
    }

    /**
     * 获取分辨率的高度
     *
     * @param context
     * @return
     */
    public static int getH(Context context) {
        try {
            DisplayMetrics dm = new DisplayMetrics();
            WindowManager windowMgr = (WindowManager) context
                    .getApplicationContext().getSystemService(
                            Context.WINDOW_SERVICE);
            windowMgr.getDefaultDisplay().getMetrics(dm);
            return dm.heightPixels;
        } catch (Exception e) {
            return 1920;
        }
    }


    /**
     * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
     */
    public static int dip2px(Context context, float dpValue) {
        try{
            final float scale = context.getResources().getDisplayMetrics().density;
            return (int) (dpValue * scale + 0.5f);
        }catch (Exception e){
            e.printStackTrace();
            return (int) dpValue;
        }
    }

    /**
     * 根据手机的分辨率从 px(像素) 的单位 转成为 dp
     */
    public static int px2dip(Context context, float pxValue) {
        try{
            final float scale = context.getResources().getDisplayMetrics().density;
            return (int) (pxValue / scale + 0.5f);
        }catch (Exception e){
            e.printStackTrace();
            return (int) pxValue;
        }
    }

}
