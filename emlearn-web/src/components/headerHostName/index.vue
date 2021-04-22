<template>
   <div>
        <span style="font-size: 16px;
            font-family: PingFangSC-Medium, PingFang SC;
            font-weight: 500;
            color: #756BD3;">房间号:{{hostName}}</span>
        <!-- <span class="timing"><i class="el-icon-time"></i></span> -->
        <span class="timing">
            <van-image :src="timeUrl" style="width:10px;height:10px;"></van-image>
        </span>
        <!-- 时间计数器 -->
        <com-time/>
   </div>
</template>

<script>
    import time from '../timeCounter/time'

    export default {
        components:{
            'com-time':time
        },
        data(){
            return {
                hostName:this.$store.state.user.houseName,//房间名称
                timeUrl:require("@/assets/time.png"),
            }
        },
    }
</script>

<style lang="scss" src="./style.scss" scoped></style>
