<template>
     <!-- <van-overlay :show="show" :data="data" class-name="custom-overlay"> -->
                <div class="chat-window-style" v-show="show" :data="data">
                    <div class="chat-container">
                        <!-- 关闭按钮 -->
                        <section class="chat-container-header">
                            <div class="chat-container-header-title">聊天区</div>
                            <div class="chat-container-header-icon"><van-icon name="cross"  class="close-icon" @click="closeChatFunc"/></div>
                        </section>
                        <!-- 面板信息 -->
                        <section  class="chat-container-panel">
                            <div class="chat-container-panel-info">
                                <ul class="content">
                                    <li v-for="(item, index) in data" :key="index">
                                        <div :style="item.isSelf?'text-align:right;':'text-align:left;'">
                                            <p style="margin:0;font-size:12px">{{item.person}}</p>
                                        </div>
                                        <div>
                                            <span :class="'span'+(item.isSelf?'right':'left')">{{item.message}}</span>
                                        </div>
                                    </li>
                                </ul>
                            </div>
                        </section>
                    
                        <!-- 发送文本 -->
                        <section style="background:#fff;">
                            <section class="chat-container-send">
                                <!-- 图标 老师端显示 学生端不显示-->
                                <div class="chat-container-send-icon">
                                    <el-tooltip class="item" effect="dark" 
                                        :content="chatStatus ? '允许聊天' : '禁止聊天'" >
                                        <van-image 
                                        class="chat-custor-pointer" 
                                        :src="chatStatus ? stopChatUrl : allowChatUrl" 
                                        style="width:28px;height:28px;" 
                                        @click="chatIconSwitchFunc(chatStatus)" 
                                        v-if=" userType == 'students' ? false : true "/>
                                    </el-tooltip>
                                </div>
                                <!-- 输入框 -->
                                <div style="flex-grow:1;">
                                    <van-field class="chat-container-send-input" 
                                        v-model="sendValue" 
                                        :disabled="disableInput"
                                        :placeholder="placeholderStatus" />
                                </div>
                                <!-- 发送按钮 -->
                                <div style="padding-right:10px;" >
                                    <van-button round 
                                    style="background:#766CD3;
                                            font-size: 12px;
                                            font-family: PingFang-SC-Medium, PingFang-SC;
                                            font-weight: 500;
                                            color: #FFFFFF;
                                            line-height: 20px;
                                            letter-spacing: 0.34px;
                                            border-radius: 14px;"
                                        class="chat-container-send-button" 
                                        @click="sendChatFunc"
                                        :style="sendButtonStyle ? this.chatButtonColor : ''" 
                                        :disabled="disableButton">
                                        发送
                                    </van-button>
                                </div>
                            </section>
                        </section>
                    </div>
                </div>
       <!-- </van-overlay> -->
</template>

