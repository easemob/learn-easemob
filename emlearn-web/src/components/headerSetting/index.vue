<template>
    <div>
        <section class="block-pointer">
            <van-image class="icon-image" :src="settingUrl" @click="showSettingOverlay=true"></van-image>
            <van-image class="icon-image" :src="uploadUrl" @click="showLogDialog=true"></van-image>
            <van-image class="icon-image" :src="exportUrl" @click="showLeaveDialog=true"></van-image>
        </section>
        <!-- 设置 -->
        <van-dialog v-model="showSettingOverlay" style="border-radius: 4px;"
            :showConfirmButton="false">
            <div class="wrapper" >
                <div class="block">
                    <!-- 摄像头 -->
                    <div class="settingOverlay">
                        <p class="text-title">摄像头</p>
                        <p>
                            <el-select v-model="cameraValue" placeholder="请选择" size="mini"  class=""
                            style="width:100%; border: none ;
                            border-bottom: 1px solid #ddd;
                            border-radius: 0;
                            padding: 0;">
                                <el-option
                                    v-for="item in cameraOptionData"
                                    :key="item.deviceId"
                                    :label="item.label"
                                    :value="item.deviceId"
                                    @change="changeCameraFunc">
                                </el-option>
                            </el-select>
                        </p>
                    </div>
                    <!-- 麦克风 -->
                    <div class="settingOverlay">
                        <p class="text-title">麦克风</p>
                        <p>
                            <el-select v-model="microphoneValue" placeholder="请选择" size="mini" style="width:100%;">
                                <el-option
                                    v-for="item in microphoneOptionData"
                                    :key="item.deviceId"
                                    :label="item.label"
                                    :value="item.deviceId"
                                    @change="changeMicrophoneFunc">
                                </el-option>
                            </el-select>
                        </p>
                        <section class="setting-icon-style">
                            <div style="display:flex;margin-right:5px;"><van-image style="width:16px;height:22px;" :src="microphoneIconUrl"></van-image></div>
                            <template v-for="(index) in 40" >
                                <div 
                                    :key="index" 
                                    style="width:2.4px;height:12px;margin:0 2px;border-radius:5px;background:#CCCCCC;"
                                    :style="blockVolumFunc(index)" 
                                    class="pointer-volume"
                                >
                                </div>
                            </template>
                        </section>
                    </div>
                    <!-- 扬声器 -->
                    <div class="settingOverlay">
                        <p class="text-title">扬声器</p>
                        <p>
                            <el-select v-model="speakerValue" placeholder="请选择" size="mini" style="width:100%;">
                                <el-option
                                    v-for="item in speakerOptionData"
                                    :key="item.deviceId"
                                    :label="item.label"
                                    :value="item.deviceId"
                                    @change="changeSpeakerFunc">
                                </el-option>
                            </el-select>
                        </p>
                        <section class="setting-icon-style">
                            <div style="display:flex;margin-right:5px;"><van-image style="width:24px;height:24px;" :src="hornIconUrl"></van-image></div>
                            <div style="flex-grow:1;"><van-slider button-size="18px" v-model="hornchangeSliderValue" @change="onChangeHornFunc" /></div>
                        </section>
                    </div>
                    <!-- 完成按钮 -->
                    <div class="settingOverlay">
                        <van-button round block type="info" 
                        style="height: 47px;
                        background: #6E63CF;
                        border-radius: 24px;
                        border: 0;" @click="settingOverFunc">完成</van-button>
                    </div>
                </div>
            </div>
        </van-dialog>
        <!-- 上传日志 -->
        <van-dialog v-model="showLogDialog"  style="border-radius: 4px;"
            show-cancel-button 
            confirmButtonText="确定" 
            confirmButtonColor="#7D74D1"
            cancelButtonColor="#616C8F"
            >
            <div class="dialog-container" style="padding:25px;" @click.stop>
                <p style="margin-bottom:5px;
                    font-size: 18px;
                    font-family: PingFang-SC-Medium, PingFang-SC;
                    font-weight: 500;
                    color: #616C8F;">上传日志</p>
                <p style="font-size: 18px;
                    font-family: PingFang-SC-Medium, PingFang-SC;
                    font-weight: 500;
                    color: #616C8F;">ID: {{logInfo}}</p>
            </div>
        </van-dialog>
         <!-- 退出房间 -->
        <van-dialog v-model="showLeaveDialog"  style="border-radius: 4px;"
            show-cancel-button
            confirmButtonText="确定" 
            confirmButtonColor="#7D74D1"
            cancelButtonColor="#616C8F"
            @confirm="stopConferOverlayFunc">
            <div class="dialog-container" style="padding:30px;" @click.stop >
                <p style="margin-bottom:5px;
                    font-size: 18px;
                    font-family: PingFang-SC-Medium, PingFang-SC;
                    font-weight: 500;
                    color: #616C8F;">确定离开房间</p>
            </div>
        </van-dialog>
       
    </div>
