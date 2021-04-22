<template>
  <div>
    <header>
        <onLineNetWork/>
        <headerHostName/>
        <com-headerSet @handelClick="handelClickSet" />
    </header>
    <!-- 查看滚动人物 -->
    <section class="viewRolling">
        <div  class="swipe-container">
            <van-swipe :loop="false" :width="swipeItemWidth" :height="swipeItemHeight" ref="VanSwipe">
            <template v-for="(val,index) in stream_list">
                <van-swipe-item class="swipe-item-container"  v-if="!val.seat"  :key="index">
                        <!-- 显示视频内容 -->
                        <section v-show="val.setVideo" class="teacher-dragIcon">
                            <video :id="val.videoID"></video>
                            <!-- 只有老师才显示拖放图标 -->
                            <template v-if="val.roleType == 'teacher'" >
                                <span class="dragIcon" style="position:absolute;right:10px;top:10px;" v-if=" userType == 'students' ? false : true ">
                                    <van-image style="width:24px;height:24px;" :src="dragIconUrl" @click="teacherDragIconFunc(val)"></van-image>
                                </span>
                            </template>
                        </section>
                        <!-- 显示占位图片 -->
                        <section v-show="!val.setVideo">
                            <van-image style="width:150px;height:150px;" :src="swipeItemUrl"></van-image>
                        </section>
                        <!-- 底部文字内容 -->
                        <div class="text-container">
                            <p style="font-size:12px;color:#fff;">
                                {{splitNameFunc(val)}}
                            </p>
                            <!-- 如果角色为学生，老师的图标不显示,学生不可操作老师 -->
                            <p class="icon-container"  v-show="audioAndVideoIconFunc(val)">
                                <!-- 音频 -->
                                <van-image class="iconPoniter" style="width:15px;height:15px;" 
                                    :src="audioSpeakIconFunc(val)" @click="swipeAudioFunc(val,index)"></van-image>
                                <!-- 视频 -->
                                <van-image class="iconPoniter" style="width:15px;height:15px;margin-left:10px;" 
                                    :src="val.setVideo?TvideoUrl:closeVideoUrl" @click="swipeVideoFunc(val,index)"></van-image>
                            </p>
                        </div>
                </van-swipe-item>
            </template>

            </van-swipe>

        <div class="arrow-left" v-show="toggleLeft">
            <van-image class="arrow-click" :src="arrowLeftUrl" @click="swipePropFunc"></van-image>
        </div>
            
        <div class="arrow-right" v-show="toggleRight">
            <van-image class="arrow-click" style="" :src="arrowUrl" @click="swipeNextFunc"></van-image>
        </div>
            
        </div>
    </section>
    <main>
        <div class="handle-whiteboard">
                <!-- 互动工具面板 -->
                <div class="whiteboard">
                    <div class="iframeContent">
                        <!-- 老师端禁止学生操作白板，学生端白板为隐藏状态 -->
                        <iframe :src="getWhiteboardUrl"></iframe>
                    </div>
                </div>
                <!-- 右侧浮层 -->
                <div class="floating">
                    <p v-if=" userType == 'students' ? false : true ">
                        <van-image style="width:38px;height:38px;" :src="membersIcon" @click="membersIconFunc"></van-image>
                    </p>
                    <p><van-image style="width:38px;height:38px;" :src="infoIcon" @click="infoIconFunc"></van-image></p>
                </div>
                <!-- 自定义工具栏 -->
                <com-tool @handleClick="handleToolsClick" v-if=" userType == 'students' ? false : true " 
                    style="position:absolute;bottom:45px;right:0px;" />
        </div>
       
        <com-chat ref="myChat" :show="chatStatusOverlay"  :data="message_list"  @send="sendChatFunc" @close="closeChatFunc" style="right:0;top: 0;"/>
        <com-stuList 
            style="right:0;top: 0;"
            :show="stuListStatusOverlay" 
            :data="stream_list" 
            @set-whiteBorad ="setWhiteBoradFunc"
            @set-message ="setMessageFunc"
            @set-audio ="setAudioFunc"
            @set-vidio="setVidioFunc"
            @close="closeStuListFunc"/> 
    </main>
  </div>
</template>

<script>
import headerSet from '../headerSetting/index'
import time from '../timeCounter/time'
import tools from '../customTools/tools'
import chat from '../chat/index'
import headerHostName from '../headerHostName/index'
import onLineNetWork from '../headerNetWork/index'
import studentsList from '../studentsList/index'
import {mapGetters,mapActions} from 'vuex'
import { Toast as VanToast} from 'vant';
import whiteBoards from 'easemob-whiteboards' //引入环信白板sdk
import {GetConfrOper,SetChatroomMute,SetWhiteStatus,SetRole} from '../../api/conference'
import {GetCur} from '../../api/user'
import WebIM from '../../config/WebIM'

