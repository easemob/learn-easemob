<template>
     <!-- <van-overlay :show="show" :data="data"> -->
            <div class="stu-window-style" v-show="show" :data="data">
                <div class="stu-container">
                    <!-- 关闭按钮 -->
                    <section class="stu-container-header">
                        <div class="stu-container-header-title">学生列表</div>
                        <div class="stu-container-header-icon"><van-icon name="cross" class="close-icon" @click="closeFunc"/></div>
                    </section>
                 
                    <!-- 面板信息 -->
                    <section  class="stu-container-panel">
                        <div class="stu-container-panel-info">
                                 <div>
                                    <div class="stulist-title">
                                        <p class="stulist-title-name">姓名</p>
                                        <p class="stulist-title-name">白板</p>
                                        <!-- <p class="stulist-title-name">消息</p> -->
                                        <p class="stulist-title-name">语音</p>
                                        <p class="stulist-title-name">视频</p>
                                    </div>
                                    <template v-for="(item,index) in data" >
                                        <!-- 学生列表只显示学生自己，不显示老师 v-if="item.roleType !== 'teacher'-->
                                        <div :key="index" class="stulist-panel" v-if="item.roleType !== 'teacher'">
                                            <p class="stulist-title-name"> {{splitNameFunc(item)}}</p>
                                            <!-- 白板 -->
                                            <p style="width:30%;">
                                                <van-image
                                                    :src="item.setWhiteboard?whiteUrl:closeWhiteUrl" @click="whiteFunc(item,index)" 
                                                    class="block-pointer-white"
                                                />
                                            </p>
                                            <!-- 消息 -->
                                            <!-- <p style="width:30%;">
                                                <van-image
                                                    :src="item.setMessage?chatUrl:closeChatUrl" @click="messageFunc(item,index)" 
                                                    class="block-pointer-message"
                                                />
                                            </p> -->
                                            <!-- 语音 -->
                                            <p style="width:30%;">
                                                <van-image
                                                    :src="item.setAudio?voiceUrl:closeVoiceUrl" @click="voiceFunc(item,index)" 
                                                    class="block-pointer-audio" 
                                                />
                                            </p>
                                            <!-- 视频 --> 
                                            <p style="width:30%;">
                                                <van-image
                                                    :src="item.setVideo?videoUrl:closeVideoUrl" @click="videoFunc(item,index)" 
                                                    class="block-pointer-video"
                                                />
                                            </p>
                                        </div>
                                    </template>
                                </div>
                        </div>
                    </section>
                </div>
            </div>
       <!-- </van-overlay> -->
</template>

<script>
    import {mapActions} from 'vuex'
    export default {
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
                chatStatusOverlay:true,
                voiceUrl:require("@/assets/stu-audio-open.png"),//音频
                   closeVoiceUrl:require("@/assets/stu-audio-close.png"),//关闭音频
                videoUrl:require("@/assets/stu-video-open.png"),//视频
                closeVideoUrl:require("@/assets/stu-video-close.png"),//关闭视频
                whiteUrl:require("../../assets/stu-white-open.png"),//白板
                closeWhiteUrl:require("../../assets/stu-white-close.png"),//关闭白板
                chatUrl:require("@/assets/stu-message-open.png"),// 聊天
                closeChatUrl:require("@/assets/stu-message-close.png"),// 禁止聊天
                /**
                    * true 为禁止操作 false 为允许操作
                    * 白板 setWhiteboard
                    * 消息 setMessage 
                    * 语音 setAudio 
                    * 视频 setVideo
                */
                // data:[
                // { name:"stu1",setWhiteboard:true,setMessage:true,setAudio:true,setVideo:true},
                // ],
            }
        },
        mounted(){
           
        },
        methods:{
            // 关闭窗口
            closeFunc(){
                this.$emit('close');
                this.chatStatusOverlay = false;
            },
            whiteFunc(scope,index){
                this.$emit('set-whiteBorad',scope,index);
                this.data[index].setWhiteboard = this.data[index].setWhiteboard ? false : true;
            },
            messageFunc(scope,index){
                this.$emit('set-message',scope,index);
                this.data[index].setMessage = this.data[index].setMessage ? false : true;
            },
            voiceFunc(scope,index){
                this.$emit('set-audio',scope,index);
                this.data[index].setAudio = this.data[index].setAudio ? false : true;
            },
            videoFunc(scope,index){
                this.$emit('set-vidio',scope,index); 
                this.data[index].setVideo = this.data[index].setVideo ? false : true;
            },
        },
        computed:{
            splitNameFunc(){
                return function(item){
                    if(item.name){
                        return item.name.length > 18 ? item.name.substring(0,10) + '...' : item.name
                    }
                }
            },
        }
    }
</script>

<style lang="scss" src="./style.scss" scoped></style>