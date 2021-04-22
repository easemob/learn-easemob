<template>
  <div>
      <header>
          <onLineNetWork/>
          <headerHostName/>
          <com-headerSet @handelClick="handelClickSet" />
      </header>
      <main style="display:flex;">
        <!-- 白板区域 -->
        <section style="width: 80%;position:relative;">
            <!-- 屏幕共享时老师端显示占位图 -->
            <div v-show="shared_desktop" style="width:100%;height: 100%;">
                <template v-if=" userType == 'students' ? false : true ">
                    <div class="shared_desktop_container">
                        <p class="shared_desktop_item">正在共享屏幕...</p>
                    </div>
                </template>
            </div>
            <!-- 屏幕共享时学生端显示视频区域 -->
            <!-- 承载屏幕共享的容器 START -->
            <template v-if=" userType == 'students' ? true : false ">
                <video ref="desktop" id="desktop"></video> 
            </template>
            <!-- 承载屏幕共享的容器 END -->
            <div class="handle-whiteboard" v-show="!shared_desktop">
                    <div class="whiteboard">
                    <div class="iframeContent">
                        <div v-show="whiteBlockVideo" class="whiteVideoStyle">
                        <div class="helloword">
                            <div class="text-event">
                            <vue-draggable-resizable
                                :w="300"
                                :h="300"
                                :x="100"
                                :y="100"
                                :parent="true"
                                :grid="[10, 10]"
                                class-name="dragging1"
                                @dragging="onDrag"
                                @resizing="onResize"
                            >
                                <!-- 视频展位图 -->
                                <section v-show="!whiteTeacherVideoStatus" class="placeholderImg-tea">
                                    <van-image :src="techarPlaceholderImg" class="placeholderImg-tea-img" />
                                </section>
                                <!-- 视频显示区 -->
                                <video id="teacher-white" v-show="whiteTeacherVideoStatus"></video>

                                <p class="white-dragIcon">
                                    <van-image
                                        style="width: 24px; height: 24px"
                                        :src="narrowIconUrl"
                                        @click="notWhiteVideoBlockFunc"
                                    ></van-image>
                                </p>
                                <div style="display: flex;
                                        align-items: center;
                                        justify-content: space-between;
                                        padding: 0 20px;
                                        background: #616C8F;
                                        opacity: 0.57;
                                        color: #fff;
                                        height: 34px;
                                        margin-top:-2px;" >
                                    <p class="person-text">{{ teaName }}</p>
                                    <p style="display:flex;align-items: center;justify-content:center;">
                                        <van-image
                                            style="width:13px;height:18px;margin-right: 10px;cursor: pointer;"
                                            :src="whiteTeacherVoiceStatus ? TvoiceUrl : closeVoiceUrl"
                                            @click="whiteVoiceFunc"
                                        ></van-image>
                                        <van-image
                                            style="width:15px;height:18px;cursor: pointer;"
                                            :src="whiteTeacherVideoStatus ? TvideoUrl : closeVideoUrl"
                                            @click="whiteVideoFunc"
                                        ></van-image> 
                                    </p>
                                </div>
                            </vue-draggable-resizable>
                            </div>
                        </div>
                        </div>
                        <iframe :src="getWhiteboardUrl"></iframe>
                    </div>
                    </div>
            </div>
            <div class="tools_style" style="z-index:1;">
                <!-- 自定义工具图标 白板，屏幕共享 -->
                <com-tool @handleClick="handleToolsClick" v-if=" userType == 'students' ? false : true " style="margin-right:10px;"/>
                <!-- 右侧聊天图标 -->
                <van-image style="width:38px;height:38px;cursor:pointer;margin-right:3px;" :src="infoIcon" @click="infoIconFunc"></van-image>
            </div>
            <com-chat ref="myChat" :show="chatStatusOverlay" :data="message_list" @send="sendChatFunc" @close="closeChatFunc" style="bottom: 25%;right: 0;"/>
        </section>
        <!-- 视频区域 -->
        <section style="width: 20%;">
            <!-- 老师 -->
            <div style="height: 50%;">
                <div v-show="whiteBlockVideo" class="placeholderImg-tea">
                    <van-image :src="videoTecharPlaceholderImg" class="placeholderImg-tea-img" />
                    <p style="position: absolute;
                        top: 50%;
                        left: 50%;
                        transform: translate(-50%, 300%);
                        font-size: 16px;
                        font-family: PingFang-SC-Regular, PingFang-SC;
                        font-weight: 400;
                        color: #616C8F;">老师的位置</p>
                </div>
                <div class="windowTeacher" v-show="!whiteBlockVideo">
                    <section v-show="teacherVideoStatus" style="height: 100%">
                    <video id="teacher" style="width: 100%;
                        height: 100%;
                        position: absolute;
                        left: 0px;
                        top: 0px;
                        transform: rotateY(180deg);
                        object-fit: cover;"></video>
                    <!-- 显示拖放图标 -->
                    <p v-if="userType == 'students' ? false : true" class="dragIcon">
                        <el-tooltip class="item" effect="light" content="拖入白板区">
                        <van-image
                            style="width: 24px; height:24px"
                            :src="dragIconUrl"
                            @click="videoWhiteBlockFunc"
                        ></van-image>
                        </el-tooltip>
                    </p>
                    </section>
                    <section v-if="!teacherVideoStatus" class="placeholderImg-tea">
                        <van-image :src="videoTecharPlaceholderImg" class="placeholderImg-tea-img" />
                        <!-- <p class="text" v-if=" userType == 'students' ? true : false && !this.teacherVideoStatus">老师正在赶来的路上</p> -->
                    </section>

                    <!-- 显示底部文字 -->
                    <div class="window-bottom-text">
                        <p class="person-text">{{ teaName }}</p>
                        <!-- 如果角色为学生，老师的音视频图标不显示 -->
                        <p class="person-icon" v-if="userType == 'students' ? false : true">
                            <van-image
                            class="elImg"
                            :src="teacherVoiceStatus ? TvoiceUrl : closeVoiceUrl"
                            @click="tVoiceUrlFunc"
                            ></van-image>
                            <van-image
                            class="elImg"
                            :src="teacherVideoStatus ? TvideoUrl : closeVideoUrl"
                            @click="tVideoUrlFunc"
                            ></van-image>
                        </p>
                    </div>
                </div>
            </div>
            <!-- 学生 -->
            <div style="height: 50%;">
                <div style="height: 100%;" class="windowStudents">
                    <section v-show="stuVideoStatus"  style="height: 100%;">
                        <video id="stu-video" style="width: 100%;
                        height: 100%;
                        position: absolute;
                        left: 0px;
                        top: 0px;
                        transform: rotateY(180deg);
                        object-fit: cover;"></video>
                    </section>
                    <section v-show="!stuVideoStatus" class="placeholderImg-stu">
                        <van-image :src="stuPlaceholderImg" class="placeholderImg-stu-img" />
                        <!-- <p class="text" v-if="userType == 'students' ? false : true && !this.stuVideoStatus">学生正在赶来的路上 </p> -->
                    </section>
                    <div class="window-bottom-text-stu">
                        <p class="person-text">{{ stuName }}</p>
                        <p class="person-icon">
                            <van-image
                            class="elImg"
                            :src="stuVoiceStatus ? SvoiceUrl : closeVoiceUrl"
                            @click="sVoiceUrlFunc"
                            />
                            <van-image
                            class="elImg"
                            :src="stuVideoStatus ? SvideoUrl : closeVideoUrl"
                            @click="sVideoUrlFunc"
                            />
                        </p>
                    </div>
                </div>
            </div>
        </section>
      </main>
  </div>
