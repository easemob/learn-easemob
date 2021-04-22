<template>
    <span style="font-size: 12px;
    font-family: PingFangSC-Regular, PingFang SC;
    font-weight: 400;
    color: #616C8F;">{{timingH}}:{{timingM}}:{{timingS}}</span>
</template>

<script>
    export default {
        data(){
            return {
                timingH:"00",
                timingM:"00",
                timingS:"00",
            }
        },
        mounted(){
            this.timeCounter();
        },
        methods:{
             //时分秒时间计数器
            timeCounter(){
                let count = 0
                let timer = null //timer变量记录定时器setInterval的返回值
                let that = this;
                timer = setInterval(function() {
                    count++;
                    that.timingS = that.showNum(count % 60)
                    that.timingM = that.showNum(parseInt(count / 60) % 60)
                    that.timingH = that.showNum(parseInt(count / 60 / 60))
                }, 1000);
            },
            //封装一个处理单位时间数字的函数
            showNum(num) {
                if (num < 10) {
                    return '0' + num
                }
                return num
            },
         }
    }
</script>

<style lang="scss" scoped></style>