export default {
    components:{
        'com-tool':tools,'com-time':time,'com-headerSet':headerSet,'com-chat':chat,
        'com-stuList':studentsList,onLineNetWork,headerHostName
    },
    data(){
        return {
            toggleLeft:false,//左测切换按钮状态
            toggleRight:false,//右测切换按钮状态
            swipeItemWidth:204,//每个视频窗口的宽度
            swipeItemHeight:116,//每个视频窗口的高度
            whiteBoardStatus:JSON.parse(window.localStorage.getItem('allStopWhite')),//白板是否允许操作权限
            swipeItemUrl:require("@/assets/u46.png"),//默认占位图片
            stream_list:[
                /**
                    * 
                    * 白板 setWhiteboard true 为禁止操作 false 为允许操作
                    * 消息 setMessage  true 为禁止操作 false 为允许操作
                    * 语音 setAudio  true 为禁止操作 false 为允许操作
                    * 视频 setVideo true 为禁止操作 false 为允许操作
                    * 是否说话 isSpeak true 讲话 false 未讲话
                */
                // { name:"stu1",id:1,setWhiteboard:true,setMessage:true,setAudio:true,setVideo:true},
                // { name:"stu2",id:2,setWhiteboard:true,setMessage:true,setAudio:true,setVideo:true},
                // { name:"stu3",id:3,setWhiteboard:true,setMessage:true,setAudio:true,setVideo:true},
                // 默认数组第0位为老师默认占位
               {
                    name:'老师',
                    seat:false,
                    setAudio:true,
                    isSpeak:false,
                    setVideo:false,
                    setWhiteboard:false,
                    setMessage:false,
                    member:'',
                    stream:'',
                    roleType:'teacher-seat',//老师占位标识
                    videoID:"list-",
                    // joinTime:1606716000222
                    joinTime:new Date().getTime()
               },
            //     {
            //         name:'学生1',
            //         roleType:'students',
            //         joinTime:1606716011006
            //    },
            //    {
            //         name:'学生2',
            //         roleType:'students',
            //         joinTime:1606716021398
            //    },
            //     {
            //         name:'刘鲸鱼老师',
            //         roleType:'teacher',
            //         joinTime:1606716032919,
            //         setAudio:true,
            //         isSpeak:false,
            //         setVideo:true,
            //    },
            //    {
            //         name:'张三',
            //         roleType:'students',
            //         joinTime:1606716039464
            //    },
            ],
            message_list:[],//存储聊天消息的列表
            arrowUrl:require("@/assets/arrow.png"),
            arrowLeftUrl:require("@/assets/arrow-left.png"),

            membersIcon:require("@/assets/u129.png"),
            infoIcon:require("@/assets/u81.png"),
            // 老师音视频
            TvoiceUrl:require("@/assets/micro-is-open-icon.png"),//音频
            TvideoUrl:require("@/assets/video-is-open-icon.png"),//视频
            dragIconUrl:require("@/assets/u89.png"),
            // 学生音视频
            SvoiceUrl:require("@/assets/micro-is-open-icon.png"),//音频
            SvideoUrl:require("@/assets/video-is-open-icon.png"),//视频 
            // 关闭音视频
            closeVoiceUrl:require("@/assets/micro-is-close-icon.png"),//音频
            closeVideoUrl:require("@/assets/video-is-close-icon.png"),//视频
            // 老师/学生说话图标
            speakVoiceUrl:require("@/assets/u976.png"),
           
            hostName:this.$store.state.user.houseName,//房间名称
            houseType:this.$store.state.user.houseType,//房间类型 一对一 小班课
            userType:this.$store.state.user.personType,//用户角色 老师/学生
            userTypeStatus:false,//true为老师 false为学生
            chatStatusOverlay:false,//聊天窗口
            stuListStatusOverlay:false,//学生列表窗口
            storageMessage:[],//存储学生列表里的消息的用户ID
            storageWhiteBorad:[],//存储学生列表里的白板的用户ID
            is_me:"",
            audio_own_stream:'',//保存学生列表点击了哪一行的音频流 老师操作学生的音频流
            saveNickName:"",
            saveStreamListName:''//保存学生列表老师的owner.name ，只有老师才有权限
        }
    },
    created(){
        this.joinConference();//加入会议
        this.init_emedia_callback();//初始化 环信音视频监听回调
        this.userGetMedia();//检测用户电脑设备
    },
    mounted(){
        this.userTypeStatus = this.userType == "students" ? false : true;

        // 获取用户昵称
        GetCur().then(res=>{
            this.saveNickName = res.nickName;
        });

      
    },
    
    methods:{
        ...mapActions([
            'initSmallConferenceFunc',
            'getRoomsMember',// //获取聊天室成员
            'allowOprateAll', // 允许全体成员互动
            'forbiteOprateAll',  // 禁止全体成员互动
            'allowOprate', // 允许单个成员互动
            'forbiteOprate',  // 禁止单个成员互动
            'setChatroomMute', //webIm 将成员禁言
            'removeRoomMute', //webIm 将成员解除禁言
        ]),
        // 检测用户电脑设备
        userGetMedia(){
            if (navigator.mediaDevices.getUserMedia || navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia) {
                //唤醒用户媒体设备, 访问摄像头
                navigator.getUserMedia({video: {width: 480, height: 320}}, this.userMediaSuccess, this.userMediaError);
            } else {
                this.$VanDialog.alert({
                    title: '提示',
                    message: '不支持访问用户媒体设备',
                }).then(() => {});
            }
        },
        userMediaSuccess(stream) {
            console.log(stream);
        },
        userMediaError(error) {
            console.log(`访问用户媒体设备失败${error.name}, ${error.message}`);
            this.$VanDialog.alert({
                title: '提示',
                message: '系统未匹配到您本机的媒体设备',
            }).then(() => {});
        },
        init_emedia_callback(){
            let that = this;
            const {userName,accessToken} = this.$store.state.user;
            const BASE_URL = "https://a1.easemob.com"
            const BASE_APP_KEY="1108200509113038#chatapp"
            const memName = BASE_APP_KEY +'_'+ userName;
            emedia.config({
                restPrefix:BASE_URL, //配置服务器域名、必填 比如: 'https://a1.easemob.com'
                appkey:BASE_APP_KEY, // 从环信后台 获取的appkey、必填
            });
            emedia.mgr.setIdentity(memName, accessToken); //设置memName 、token
            emedia.mgr.onStreamAdded =  function (member, stream) {
                // console.log("媒体流发布者加入" + JSON.stringify(member.name));
                // console.log(member,'member');
                // console.log(stream,'stream');
               
                if(!stream.located()) {
                    if( member.memName.split('.').length > 1){//进来的是老师
                        if(that.stream_list.length > 1){
                            that.stream_list.map((item,index)=>{
                                if(item.roleType == 'teacher-seat'){
                                    item.seat = true;
                                }
                            });
                        };
                        that.stream_list.push({
                                name:stream.ext.nickName,
                                setAudio:true,
                                isSpeak:false,
                                setVideo:true,
                                setWhiteboard:true,
                                setMessage:true,
                                member:member,
                                stream:stream,
                                roleType:member.memName.split('.').length > 1 ? 'teacher' : 'students',
                                videoID:"list-"+ member.name,
                                joinTime:new Date().getTime()
                        });
                        setTimeout(() => {
                            that.stream_list.sort(function (a, b) {
                                if(a.roleType  > b.roleType ){
                                    return -1;
                                }else if(a.joinTime  > b.joinTime ){
                                    return 1;
                                }else{
                                    return 0;
                                }
                            });
                            emedia.mgr.subscribe(member, stream, true, true, document.getElementById("list-"+ member.name));
                        }, 100); 
                        
                    }else{ //进来的是学生
                        that.stream_list.push({
                                name:stream.ext.nickName,
                                setAudio:true,
                                isSpeak:false,
                                setVideo:true,
                                setWhiteboard:true,
                                setMessage:true,
                                member:member,
                                stream:stream,
                                roleType:member.memName.split('.').length > 1 ? 'teacher' : 'students',
                                videoID:"list-"+ member.name,
                                joinTime:new Date().getTime()
                        });
                        setTimeout(() => {
                            that.stream_list.sort(function (a, b) {
                                if(a.roleType  > b.roleType ){
                                    return -1;
                                }else if(a.joinTime  > b.joinTime ){
                                    return 1;
                                }else{
                                    return 0;
                                }
                            });
                            emedia.mgr.subscribe(member, stream, true, true, document.getElementById("list-"+ member.name));
                        }, 100); 
                    }
                }   

                if(that.stream_list.length > 0){
                    that.stream_list.map(item=>{
                        setTimeout(() => {
                            let VideoTag = document.getElementById(item.videoID);
                            if(VideoTag){
                                // 监听音视频的开关
                                emedia.mgr.onMediaChanaged(VideoTag, function (constaints, stream) {
                                    // console.log(constaints,'constaints=========================================')
                                    // console.log(stream,'stream=========================================')
                                });
                                // 监听谁在说话
                                // 函数触发，就证明有人说话 拿 stream_id
                                emedia.mgr.onSoundChanaged(VideoTag,function (meterData, stream) {
                                    // instant: 0.26280892641627845 // instant 大约每50毫秒变化一次， 小于1的浮点数
                                    // slow: 0.06802768487276245 // slow大约是一秒钟内的平均音量，小于1的浮点数
                                    // clip: 0
                                    let { instant } = meterData;
                                    if(instant * 100 > 1){
                                        // 有人讲话
                                        if(stream.id == item.stream.id){
                                            item.isSpeak = true;
                                        }else{
                                            item.isSpeak = false;
                                        }
                                    }else {
                                        // 没人讲话
                                        item.isSpeak = false;
                                    }
                                });
                            }
                        }, 100);
                    });
                }
            }
            //有媒体流移除
            emedia.mgr.onStreamRemoved = function(member, stream) {
                // member：发布流人员的信息、stream：流信息
                emedia.mgr.unsubscribe(stream) // 停止订阅流
                console.log('媒体流发布者退出',member,stream);
                that.on_stream_removed(stream);
            }

            //有人加入会议
            emedia.mgr.onMemberJoin = function (member,confrId) {
                console.log("加入会议=========");
                console.log(member,'member');
                console.log(confrId,'confrId');
                console.log(`${member.nickName || member.name} 加入了会议`);
            }
                
            //有人退出会议
            emedia.mgr.onMemberExited = function (member) {
                console.log("退出会议=========" + JSON.stringify(member.name));   // member: 退出会议成员信息
            } 

            //自己角色变更
            emedia.mgr.onRoleChanged = role => {} // role: 变更后的角色

            //会议退出；自己主动退 或 服务端主动关闭；
            emedia.mgr.onConferenceExit = function (reason, failed) {
                reason = (reason || 0);
                switch (reason){
                    case 0:
                        reason = "正常挂断";
                        break;
                    case 1:
                        reason = "没响应";
                        break;
                    case 2:
                        reason = "服务器拒绝";
                        break;
                    case 3:
                        reason = "对方忙";
                        break;
                    case 4:
                        reason = "失败,可能是网络或服务器拒绝";
                        if(failed === -9527){
                            reason = "失败,网络原因";
                        }
                        if(failed === -500){
                            reason = "Ticket失效";
                        }
                        if(failed === -502){
                            reason = "Ticket过期";
                        }
                        if(failed === -504){
                            reason = "链接已失效";
                        }
                        if(failed === -508){
                            reason = "会议无效";
                        }
                        if(failed === -510){
                            reason = "服务端限制";
                        }
                        break;
                    case 5:
                        reason = "不支持";
                        break;
                    case 10:
                        reason = "其他设备登录";
                        break;
                    case 11:
                        reason = "会议关闭";
                        break;
                }
            }

            //管理员变更
            emedia.mgr.onAdminChanged = admin => {
                console.log("管理员变更: "+ admin)
            } //admin 管理员信息

            //监听弱网状态
            emedia.mgr.onNetworkWeak = streamId => {
                console.log("监听弱网状态: "+ streamId)
            } //streamId 会议中的流 ID

            //监听断网状态
            emedia.mgr.onNetworkDisconnect = streamId => {
                console.log("监听断网状态: "+ streamId)
            } //streamId 会议中的流 ID
            //某人被管理员静音的回调（只他自己收到回调）
            emedia.mgr.onMuted = () => {
                // alert("你被管理员禁言了");
                that.close_audio();// 在收到回调后，需要在程序中执行关闭麦克风的逻辑( await emedia.mgr.pauseAudio(own_stream))
            }
            emedia.mgr.onUnmuted = () => { 
                // alert("你被管理员取消了禁言");
                that.open_audio();// 在收到回调后，需要在程序中执行开启麦克风的逻辑( await emedia.mgr.resumeAudio(own_stream))
            }
            // 全体静音或取消全体静音
            emedia.mgr.onMuteAll = () => { 
                // alert("管理员开启了全体禁言")
            }
            emedia.mgr.onUnMuteAll = () => { 
                // alert("管理员取消了全体禁言")
            }
        },

        on_stream_removed(stream) {
            if(!stream){
                return
            }
            const {stream_list} = this;
            stream_list.map((item, index) => {
                if(item.stream.id == stream.id ){
                    stream_list.splice(index, 1)
                }
            });
        },
        async joinConference(){
            const {confrId,password,nickName,userName} = this.$store.state.user; 
            const {userType} = this; 
            const join_result  = await emedia.mgr.joinUsePassword(confrId, password);
            console.log(join_result ,'===>加入会议  join_result ');
            if(userType == "teacher"){
                SetRole(confrId,7,userName).then(res=>{
                    if(res.code ==1){
                        console.log('已成功设置老师身份为管理员')
                    }
                });
            }
            let constaints = { audio: true,video: true }
            let ext = {
                nickName: nickName,
                roleType:userType
            } // 发布流的扩展信息 Object 非必需。会议其他成员可接收到
            const pushedStream =  await emedia.mgr.publish(constaints,ext);

            this.is_me = pushedStream.ext.nickName;//存储下自己的用户ID
            console.log(pushedStream,'===============>调用 emedia.publish 发布视频流')
            if(ext.roleType == 'teacher'){
                this.audio_own_stream = pushedStream;//用来控制流
                this.stream_list.shift();//删除默认老师占位
                this.stream_list.unshift({
                        name:ext.nickName,
                        setAudio:true,
                        isSpeak:false,
                        setVideo:true,
                        setWhiteboard:true,
                        setMessage:true,
                        member:pushedStream.owner.name,
                        stream:pushedStream,
                        roleType:ext.roleType,
                        videoID:"list-"+ pushedStream.owner.name,
                        joinTime:new Date().getTime()
                });
                setTimeout(() => {
                    emedia.mgr.streamBindVideo(pushedStream, document.getElementById("list-"+ pushedStream.owner.name));
                }, 10);
            }else{
                this.audio_own_stream = pushedStream;//用来控制流
                // 加入角色为学生，检查数组内有无老师 ，有老师直接push，没老师手动push一个占位老师进去
                // 返回数组中满足条件的第一个元素的值，如果没有，返回undefined
                let result = this.stream_list.find(item =>{
                    return item.roleType  == 'teacher';
                });
                if(result){ //有老师
                    this.stream_list.map((item,index)=>{
                        if(item.roleType == 'teacher-seat'){
                            item.seat = true;
                        }
                    });
                    this.stream_list.push({
                        name:ext.nickName,
                        setAudio:true,
                        isSpeak:false,
                        setVideo:true,
                        setWhiteboard:true,
                        setMessage:true,
                        member:pushedStream.owner.name,
                        stream:pushedStream,
                        roleType:ext.roleType,
                        videoID:"list-"+ pushedStream.owner.name,
                        joinTime:new Date().getTime()
                    });
                    setTimeout(() => {
                        emedia.mgr.streamBindVideo(pushedStream, document.getElementById("list-"+ pushedStream.owner.name));
                    }, 10);
                }else{
                    this.stream_list.push({
                        name:ext.nickName,
                        setAudio:true,
                        isSpeak:false,
                        setVideo:true,
                        setWhiteboard:true,
                        setMessage:true,
                        member:pushedStream.owner.name,
                        stream:pushedStream,
                        roleType:ext.roleType,
                        videoID:"list-"+ pushedStream.owner.name,
                        joinTime:new Date().getTime()
                    });
                    setTimeout(() => {
                        emedia.mgr.streamBindVideo(pushedStream, document.getElementById("list-"+ pushedStream.owner.name));
                    }, 10);
                }
            }
            
          
            // 获取会议信息
            const confr_info = await emedia.mgr.selectConfr(confrId, password); 
            console.log(confr_info ,'===>获取会议信息  confr_info ');
            // GetConfrOper(confrId).then(item=>{
            //     console.log(item,'===>itemx')
            // });
        },
        // 只有老师自己才会显示拖动图标
        teacherDragIconFunc(val){
             console.log(val,'只有老师自己才会显示拖动图标')
        },
        // 滚动面板上的音频图标
        async swipeAudioFunc(scope,index){
            this.stream_list[index].setAudio = !this.stream_list[index].setAudio;
            const {confrId} = this.$store.state.user; 
            if(scope.setAudio){
                if(scope.stream){
                   // 解除静音某一人
                    emedia.mgr.unmuteBymemberId(confrId, scope.member.id);
                }
            }else{
                if(scope.stream){
                    // 静音某一人
                    emedia.mgr.muteBymemberId(confrId, scope.member.id);
                }
            }
        },
        // 滚动面板上的视频图标
        async swipeVideoFunc(scope,index){
            this.stream_list[index].setVideo = !this.stream_list[index].setVideo;
            const {confrId} = this.$store.state.user; 
            if(scope.setVideo){
                if(scope.stream){ 
                    const res_stream = await emedia.mgr.resumeVideo(scope.stream) //开启视频
                }
            }else{
                if(scope.stream){
                    const res_stream = await emedia.mgr.pauseVideo(scope.stream) //关闭视频
                }
            }
        },

        // header 内的 setting数据
        handelClickSet(val){
            console.log(val,'传递过来的值');
        },
        
        // 设置白板权限
        async setWhiteBoradFunc (scope,index){
            const {stream_list} = this;
            stream_list.map(item=>{
                if(item.roleType == 'teacher'){
                   this.saveStreamListName = item.stream.owner.name
                }
            });
            const {confrId,userName,accessToken} = this.$store.state.user;
            console.log(scope)
          
            if(scope.setWhiteboard){
                this.saveChatMemberInfo = [];
                this.saveChatMemberInfo.push(scope.stream.owner.name)
                const {accessToken} = this.$store.state.user;
                let obj = {
                    userName:scope.stream.owner.name,
                    accessToken:accessToken,
                    members:this.saveChatMemberInfo
                };
                console.log(obj)
                this.forbiteOprate(obj);
                // this.storageWhiteBorad.push(scope.member.name);
                // SetWhiteStatus(confrId,-1,this.storageWhiteBorad).then(res=>{
                //     if(res.code == 1){
                //         VanToast.success("您已设置该成员禁止操作白板");
                //     }
                // });
            }else{
                this.saveChatMemberInfo = [];
                this.saveChatMemberInfo.push(scope.stream.owner.name);
                const {accessToken} = this.$store.state.user;
                let obj = {
                    userName:scope.stream.owner.name,
                    accessToken:accessToken,
                    members:this.saveChatMemberInfo
                };
                 console.log(obj,'yunxu')
                this.allowOprate(obj);
                //  let removeArr = this.storageWhiteBorad;
                //  for (let i = 0; i < removeArr.length; i++) {
                // 　　if (removeArr[i] == scope.member.name) {
                //         removeArr.splice(i, 1); 
                //     　　　　i--; 
                //     　　}
                // }
                // SetWhiteStatus(confrId,1,removeArr).then(res=>{
                //     if(res.code == 1){
                //         VanToast.success("已解除该成员禁止操作白板");
                //     }
                // });
            }
        },
        // 设置消息权限
        async setMessageFunc (scope,index){
            const {confrId} = this.$store.state.user;
            console.log(scope.stream.owner.memName)
            let obj = {
                username:scope.stream.owner.memName
            };
            if(scope.setMessage){
                this.setChatroomMute(obj);
                // this.storageMessage.push(scope.member.name);
                // SetChatroomMute(confrId,-1,this.storageMessage).then(res=>{
                //     if(res.code == 1){
                //         VanToast.success("您已开启成员禁言");
                //     }
                // });
            }else{
                this.removeRoomMute(obj);
                //  let removeArr = this.storageMessage;
                //  for (let i = 0; i < removeArr.length; i++) {
                // 　　if (removeArr[i] == scope.member.name) {
                //         removeArr.splice(i, 1); 
                //     　　　　i--; 
                //     　　}
                // }
                // SetChatroomMute(confrId,1,removeArr).then(res=>{
                //     if(res.code == 1){
                //         VanToast.success("您已关闭成员禁言");
                //     }
                // });
            }
            
        },
        // 设置音频权限
        setAudioFunc (scope,index){
            const {confrId} = this.$store.state.user; 
            if(scope.setAudio){
                // 静音某一人
                emedia.mgr.muteBymemberId(confrId, scope.member.id);
            }else{
                // 解除静音某一人
                emedia.mgr.unmuteBymemberId(confrId, scope.member.id);
            }
        },
        // 设置视频权限
        async setVidioFunc(scope,index){
            const {confrId,password} = this.$store.state.user; 
            const {audio_own_stream} = this;
            if(scope.setVideo){
                console.log( scope,'scope')
                const res_stream = await emedia.mgr.pauseVideo(audio_own_stream) //关闭视频
                // const res_stream = await emedia.mgr.pauseVideo(scope.stream) //关闭视频
            }else{
                console.log( scope,'scope')
                console.log(
                    document.getElementById(scope.videoID)
                )
                const res_stream = await emedia.mgr.resumeVideo(audio_own_stream) //开启视频
                // const res_stream = await emedia.mgr.resumeVideo(scope.stream) //开启视频
            }
        },
        
        async close_audio(){
            const {audio_own_stream} = this;
            if(!audio_own_stream) {
                return
            }
            // 同步音量图标禁用还是启用
            this.stream_list.map(item=>{
                if(item.name == audio_own_stream.ext.nickName){
                    item.setAudio = false;
                }
            });
            await emedia.mgr.pauseAudio(audio_own_stream);//关闭音频
        },
        async open_audio(){
            const {audio_own_stream} = this;
            if(!audio_own_stream) {
                return
            }
            // 同步音量图标禁用还是启用
            this.stream_list.map(item=>{
                if(item.name == audio_own_stream.ext.nickName){
                    item.setAudio = true;
                }
            });
            await emedia.mgr.resumeAudio(audio_own_stream);//开启音频
        },
        // 开启聊天窗口
        infoIconFunc(){
            if(this.stuListStatusOverlay){ //开启聊天窗口时，如果学生列表打开 就关闭
                this.stuListStatusOverlay = false;
            }
            this.chatStatusOverlay = !this.chatStatusOverlay;
            const {userName} = this.$store.state.user;
            const {message_list,saveNickName} = this; 
            
            let getMes = JSON.parse(window.localStorage.getItem("message"));
            let storageMes = [];
            message_list.map(item=>{
               storageMes.push(item.message);
            });
            if(getMes){
                getMes.map(item=>{
                    if(!(storageMes.includes(item.data))) {
                        this.message_list.push({
                            message: item.data,
                            person: userName !== item.from ?item.ext.nickName:saveNickName,
                            isSelf: userName !== item.from ?false:true
                        });
                    }
                });
            }
        },
        // 关闭聊天窗口
        closeChatFunc(){
            this.chatStatusOverlay = false;
        },
        // 开启学生列表窗口
        membersIconFunc(){
            // 只在教师端 小班课显示成员图标
            if(this.chatStatusOverlay){ //开启学生列表窗口时，如果聊天窗口打开 就关闭
                this.chatStatusOverlay = false;
            }
            this.stuListStatusOverlay = !this.stuListStatusOverlay;
            
            const {stream_list} = this;
            const {allStopWhite} = this.$store.state;
            let allStopChat = JSON.parse(window.localStorage.getItem('allStopChat'));
            console.log(
                stream_list,'==>stream_list'
            )
            // // 学生列表 不显示老师自己
            // this.stream_list = this.stream_list.filter((item=>{
            //     return item.roleType !== 'teacher'
            // }))
            // (全员）禁止聊天：
            //      禁止全员聊天后，所有学生的“消息”权限状态均变为“关闭状态”；
            //      允许全员聊天后，所有学生的“消息”权限状态均变为“开启状态”；
            // （全员）禁用白板：
            //      禁止全员白板后，所有学生的“白板”权限状态均变为“关闭状态”；
            //      允许全员白板后，所有学生的“白板”权限状态均变为“开启状态”；
            if(allStopChat){  //是否全员禁聊 禁聊 true 不禁聊 false
                stream_list.map(item=>{
                    if(item.roleType !== "teacher"){
                        item.setMessage = false;
                    }
                });
            }else{
                stream_list.map(item=>{
                    if(item.roleType !== "teacher"){
                        item.setMessage = true;
                    }
                });
            }

            if(allStopWhite){  //是否全员禁止学生使用白板 禁止 true 不禁止 false
                stream_list.map(item=>{
                    if(item.roleType !== "teacher"){
                        item.setWhiteboard = false;
                    }
                });
            }else{
                stream_list.map(item=>{
                    if(item.roleType !== "teacher"){
                        item.setWhiteboard = true;
                    }
                });
            }
        },
        //关闭学生列表窗口
        closeStuListFunc(){
            this.stuListStatusOverlay = false;
        },
      
        // 发送聊天信息
        sendChatFunc(val){
            console.log('发送:',val)
            if(val){
                const {chatId} = this.$store.state.user;
                const {message_list,saveNickName} = this; 
                let id = WebIM.conn.getUniqueId();                 // 生成本地消息id
                let msg = new WebIM.message('txt', id);      // 创建文本消息
                let options = {
                    msg: val,                  // 消息内容
                    to: chatId,     // 接收消息对象（用户id）
                    chatType: 'chatRoom',                  // 设置为单聊:singleChat 群聊：groupChat 聊天室:chatRoom
                    ext: {nickName:saveNickName},          //扩展消息
                    success: function (id, serverMsgId) {// 对成功的相关定义，sdk会将消息id登记到日志进行备份处理
                        message_list.push({
                            message: val,
                            person:saveNickName,
                            isSelf: true
                        });
                        //that.sendValue = "";
                        console.log('send private text Success');  
                    },                                       
                    fail: function(e){// 对失败的相关定义，sdk会将消息id登记到日志进行备份处理
                        VanToast.fail("未知错误 消息发送失败");
                        console.log(e,"eeeeeeeeeeeee");  
                        console.log("Send private text error");  
                    }          
                }
                msg.set(options);
                WebIM.conn.send(msg.body); 
            }

        },
        //轮播图左侧点击事件
        swipePropFunc(){
            this.$refs.VanSwipe.prev();
        },
        //轮播图右侧点击事件
        swipeNextFunc(){
            this.$refs.VanSwipe.next();
        },
          // 允许白板互动
        allowClick(e) {
            const {userName,accessToken} = this.$store.state.user;
            let obj = {
                userName:userName,
                accessToken:accessToken
            };
            this.allowOprateAll(obj);
        },
        // 禁止白板互动
        forbitClick(e){
            const {userName,accessToken} = this.$store.state.user;
            let obj = {
                userName:userName,
                accessToken:accessToken,
            };
			this.forbiteOprateAll(obj);
        },
       //自定义工具事件
        handleToolsClick(index,val){
            switch(index){
                case 0:{
                    if(val){
                        this.forbitClick();//禁止白板互动
                    }else{
                        this.allowClick();//允许白板互动
                    }
                    break;
                }
                case 1:{
                    console.log('屏幕共享')
                    break;
                }
                default:{break;}
            }
        },
    },
    computed:{
        ...mapGetters(['getWhiteboardUrl']),
        splitNameFunc(){
            return function(item){
                if(item.name){
                    return item.name.length > 18 ? item.name.substring(0,18) + '...' : item.name
                }
            }
        },
        
        // 如果角色为学生，老师的音频和视频图标不显示，学生不可操作老师
        audioAndVideoIconFunc(){
            let that = this;
            return function(item){
                if(this.userTypeStatus){
                   return true; //老师显示所有学生的音视频图标（包括自己）
                }else{
                    if( that.is_me == item.name){ //学生只显示自己的音视频图标，不显示老师和其他学生的音视频图标
                        return true;
                    }else{
                        return false;
                    }
                }
            }
        },
        // 如果有人说话，显示说话的图标
        audioSpeakIconFunc(){
            return function(item){
                if(item.isSpeak){
                    return this.speakVoiceUrl;
                }else{
                    return item.setAudio ? this.TvoiceUrl : this.closeVoiceUrl;
                }
            }
        }
    },
    watch:{
        chatStatusOverlay(newVal){
            if(newVal){
                this.timer = setInterval(()=>{
                let getMes = JSON.parse(window.localStorage.getItem("message"));
                // 老师是否开启全员禁聊 true禁聊 false 解除禁聊
                let stopChat = JSON.parse(window.localStorage.getItem("allStopChat"));
                
                if(getMes){
                        const {userName} = this.$store.state.user;
                        const {message_list,saveNickName} = this; 
                        let storageMes = [];
                        message_list.map(item=>{
                            storageMes.push(item.message);
                        });
                        getMes.map(item=>{
                            if(!(storageMes.includes(item.data))) {
                                this.message_list.push({
                                    message: item.data,
                                    person: userName !== item.from ?item.ext.nickName:saveNickName,
                                    isSelf: userName !== item.from ?false:true
                                });
                            }
                        });
                     }
                 },500)
            }else{
                clearInterval(this.timer);
            }
        },
        stream_list: { //左右切换按钮，仅在视频区超过页面一屏范围时展示；
            handler(newValue) {
                let totalItem =  newValue.length * this.swipeItemWidth;
                let vanSwipe = document.getElementsByClassName('van-swipe')[0];
                if(totalItem > vanSwipe.clientWidth) {
                    this.toggleLeft = true;
                    this.toggleRight = true;
                }else{
                    this.toggleLeft = false;
                    this.toggleRight = false;
                }
            },
            deep: true 
        }
    }
}
</script>

<style lang="scss" src="./style.scss" scoped></style>
<style lang="scss" >
    // 取消轮播图下边的标记点
    .van-swipe__indicators{
        display:none !important;
    }
</style>