<script>
    import {mapActions,mapGetters,mapState} from 'vuex'
    import {SetChatroomMute} from '../../api/conference'
    import { Toast as VanToast} from 'vant';
    import WebIM from '../../config/WebIM'
    export default {
        name: "myChat",
        props:{
            show:{
                default () {
                    return false;
                },
                type:Boolean
            },
            data:{
                default () {
                    return [];
                },
                type:Array
            }
        },
        data(){
            return {
                allowChatUrl:require("@/assets/chat.png"),// 允许聊天图标
                stopChatUrl:require("@/assets/stop-chat.png"),// 禁止聊天图标
                chatButtonColor:{background:"#AAAAAA",border:0,opacity:1},// 禁止聊天按钮样式
                chatStatusOverlay:true,
                sendValue:"",
                userType:this.$store.state.user.personType,//用户角色 老师/学生
                userTypeStatus:false,//true为老师 false为学生
                timer:null,

                disableInput:false,
                disableButton:false,
                sendButtonStyle:false,
                placeholderStatus:'说点什么...',
            }
        },
        created(){
            //回车键发送消息
            let that = this;
                document.onkeypress = function (e) {
                let keycode = document.all ? event.keyCode : e.which;
                if (keycode == 13) {
                    that.sendChatFunc();// 登录方法名
                    return false;
                }
            };
        },
        mounted(){
            this.userTypeStatus = this.userType == "students" ? false : true;
            this.WebIMcallbackIM();
			window.localStorage.setItem('allStopChat',false);//聊天室默认是全体未禁言状态
        },
      
        methods:{
            ...mapActions([
                'onLogin',
                'joinRoom',
                'queryFriendsList',
                'getRoomsMember',//获取聊天室成员
                'getHistory',
                'getRoomsList',
                'setMuteAll',///开启聊天室全员禁言
                'removeMuteAll',// //关闭聊天室全员禁言
            ]),
            WebIMcallbackIM(){
                this.joinRoom();
                this.getRoomsMember();
            },
            // 点击聊天窗口内的聊天图标
            async chatIconSwitchFunc(val){
                if(this.chatStatus){
                    const result = await this.removeMuteAll();//解除全员禁言
                    if(result.data){
                        this.$store.commit('chatCurStatus',false);
                    }
                }else{
                    const result = await this.setMuteAll(); //开启全员禁言
                    if(result.data){
                        this.$store.commit('chatCurStatus',true);
                    }
                }
            },
        
            // 关闭聊天窗口
            closeChatFunc(){
                this.$emit('close');
                // this.chatStatusOverlay = false;
            },
            // 发送聊天信息
            sendChatFunc(){
                let that = this;
                if(this.sendValue){
                    this.$emit('send',this.sendValue);
                    this.sendValue = "";
                    // let id = WebIM.conn.getUniqueId();                 // 生成本地消息id
                    // let msg = new WebIM.message('txt', id);      // 创建文本消息
                    // let options = {
                    //     msg: that.sendValue,                  // 消息内容
                    //     to: that.$store.state.user.chatId,     // 接收消息对象（用户id）
                    //     chatType: 'chatRoom',                  // 设置为单聊:singleChat 群聊：groupChat 聊天室:chatRoom
                    //     ext: {},                                  //扩展消息
                    //     success: function (id, serverMsgId) {// 对成功的相关定义，sdk会将消息id登记到日志进行备份处理
                    //         // that.data.push({
                    //         //     message: that.sendValue,
                    //         //     person:id,
                    //         //     // time:new Date(),
                    //         //     isSelf: true
                    //         // }); 
                    //         that.sendValue = "";
                    //         console.log('send private text Success');  
                    //     },                                       
                    //     fail: function(e){// 对失败的相关定义，sdk会将消息id登记到日志进行备份处理
                    //         console.log(e,"eeeeeeeeeeeee");  
                    //         console.log("Send private text error");  
                    //     }          
                    // }
                    // msg.set(options);
                    // WebIM.conn.send(msg.body);     
                }
            },
        },
        computed:{
            ...mapState(['chatStatus']),
        },
        watch: {
            data: function() { //每次发送聊天后，都将滚动条自动滚到底部，实现可以看到新发送的内容
                // nextTick：等待DOM更新完成后再执行回调函数
                this.$nextTick(() => {
                    let container = this.$el.querySelector('.content');
                    container.scrollTop = container.scrollHeight // 将页面卷到底部
                })
            },
           
            
            show:function(newVal) { 
                // 如果聊天窗口是开启状态
                if(newVal){
                    let that = this;
                    this.timer = setInterval(()=>{
                        let getChatStop = JSON.parse(window.localStorage.getItem("allStopChat"));
                        if(getChatStop){ // 如果老师采用全局禁言  老师对自己的权限控制无效，只操作学生的权限
                            if(this.userTypeStatus){ //如果为老师
                               
                            }else{ //如果为学生
                                this.placeholderStatus = '禁言中';
                                this.disableInput = true;
                                this.disableButton = true;
                                this.sendButtonStyle = true;
                            }
                        }else{
                            this.placeholderStatus = '说点什么...';
                            this.disableInput = false;
                            this.disableButton = false;
                            this.sendButtonStyle = false;
                        }
                    },500);
                }else{
                    clearInterval(this.timer);
                }
            }
        },
    }
</script>

<style lang="scss" src="./style.scss" scoped></style>
<style lang="scss">
   .content {
      font-size: 14px;
      height: 310px;
      overflow: auto;
      padding: 0 5px 20px 5px;;
      margin:0;
    }
    .content li {
      margin-top: 10px;
      overflow: hidden;
    }
    .content li img {
      float: left;
    }
    .content li span {
      background: #8178D5;
      padding: 6px;
      float: left;
      margin: 0 10px 0 10px;
      max-width: 310px;
      box-shadow: 0 0 3px #ccc;
      font-size: 12px;
    }
    .content li span.spanleft {
        float: left;
        background: #fff;
        font-size: 12px;
        font-family: PingFang-SC-Medium, PingFang-SC;
        font-weight: 500;
        color: #616C8F;
        border-radius: 0px 4px 4px 8px;
    }
    .content li span.spanright {
        float: right;
        font-size: 12px;
        font-family: PingFang-SC-Medium, PingFang-SC;
        font-weight: 500;
        color: #FFFFFF;
        background: #8178D5;
        border-radius: 4px 0px 8px 4px;
    }
</style>