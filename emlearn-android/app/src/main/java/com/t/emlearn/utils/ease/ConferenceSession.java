package com.t.emlearn.utils.ease;


import android.os.Parcel;
import android.os.Parcelable;
import com.hyphenate.chat.EMConference;
import com.hyphenate.chat.EMConferenceManager;

import java.util.ArrayList;
import java.util.List;

public class ConferenceSession implements Parcelable {
    private String userName;
    private String userId;
    private String nickName;
    private String confrId;
    private String roomName;
    private String confrPwd;
    private String confrType;
    private String chatId;
    private String roleType;
    private String accessToken;
    private String sysToken;
    private EMConference mConferenceParam;
    private List<ConferenceMemberInfo> memberInfoList = null;
    private EMConferenceManager.EMConferenceRole role;

    public ConferenceSession(){}

    private ConferenceSession(Parcel in) {
        userName = in.readString();
        memberInfoList = in.readArrayList(ArrayList.class.getClassLoader());
        confrId = in.readString();
        confrPwd = in.readString();
    }

    public static final Creator<ConferenceMemberInfo> CREATOR = new Creator<ConferenceMemberInfo>() {
        @Override
        public ConferenceMemberInfo createFromParcel(Parcel in) {
            return new ConferenceMemberInfo(in);
        }

        @Override
        public ConferenceMemberInfo[] newArray(int size) {
            return new ConferenceMemberInfo[size];
        }
    };

    public EMConference getConference() {
        return mConferenceParam;
    }

    public void setChatId(String chatId){
        this.chatId = chatId;
    }
    public String getChatId(){
        return this.chatId;
    }

    public void setRoomName(String roomName){
        this.roomName = roomName;
    }
    public String getRoomName(){
        return this.roomName;
    }

    public void setConference(EMConference streamParam) {
        mConferenceParam = streamParam;
    }


    public void setRoleType(String roleType){
        this.roleType = roleType;
    }
    public String getRoleType(){
        return this.roleType;
    }

    public void setAccessToken(String accessToken){
        this.accessToken = accessToken;
    }
    public String getAccessToken(){
        return this.accessToken;
    }

    public void setSysToken(String sysToken){
        this.sysToken = sysToken;
    }
    public String getSysToken(){
        return this.sysToken;
    }
    public String getUserName() {
        return userName;
    }

    public String getUserId(){
        return this.userId;
    }
    public void setUserId(String userId){
        this.userId = userId;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setConfrType(String confrType){
        this.confrType = confrType;
    }
    public String getConfrType(){
        return this.confrType;
    }
    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getNickName(){
        return this.nickName;
    }
    public List<ConferenceMemberInfo> getConferenceProfiles() {
        return memberInfoList;
    }

    public ConferenceMemberInfo getConferenceMemberInfo(String userId){
        if (userId == null || memberInfoList == null || memberInfoList.isEmpty()) {
            return null;
        }
        for (ConferenceMemberInfo userProfile : memberInfoList){
            if (userProfile.getUserId().equals(userId)){
                return userProfile;
            }
        }
        return null;
    }

    public ConferenceMemberInfo getConferenceMemberByStreamId(String streamId){
        if (streamId == null || memberInfoList == null || memberInfoList.isEmpty()) {
            return null;
        }
        for (ConferenceMemberInfo userProfile : memberInfoList){
            if (userProfile.getStreamId().equals(streamId)){
                return userProfile;
            }
        }
        return null;
    }

    public void setConferenceProfiles(List<ConferenceMemberInfo> callUserProfiles) {
        memberInfoList = callUserProfiles;
    }

    public String getConfrId() {
        return confrId;
    }

    public void setConfrId(String confrId) {
        this.confrId = confrId;
    }

    public String getConfrPwd() {
        return confrPwd;
    }

    public void setConfrPwd(String confrPwd) {
        this.confrPwd = confrPwd;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(userName);
        dest.writeString(confrId);
        dest.writeString(confrPwd);
    }
}