</template>

<script>
    import emedia from 'easemob-emedia';
    import whiteBoards from 'easemob-whiteboards' //引入环信白板sdk
    import webIM from '../../config/WebIM' //引入环信聊天功能
    import {mapActions} from 'vuex'
    import {LeaveConference} from '../../api/conference'
    
    export default {
        props:{
            logInfo:{
                default() {
                    return '12345678910256';//引用组件时（:logInfo="???"）如绑定logInfo就使用新值，未绑定就使用默认值
                },
                type:String
            }
        },
        data(){
            return {
                microphoneSliderValue:1,//麦克风音量条的值
                hornchangeSliderValue:50,//扬声器滑块的值
                showSettingOverlay:false,//设置弹窗状态
                showLogDialog:false,//日志弹窗状态
                showLeaveDialog:false,//退出房间弹窗状态
                cameraValue:"",//摄像头
                microphoneValue:"",//麦克风
                speakerValue:"",//扬声器 
                cameraOptionData:[],
                microphoneOptionData:[],
                speakerOptionData:[],
                settingUrl:require("@/assets/setting.png"),
                uploadUrl:require("@/assets/upload.png"),
                exportUrl:require("@/assets/export.png"),
                hornIconUrl:require("@/assets/horn.png"),//喇叭
                microphoneIconUrl:require("@/assets/microphone.png"),//麦克风
                mediaStreamSource : null,
                scriptProcessor : null,
                isRecord : false,
            }
        },
        mounted(){
            this.getDevices();//获取设备
            if (navigator.mediaDevices.getUserMedia || navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia) {
                //唤醒用户媒体设备, 访问摄像头
                navigator.getUserMedia({audio: true,video:true}, this.userMediaSuccess, this.userMediaError);
            } else {
               throw new Error("不支持访问用户媒体摄像头");  
            }
        },
        methods:{
             ...mapActions(['deleteWhiteboard']),

            // 麦克风音量检测
            userMediaSuccess(stream){
                let audioContext = new window.AudioContext();
                // 将麦克风的声音输入这个对象
                this.mediaStreamSource = audioContext.createMediaStreamSource(stream);
                // 创建一个音频分析对象，采样的缓冲区大小为4096，输入和输出都是单声道
                this.scriptProcessor = audioContext.createScriptProcessor(4096,1,1);
                // 将该分析对象与麦克风音频进行连接
                this.mediaStreamSource.connect(this.scriptProcessor);
                // 此举无甚效果，仅仅是因为解决 Chrome 自身的 bug
                this.scriptProcessor.connect(audioContext.destination);

                // 开始处理音频
                this.scriptProcessor.onaudioprocess = (e) => {
                    if(!this.isRecord) {
                        // 获得缓冲区的输入音频，转换为包含了PCM通道数据的32位浮点数组
                        const buffer = e.inputBuffer.getChannelData(0);
                        // 获取缓冲区中最大的音量值
                        const maxVal = Math.max(...buffer);
                        // 显示音量值
                        const mv = Math.round(maxVal * 100);
                        this.microphoneSliderValue = mv;
                    }
                };
            },
            userMediaError(error) {
                console.log(`访问用户媒体设备失败${error.name}, ${error.message}`);
            },
            //获取设备 摄像头 麦克风 扬声器
            async getDevices(){
                // 第一种方法
                const devices = await emedia.mgr.mediaDevices(); //获取设备列表
                // console.log(devices,'===>获取设备列表');
                devices.map(item=>{
                    if (item.kind === "audioinput") { //麦克风
                        // console.log(item,'===>audioinput');
                        let obj = {
                            deviceId :item.deviceId,
                            groupId :item.groupId,
                            label:item.label
                        }
                        this.microphoneOptionData.push(obj);
                        this.microphoneValue = this.microphoneOptionData[0].deviceId;
                   } else if (item.kind === "videoinput") { //摄像头
                        // console.log(item,'===>videoinput');
                        let obj = {
                            deviceId :item.deviceId,
                            groupId :item.groupId,
                            label:item.label
                        }
                        this.cameraOptionData.push(obj);
                        this.cameraValue = this.cameraOptionData[0].deviceId;
                    } else if (item.kind === "audiooutput") {// 扬声器
                        // console.log(item,'===>audiooutput');
                        let obj = {
                            deviceId :item.deviceId,
                            groupId :item.groupId,
                            label:item.label
                        }
                        this.speakerOptionData.push(obj);
                        this.speakerValue = this.speakerOptionData[0].deviceId;
                    } else {
                        console.log("Found one other kind of source/device: ",item);
                    }
                });
                // 第二种方法 原生方法
                // navigator.mediaDevices.enumerateDevices()
                // .then(function(deviceInfos) {
                //         let videoArr = [];//摄像头
                //         let audioArr = [];//麦克风
                //         for (let i = 0; i !== deviceInfos.length; ++i) {
                //             let deviceInfo = deviceInfos[i];
                //             let option = {};
                //             option.id = deviceInfo.deviceId;
                //             if (deviceInfo.kind === "audioinput") {
                //                 option.label = deviceInfo.label;
                //                 audioArr.push(option);
                //             } else if (deviceInfo.kind === "videoinput") {
                //                 option.label = deviceInfo.label;
                //                 videoArr.push(option);
                //             } else {
                //                 console.log("Found one other kind of source/device: ",deviceInfo);
                //             }
                //         }
                //         console.log(videoArr,'===>videoArr')
                //         console.log(audioArr,'===>audioArr')
                // }).catch(function (err) {
                //     console.log(err + '获取摄像头失败');
                // });
            },
            async leaveConfrIdFunc(){
                const {confrId,userName} = this.$store.state.user; 
                const result = await LeaveConference(confrId,userName);
                console.log(result,'===>result');
            },
            //关闭浏览器窗口的时候清空浏览器缓存在localStorage的数据
            clearStorageFunc(){
                let storage = window.localStorage;
                // storage.clear();
                storage.removeItem('userInfo');
                storage.removeItem('conference');
                storage.removeItem('smallConference');
                storage.removeItem('whiteboardUrl');
                storage.removeItem('whiteboards-roomId');
                storage.removeItem('message');
            },
            // 结束会议
            stopConferOverlayFunc(){
                this.$router.push("/");
                const {userName,accessToken} = this.$store.state.user;
                let delWhiteboardObj = {
                    userName: userName,
                    token: accessToken,
                };
                this.deleteWhiteboard(delWhiteboardObj);//删除白板
                this.clearStorageFunc();
                this.leaveConfrIdFunc();
                emedia.mgr.exitConference();//关闭加入的会议 无参数
            },
             // 摄像头下拉数据
            changeCameraFunc(opt){
                this.cameraValue = opt;
            }, 
            // 麦克风下拉数据
            changeMicrophoneFunc (opt){
                this.microphoneValue = opt;
            }, 
            // 扬声器下拉数据
            changeSpeakerFunc(opt){
                this.speakerValue = opt;
            }, 
            
            //调整扬声器音量
            onChangeHornFunc(value){
                console.log("当前值：", value);
                this.hornchangeSliderValue = value;
            },
            // 设置完成按钮
            settingOverFunc(){
                this.showSettingOverlay = false;//关闭设置的弹窗信息
                let obj = {
                    selectCamera:this.cameraValue,
                    selectMicrophone:this.microphoneValue,
                    selectSpeaker:this.speakerValue,
                    microphoneSliderValue:this.microphoneSliderValue,
                    hornchangeSliderValue:this.hornchangeSliderValue,
                };
                this.cameraValue = this.cameraOptionData[0].deviceId;
                this.microphoneValue = this.microphoneOptionData[0].deviceId;
                this.speakerValue = this.speakerOptionData[0].deviceId;
                // this.microphoneSliderValue = 1;
                // this.hornchangeSliderValue = 100;
                this.$emit("handelClick",obj);
            },
        },
        computed:{
            blockVolumFunc(){
                return function(index){
                    return index > this.microphoneSliderValue ? 'background:#CCCCCC':'background:#796FD3'
                }
           
            }
        }
    }
</script>

<style lang="scss" src="./style.scss" scoped></style>
<style lang="scss" >
 .el-input--mini .el-input__inner{
    border: none !important;
    border-bottom: 1px solid #ddd !important;
    border-radius: 0 !important;
    padding: 0 !important;
}
</style>