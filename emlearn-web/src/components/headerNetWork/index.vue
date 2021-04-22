<template>
   <div>
        <span>
            <span style="height: 18px;
                    font-size: 12px;
                    font-family: PingFang-SC-Regular, PingFang-SC;
                    font-weight: 400;
                    color: #616C8F;
                    line-height: 18px;">延迟: </span>
           
            <span style="height: 18px;
                    font-size: 12px;
                    font-family: PingFang-SC-Regular, PingFang-SC;
                    font-weight: 500;
                    color: #616C8F;
                    line-height: 18px;" class="title-delayTime">{{delayTime}}ms</span>
        </span>
        <span>
             <span style="height: 18px;
                    font-size: 12px;
                    font-family: PingFang-SC-Regular, PingFang-SC;
                    font-weight: 400;
                    color: #616C8F;
                    line-height: 18px;">网络: </span>
           
            <span style="height: 18px;
                    font-size: 12px;
                    font-family: PingFang-SC-Regular, PingFang-SC;
                    font-weight: 500;
                    color: #616C8F;
                    line-height: 18px;">
                <van-image style="width:28px;height:19px;" :src="onLine?network[5]:network[0]"></van-image>
            </span>
        </span>
   </div>
</template>

<script>
    export default {
        data(){
            return {
                delayTime:"10",//延迟时间
                network:[
                    require("@/assets/network0.png"),
                    require("@/assets/network1.png"),
                    require("@/assets/network2.png"),
                    require("@/assets/network3.png"),
                    require("@/assets/network4.png"),
                    require("@/assets/network5.png"),
                ],
                onLine: navigator.onLine,//判断网络链接
            }
        },
        mounted(){
            this.delayTime = navigator.connection.rtt;//延迟秒数
            if(!this.onLine){
                this.networkAlertOff();
            }
            // 网络由状态改变时触发
            window.addEventListener('online',  this.updateOnlineStatus);
            window.addEventListener('offline', this.updateOnlineStatus);
        },
        beforeDestroy() {
            window.removeEventListener('online',  this.updateOnlineStatus);
            window.removeEventListener('offline', this.updateOnlineStatus);
        },
        methods:{
            //网络,断开状态下的报错信息
            networkAlertOff(){
                this.$VanDialog.alert({
                    title: '警告',
                    message: '网络不给力,请检查网络是否链接',
                }).then(() => {});
            },
            //网络恢复状态下的报错信息
            networkAlertOn(){
                this.$VanDialog.alert({
                    title: '提示',
                    message: '网络已正常',
                }).then(() => {});
            },
            // 判断是否离线状态
            updateOnlineStatus(e) {
                const { type } = e;
                this.onLine = type === 'online';

                if(this.onLine){
                    this.networkAlertOn();
                }else{
                    this.networkAlertOff();
                }
                if(navigator.connection) {
                    navigator.connection.addEventListener('change', this.onConnectionChange);
                }
                //navigator.connection.downlink //表示带宽的估计值 单位是  MB/S
                //navigator.connection.rtt //表示有效的往返时间估计 单位是 ms
                this.delayTime = navigator.connection.rtt;//延迟秒数
            },
            // 只适用于 chrome 网络状态 变化
            onConnectionChange() {
                let { effectiveType } = navigator.connection;
                //console.log(effectiveType,"===>effectiveType");
                switch(effectiveType){
                    case 'slow-2g':
                        console.log("slow-2g");
                        break;
                    case '2g':
                        console.log("2g");
                        break;
                    case '3g':
                        console.log("3g");
                        break;
                    case '4g':
                        console.log("4g");
                        break;
                }
            },
        }

    }
</script>

<style lang="scss" src="./style.scss" scoped></style>
