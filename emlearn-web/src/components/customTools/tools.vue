<template>
  <div class="tools">
        <el-tooltip class="item" effect="light" :content="u85Status ?'开启学生白板':'禁用学生白板'" >
            <van-image style="width:32px;height:32px;" 
                :src="u85Status?u85Open:u85" @click="u85Func(u85Status)"></van-image>
        </el-tooltip>
        <el-tooltip class="item" effect="light" :content="u86Status?'关闭屏幕共享':'开启屏幕共享'">
            <van-image style="width:32px;height:32px;" 
                :src="u86Status?u86Open:u86" @click="u86Func(u86Status)"></van-image>
        </el-tooltip>
        <!-- 云端录制已确定不做 -->
        <!-- <el-tooltip class="item" effect="light" :content="u87Status?'关闭云端录制':'开启云端录制'">
            <van-image style="width:28px;height:28px;" 
                :src="u87Status?u87Open:u87" @click="u87Func(u87Status)"></van-image>
        </el-tooltip> -->
  </div>
</template>

<script>
    import './style.scss'
    import {mapActions} from 'vuex'
    import {SetWhiteStatus} from '../../api/conference'
    import { Toast as VanToast} from 'vant';
    import {GetCur} from '../../api/user'

    export default {
        data(){
            return {
                u85:require("../../assets/u85.png"),
                u85Open:require("../../assets/u85-open.png"),
                u85Status:false,
                u86:require("../../assets/u86.png"),
                u86Open:require("../../assets/u86-open.png"),
                u86Status:false,
                u87:require("../../assets/u87.png"),
                u87Open:require("../../assets/u87-open.png"),
                u87Status:false,
                own_desktop_stream: null, // 老师发起的屏幕共享流，不显示（保存起来，用于停止共享）
            }
        },
        mounted(){
           this.saveAllStopWhiteStatus(false);//初始化本地存储是否全员禁止使用白板
        },
        
        methods:{
            ...mapActions(['saveAllStopWhiteStatus']),

            async u85Func(val){
                const {confrId} = this.$store.state.user;
                if(val){
                    this.u85Status = !this.u85Status;
                    this.$emit('handleClick',0,this.u85Status);
                    this.saveAllStopWhiteStatus(this.u85Status);//只有老师有权限，禁止全员学生操作白板 false为允许操作
                    // SetWhiteStatus(confrId,1,[]).then(res=>{
                    //     if(res.code == 1){
                    //         // VanToast.success("您已解除学生操作白板");
                    //     }
                    // });
                }else{
                    this.u85Status = !this.u85Status;
                    this.$emit('handleClick',0,this.u85Status);
                    this.saveAllStopWhiteStatus(this.u85Status);//只有老师有权限，禁止全员学生操作白板 true为禁止操作
                    // SetWhiteStatus(confrId,-1,[]).then(res=>{
                    //     if(res.code == 1){
                    //         // VanToast.success("您已开启禁止全体学生操作白板");
                    //     }
                    // });
                }
            },
            async u86Func(val){
                if(val){
                    this.u86Status = !this.u86Status;
                    this.$emit('handleClick',1,this.u86Status);
                }else{
                    try {
                        /**
                         * videoConstaints {screenOptions: ['screen', 'window', 'tab']} or true
                         * withAudio： true 携带语音，false不携带  如携带语音，需自己调用关闭流，不会执行 stopSharedCallback 回调
                         * ext 用户自定义扩展，其他成员可以看到这个字段
                         * stopSharedCallback 共享插件 点击【停止共享】的回调函数，做相应的处理（比如删除流...）
                         */
                        let options = {
                            withAudio:true,
                            confrId:this.$store.state.user.confrId,
                            ext:"共享屏幕",
                            stopSharedCallback: item => this.stop_share_desktop(item)
                        };
                        const result = await emedia.mgr.shareDesktopWithAudio(options);
                        if(result){ //老师已开启屏幕共享
                            console.log(result,'===>result')
                            this.u86Status = true;
                            this.$emit('handleClick',1,this.u86Status);
                        }
                        
                    } catch (err) {
                        if( //用户取消也是 -201 所以两层判断
                            err.error == -201 &&
                            err.errorMessage.indexOf('ShareDesktopExtensionNotFound') > 0
                        ){
                            this.$VanToast({
                                message: '请确认已安装共享桌面插件 或者是否使用的 https域名',
                                icon: 'success',
                            });
                        }
                    }
                }
            },
            stop_share_desktop(){
                alert("关闭屏幕共享")
            },
            // 云端录制已确定不做
            async u87Func(val){
                this.$emit('handleClick',2);
                if(val){
                    this.u87Status = false;
                }else{
                     this.u87Status = true;
                }
            },

        }
    }
</script>
