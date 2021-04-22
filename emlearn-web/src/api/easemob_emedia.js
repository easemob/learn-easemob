import emedia from 'easemob-emedia';

export const joinConference = (roomName,roomPassword,role) => {
    var params = {
        roomName:roomName, // string 房间名称 必需
        password:roomPassword, // string 房间密码 必需
        role:role  // number 进入会议的角色 1: 观众  3:主播 必需
    }
    try {
        const user_room =  emedia.mgr.joinRoom(params);
        const confrId = user_room.confrId;
        const password = roomName;
        const confr =  emedia.mgr.selectConfr(confrId, password);

        var constaints = { // 发布音频流的配置参数, Object 必需。 video或audio属性 至少存在一个
            audio: true, // 是否发布音频
            video: true  // 是否发布视频
        }
         emedia.mgr.publish(constaints);
    }catch(error){
        console.log("err:",error)
        for(var k in error){
          alert('2key:'+k+" val:"+error[k])
        }
    }
}

const BASE_URL = "https://a1.easemob.com"
const BASE_APP_KEY="1108200509113038#chatapp"
export const initEmedia= (userName,accessToken,onStreamMethod) => {
    emedia.config({
        restPrefix: BASE_URL,
        appkey:BASE_APP_KEY,
        consoleLogger: true,
        // useDeployMore:true //开启多集群部署
    });
    emedia.mgr.setIdentity(BASE_APP_KEY+"_"+userName, accessToken)

    emedia.mgr.onStreamAdded = function (member, stream) {
        console.log('onStreamAdded >>>', member, stream);
        onStreamMethod(member,stream)
    //     if(!stream.located()) {
    //       var option = {
    //           member: member, 
    //           stream: stream, 
    //           subVideo: true,
    //           subAudio: true,
    //           videoTag: document.getElementById('other')
    //       }
    //       emedia.mgr.subscribe(option.member, option.stream, option.subVideo, option.subAudio, option.videoTag)    
    //   }else{
    //     var videoTag = document.getElementById('self');
    //     emedia.mgr.streamBindVideo(stream, videoTag);
    //   }
    // let username = member.name.split("_")[1]
    //         that.stream_list[username] = stream;
    };
    emedia.mgr.onStreamRemoved = function (member, stream) {
        console.log('onStreamRemoved',member,stream);

    };
    emedia.mgr.onMemberJoined = function (member) {
          console.log('onMemberJoined',member);
    };

    emedia.mgr.onMemberLeave = function (member, reason, failed) {
        console.log('onMemberLeave', member, reason, failed);
    };

    emedia.mgr.onConferenceExit = function (reason, failed) {
        console.log('onConferenceExit', reason, failed);
        
    };
    emedia.mgr.onConfrAttrsUpdated = function(confr_attrs){ 
        console.log('onConfrAttrsUpdated', confr_attrs);
    };

    emedia.mgr.onRoleChanged = function (role) {
    console.log('onRoleChanged', role);
    };

    // 主持人变更回调
    emedia.mgr.onAdminChanged = function(admin) {
    console.log('onAdminChanged', admin);
    }

    // 视频流达到最大数失败回调
    emedia.mgr.onPubVideoTooMuch = async () => {
    console.log('已达到最大视频数，只能开启音频');
    }
    // 共享桌面最大数发布 回调
    emedia.mgr.onPubDesktopTooMuch = () => {
    console.log('共享桌面数已经达到最大');
    }

    // 主持人 收到上麦申请回调
    // applicat 申请者信息 {memberId, nickName}
    // 只有管理员会收到这个回调
    
    emedia.mgr.onRequestToTalker = function(applicat, agreeCallback, refuseCallback) {
        console.log('onRequestToTalker',applicat,agreeCallback,refuseCallback);
    }

    // 观众收到 上麦申请的回复 result 0: 同意 1: 拒绝
    emedia.mgr.onRequestToTalkerReply = function(result) {
        if(result == 1){
        console.log('管理员拒绝了你的上麦申请');
        }
    }
    // 主播收到 申请主持人的回复 result 0: 同意 1: 拒绝
    emedia.mgr.onRequestToAdminReply = function(result) {
        if(result == 1){
            console.log('管理员拒绝了你的主持人申请')
        }
    }

    // 收到主播的主持人申请, applicat 申请者信息 {memberId, nickName}
    emedia.mgr.onRequestToAdmin = function(applicat, agreeCallback, refuseCallback) {
    console.log('onRequestToAdmin',applicat,agreeCallback,refuseCallback);
    }

    // 某人被管理员静音或取消静音的回调
    emedia.mgr.onMuted = () => { 
        console.log('你被管理员禁言了'); 
    }
    emedia.mgr.onUnmuted = () => { 
        console.log('你被管理员取消了禁言');
    }

    // 全体静音或取消全体静音
    emedia.mgr.onMuteAll = () => { 
        console.log('管理员启用了全体禁言');
    }
    emedia.mgr.onUnMuteAll = () => { 
        console.log('管理员取消了全体禁言');
    }
}

export const exitConference = ()=>{
    emedia.mgr.exitConference();
}

export const toggleVideo = (isOff,stream) => {
    if(isOff){//关闭摄像头
         emedia.mgr.pauseVideo(stream);
    }else{//开启摄像头
         emedia.mgr.resumeVideo(stream);
    }
}

export const toggleAudio = (isOff,stream) => {
    if(isOff){//关闭摄像头
         emedia.mgr.pauseAudio(stream);
    }else{//开启摄像头
         emedia.mgr.resumeAudio(stream);
    }
}