</template>

<script>
import headerSet from '../headerSetting/index'
import tools from '../customTools/tools'
import chat from '../chat/index'
import headerHostName from '../headerHostName/index'
import onLineNetWork from '../headerNetWork/index'
import { GetConfrOper,SetRole } from '../../api/conference'
import {GetCur,GetNickName} from '../../api/user'
import VueDraggableResizable from 'vue-draggable-resizable'
import 'vue-draggable-resizable/dist/VueDraggableResizable.css'
import {mapActions,mapGetters} from 'vuex'
import { Toast as VanToast} from 'vant';
import whiteBoards from 'easemob-whiteboards' //引入环信白板sdk
import WebIM from '../../config/WebIM'

export default {
    components:{
        'vue-draggable-resizable':VueDraggableResizable,
        'com-tool':tools,'com-headerSet':headerSet,'com-chat':chat,onLineNetWork,headerHostName},
    data(){
        return {
            infoIcon:require("@/assets/u81.png"),
            chatStatusOverlay:false,
            message_list:[],//存储聊天消息的列表
           
            // 老师音视频
            techarPlaceholderImg:require("@/assets/u45.png"),//白板区老师视频默认占位图片
            videoTecharPlaceholderImg:require("@/assets/u45-teacher.png"),//视频区老师视频默认占位图片
            TvoiceUrl:require("@/assets/micro-is-open-icon.png"),//音频
            TvideoUrl:require("@/assets/video-is-open-icon.png"),//视频
            dragIconUrl:require("@/assets/u89.png"),//放大图标
            narrowIconUrl:require("@/assets/u89-narrow.png"),//缩小图标
            teacherVoiceStatus:true,//老师音频状态 
            teacherVideoStatus:false,//老师视频状态 默认显示占位图片 状态为true 显示视频
            
            // 学生音视频
            stuPlaceholderImg:require("@/assets/u46.png"),//学生视频内默认占位图片
            SvoiceUrl:require("@/assets/micro-is-open-icon.png"),//音频
            SvideoUrl:require("@/assets/video-is-open-icon.png"),//视频
            stuVoiceStatus:false,//学生音频状态 
            stuVideoStatus:false,//学生视频状态 默认显示占位图片 状态为true 显示视频  

            closeVoiceUrl:require("@/assets/micro-is-close-icon.png"),//关闭音频
            closeVideoUrl:require("@/assets/video-is-close-icon.png"),//关闭视频
           
            houseType:this.$store.state.user.houseType,//房间类型 一对一 小班课
            userType:this.$store.state.user.personType,//用户角色 老师/学生
            userTypeStatus:false,//true为老师 false为学生

            whiteBlockVideo:false,//是否在白板区显示老师视频 false不在白板区显示 true在白板区显示
            whiteBlockPlaceHoldImgVideo:false,//是否在白板区显示老师默认占位图片 false不显示 true显示
            whiteTeacherVoiceStatus:true,//白板区老师音频状态 
            whiteTeacherVideoStatus:true,//白板区老师视频状态 
 
            width: 0,
            height: 0,
            x: 0,
            y: 0,
            localStream:"",//老师的视频流
            otherStream:"",//学生的视频流 
            otherMember:"",//学生的member
            teaName:"老师",//老师名称
            stuName:"学生",//学生名称
            saveNickName:"",
            timer:null,
            shared_desktop:false,
            own_desktop_stream: null, // 老师发起的屏幕共享流，不显示（保存起来，用于停止共享）
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
            console.log(res)
            this.saveNickName = res.nickName;
        });
    },
   
    methods:{
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
            const BASE_URL = "https://a1.easemob.com"
            const BASE_APP_KEY="1108200509113038#chatapp"
            const userName =  this.$store.state.user.userName;
            const accessToken =  this.$store.state.user.accessToken;
            const confrId = this.$store.state.user.confrId;

            const memName = BASE_APP_KEY +'_'+ userName;
            emedia.config({
                restPrefix:BASE_URL, //配置服务器域名、必填 比如: 'https://a1.easemob.com'
                appkey:BASE_APP_KEY, // 从环信后台 获取的appkey、必填
                consoleLogger: true, // boolean 是否开启打印日志，默认true
            });
            emedia.mgr.setIdentity(memName, accessToken); //设置memName 、token
            emedia.mgr.onStreamAdded = function(member, stream) {
                // console.log("onStreamAdded" + member,stream);
                // console.log(member.memName);
                // console.log(stream);
                // console.log(member);
                if(
                    stream.type == emedia.StreamType.DESKTOP 
                    && stream.located()
                ) { // 自己的共享桌面不显示
                    that.own_desktop_stream =  stream;// 保存下来，用于停止共享
                    return
                }
                if(!stream.located()) {
                //    if( stream.ext.roleType == "teacher"){
                   if( member.memName.split('.').length > 1){
                        console.log(stream,'老师');
                        console.log(member,'老师');
                            // 获取用户昵称
                            GetNickName(confrId,stream.owner.memName).then(res=>{
                                // console.log('11111111111111111111111111111111');
                                // console.log(res);
                                if(res){
                                    that.teaName = res;//绑定老师名称
                                }
                                // console.log('222222222222222222222222222222222');
                            });
                            /**
                             * 此种方法绑定老师名称 当屏幕共享时会报错，由于没有stream.ext.nickName
                             * 采用如上接口调用方式绑定老师名称
                             */
                            // that.teaName = stream.ext.nickName;//绑定老师名称 
                            that.teacherVideoStatus  = true;//显示老师视频
                            let teacherVideoTag = document.getElementById('teacher');
                            emedia.mgr.subscribe(member, stream, true, true, teacherVideoTag);
                        if(stream.type == 1){
                            emedia.mgr.subscribe(member, stream, true, true, document.getElementById("desktop"));
                            document.getElementById("desktop").style.zIndex=1;
                        }else{
                            document.getElementById("desktop").style.zIndex=0;
                        }
                    }else{
                        console.log(stream,'学生');
                        console.log(member,'学生');
                        that.otherMember = member;
                        // that.stuName = stream.ext.nickName;//绑定学生名称
                        that.stuName = stream.ext.nickName;//绑定学生名称

                        that.stuVideoStatus  = true;//显示学生视频
                        let stuVideoTag = document.getElementById('stu-video');
                        emedia.mgr.subscribe(member, stream, true, true, stuVideoTag)    ;
                        // 监听音视频的开关
                        console.log(stuVideoTag,'==>videoTag');
                        emedia.mgr.onMediaChanaged(stuVideoTag, function (constaints, stream) {
                            if(constaints.aoff == 1){ //学生关闭了自己的音频
                                that.stuVoiceStatus = false;
                            }else if(constaints.aoff == 0){ //学生开启了自己的音频
                                 that.stuVoiceStatus = true;
                            }

                            if(constaints.voff == 1){ //学生关闭了自己的视频
                                that.stuVideoStatus = false;
                            }else if(constaints.voff == 0){ //学生开启了自己的视频
                                that.stuVideoStatus = true;
                            }
                            console.log(constaints,'constaints=========================================')
                            console.log(stream,'stream=========================================')
                        });
                    }
                };
               
            }
           

            //有媒体流移除
            emedia.mgr.onStreamRemoved = function(member, stream) {
                // member：发布流人员的信息、stream：流信息
                emedia.mgr.unsubscribe(stream) // 停止订阅流
                //removeView(stream.id) // 移除video标签，removeView方法需自己实现
                document.getElementById("desktop").style.zIndex=0;
                console.log("媒体流发布者退出=========" + JSON.stringify(member.name));
            }

            //有人加入会议
            emedia.mgr.onMemberJoin = function (member) {
                console.log('onMemberJoined',member);
                console.log(`${member.nickName || member.name} 加入了会议`);
            }
                
            //有人退出会议
            emedia.mgr.onMemberExited = function (member, reason, failed) {
                console.log('onMemberLeave', member, reason, failed);
                console.log(`${member.nickName || member.name} 退出了会议`);
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
            emedia.mgr.onMuted = () => {
                // alert("你被管理员禁言了");
                that.stuVoiceStatus = false;//修改学生的音频图标为禁用状态
                that.close_audio();// 在收到回调后，需要在程序中执行关闭麦克风的逻辑( await emedia.mgr.pauseAudio(own_stream))
            }
            emedia.mgr.onUnmuted = () => { 
                // alert("你被管理员取消了禁言");
                that.stuVoiceStatus = true;//修改学生的音频图标为启用状态
                that.open_audio();// 在收到回调后，需要在程序中执行开启麦克风的逻辑( await emedia.mgr.resumeAudio(own_stream))
            }
            //监听断网状态
            emedia.mgr.onNetworkDisconnect = streamId => {
                console.log("监听断网状态: "+ streamId)
            } //streamId 会议中的流 ID
        },
         ...mapActions([
            'allowOprateAll', // 允许全体成员互动
            'forbiteOprateAll',  // 禁止全体成员互动
             "deleteWhiteboard",
             "initConferenceInfo",
             "saveAllStopWhiteStatus"
            ]),
        onResize: function(x, y, width, height) {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
        },
        onDrag: function(x, y) {
            this.x = x;
            this.y = y;
        },
      
        async joinConference(){
                const {confrId,password,nickName,userName} = this.$store.state.user;
                const {userType} = this; 
                // 获取会议信息
                const confr_info = await emedia.mgr.selectConfr(confrId, password); 
                console.log(confr_info ,'===>会议信息  confr_info ');
                const join_result  = await emedia.mgr.joinUsePassword(confrId,password);
                console.log(join_result ,'===>加入会议  join_result ');

                if(userType == "teacher"){
                    SetRole(confrId,7,userName).then(res=>{
                        if(res.code ==1){
                            console.log('已成功设置老师身份为管理员')
                        }
                    });
                };

                let constaints = { audio: true,video: true }
                let ext = {
                    nickName: nickName,
                    roleType: userType
                } // 发布流的扩展信息 Object 非必需。会议其他成员可接收到
                const pushedStream =  await emedia.mgr.publish(constaints,ext)
            
                if(ext.roleType == "teacher"){
                    this.localStream = pushedStream;//绑定老师视频流
                    this.teaName = ext.nickName;//绑定老师名称
                    this.teacherVideoStatus  = true;//显示老师视频
                    let teacherVideoTag = document.getElementById('teacher');
                    let teacherVideoWhiteTag = document.getElementById('teacher-white');
                    emedia.mgr.streamBindVideo(pushedStream, teacherVideoTag);
                    emedia.mgr.streamBindVideo(pushedStream, teacherVideoWhiteTag);
                }else{
                    this.otherStream = pushedStream;//绑定学生视频流
                    this.stuName = ext.nickName;//绑定学生名称
                    this.stuVideoStatus  = true;//显示学生视频
                    this.stuVoiceStatus  = true;//显示学生音频
                    

                    let stuVideoTag = document.getElementById('stu-video');
                    emedia.mgr.streamBindVideo(pushedStream, stuVideoTag);
                }
                
                GetConfrOper(confrId).then(item=>{
                    console.log(item,'===>itemx')
                });
        },
       
        // header 内的 setting数据
        handelClickSet(val){
            console.log(val,'传递过来的值');
        },
        
        // 开启聊天窗口
        infoIconFunc(){
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
                    success: function (id, serverMsgId) {  // 对成功的相关定义，sdk会将消息id登记到日志进行备份处理
                        message_list.push({
                            message: val,
                            person:saveNickName,
                            isSelf: true
                        });
                        console.log('send private text Success');  
                    },                                       
                    fail: function(e){// 对失败的相关定义，sdk会将消息id登记到日志进行备份处理
                        console.log(e,"eeeeeeeeeeeee");  
                        console.log("Send private text error");  
                    }          
                }
                msg.set(options);
                WebIM.conn.send(msg.body); 
            }
        },
        
        async tVoiceUrlFunc(){
            this.teacherVoiceStatus = !this.teacherVoiceStatus;
            if(this.teacherVoiceStatus){
                if(this.localStream){
                    const res_stream = await emedia.mgr.resumeAudio(this.localStream) //开启音频
                }
            }else{
                if(this.localStream){
                   const res_stream = await emedia.mgr.pauseAudio(this.localStream) //关闭音频
                }
            }
        },
        async tVideoUrlFunc(){
            this.teacherVideoStatus = !this.teacherVideoStatus;
            if(this.teacherVideoStatus){
                if(this.localStream){
                    const res_stream = await emedia.mgr.resumeVideo(this.localStream) //开启视频
                }
            }else{
                if(this.localStream){
                    const res_stream = await emedia.mgr.pauseVideo(this.localStream) //关闭视频
                }
            }
        },
        async sVoiceUrlFunc(){
            const {confrId} = this.$store.state.user; 
            const {userType,otherMember} = this;
            this.stuVoiceStatus = !this.stuVoiceStatus;
            if(this.stuVoiceStatus){
                 if(userType == "teacher"){ //如果角色为老师 老师可以操作学生音频流 
                    //解除静音某一人
                    emedia.mgr.unmuteBymemberId(confrId, otherMember.id);
                }else{
                    if(this.otherStream){
                        const res_stream = await emedia.mgr.resumeAudio(this.otherStream);
                    }
                }
            }else{
                if(userType == "teacher"){ //如果角色为老师 老师可以操作学生音频流 
                    // 静音某一人
                    emedia.mgr.muteBymemberId(confrId, otherMember.id);
                }else{
                    if(this.otherStream){
                      const res_stream = await emedia.mgr.pauseAudio(this.otherStream) //关闭音频
                        console.log(res_stream,'关闭音频学生');
                    }
                }
            }
        },
        async sVideoUrlFunc(){
            const {userType} = this;
            this.stuVideoStatus = !this.stuVideoStatus;
            if(this.stuVideoStatus){
                if(userType == "teacher"){
                    if(this.otherStream){
                        //如果角色为老师 老师可以操作学生视频流 目前环信暂不支持该功能
                    }
                }else{
                    if(this.otherStream){
                        const res_stream = await emedia.mgr.resumeVideo(this.otherStream) //开启视频
                        console.log( res_stream,'===>res_stream 开启视频')
                    }
                }
            }else{
                const {userType} = this;
                if(userType == "teacher"){
                    if(this.otherStream){
                        //如果角色为老师 老师可以操作学生视频流 目前环信暂不支持该功能
                    }
                }else{
                    if(this.otherStream){
                        const res_stream = await emedia.mgr.pauseVideo(this.otherStream) //关闭视频
                        console.log(res_stream,'===>res_stream 关闭视频' )
                    }
                }
            }
        },
        async close_audio(){
            const {otherStream} = this;
            if(!otherStream) {
                return
            }
            await emedia.mgr.pauseAudio(otherStream);//关闭音频
        },
        async open_audio(){
            const {otherStream} = this;
            if(!otherStream) {
                return
            }
            await emedia.mgr.resumeAudio(otherStream);//开启音频
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
        
        // 老师视频在白板区显示
        videoWhiteBlockFunc(){
            this.whiteBlockVideo = !this.whiteBlockVideo;//老师视频在白板区显示
        },
        // 老师视频不在白板区显示
        notWhiteVideoBlockFunc(){
            this.whiteBlockVideo = false;//老师视频不在白板区显示
        },
        // 白板内视频 音频事件
        whiteVoiceFunc(){
            this.whiteTeacherVoiceStatus = !this.whiteTeacherVoiceStatus;
            console.log(this.whiteTeacherVoiceStatus );
        },
        // 白板内视频 视频事件
        whiteVideoFunc(){
            this.whiteTeacherVideoStatus = !this.whiteTeacherVideoStatus;
            console.log(this.whiteTeacherVideoStatus );
        },
        stop_share_desktop() {
            if(this.own_desktop_stream){
                this.shared_desktop=false;
                emedia.mgr.unpublish(this.own_desktop_stream);
                this.own_desktop_stream= null;
            }
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
                    if(val){
                        this.shared_desktop = true;
                    }else{
                        this.stop_share_desktop();
                    }
                    break;
                }
                default:{break;}
            }
        },
    },
    computed:{
        ...mapGetters(['getWhiteboardUrl']),
    },
   
    watch:{
        chatStatusOverlay(newVal){
            if(newVal){
                this.timer = setInterval(()=>{
                let getMes = JSON.parse(window.localStorage.getItem("message"));
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
                 },500);
            }else{
                clearInterval(this.timer);
            }
        },
    }
}
</script>
<style lang="scss" src="./style.scss" scoped></style>
<style lang="scss">
        .helloword {
            overflow: hidden;
        }
        .text-event {
            float: left;
            height: 500px;
            width: 500px;
            // border: 1px solid red;
            position: relative;
        }
        .p-event {
            float: left;
            height: 300px;
            width: 300px;
            border: 1px solid blue;
            position: relative;
            margin-left: 20px;
            background: red;
        }

        .dragging1 {
            // border: 1px solid #000;
            color: #000;
        }
</style>
