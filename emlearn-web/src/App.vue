<template>
  <div id="app" v-cloak>
      <router-view />
  </div>
</template>
<script>
import $ from 'jquery'; //在需要使用的页面中
export default {
  data() {
    return {
    
    };
  },
  mounted() {
    // 关闭前发起退出登录请求，必须使用原生或者$ajax发同步，axios不支持同步
    let beginTime = 0; //开始时间
    let differTime = 0; //时间差
    window.onunload = function() {
      differTime = new Date().getTime() - beginTime;
      if (differTime <= 5) {
        console.log("浏览器关闭");
        const {confrId,userName} = this.$store.state.user; 
        let list = {
          "confrId":confrId,
          "userName":userName,
        };
        let token = 'Bearer '+ localStorage.getItem('Authorization');
        $.ajax({
            type : "POST", //请求方式
            async: false, // fasle表示同步请求，true表示异步请求
            contentType: "application/json;charset=UTF-8", 
            url : "https://cgame.bjictc.com/Conference/Leave",
            data : JSON.stringify(list),
            headers: {
              Authorization:token
            },
            success : function(result) { //请求成功
              console.log(result);
            },
            error : function(e){  //请求失败，包含具体的错误信息
              console.log(e.status);
            }
        });
      } else {
        console.log("浏览器刷新");
        
      }
    };
    window.onbeforeunload = function() {
      beginTime = new Date().getTime();
    };
  },
 
  methods: {
    
  },
};
</script>
<style lang="scss">

  #app {
    font-family: "Avenir", Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    color: #2c3e50;
    height: 100%;
    width: 100%;
  }
  //防止页面出现绑定的变量名
  [v-cloak] {
    display: none;
  }
 
  //解决苹果电脑无法出现滚动条的问题
  ::-webkit-scrollbar{
      // width: 2px;
      // height: 2px;
    }

  ::-webkit-scrollbar-thumb{
    //border-radius: 1em;
    background-color: rgba(50,50,50,.3);
  }

  ::-webkit-scrollbar-track{
    //border-radius: 1em;
    background-color: rgba(50,50,50,.1);
  }
  //解决苹果电脑无法出现滚动条的问题
  /**
  * 统一设置输入框下边距的尺寸
  */
  .el-form-item {
      // margin-bottom: 16px !important;   //element的原始尺寸为 margin-bottom: 22px
  }
  /**
  * 统一设置输入框的尺寸
  */
  .input_size{
    width:280px !important;
  }
  .van-overlay {
      background-color: #6A7596;
      opacity: 0.9;
  }
.van-slider {
    height: 8px !important;
    border-radius: 4px !important;
}
.van-slider__bar {
    background-color: #7367D0 !important;
}
.van-slider__button {
    background-color: #837AD7 !important;
}
</style>
