<template>
  <div style="background: #8A81DE;height: 100%;width: 100%;position: fixed;">
    <section style="display: flex;align-items: center;justify-content:flex-end;font-family:PingFang-SC-Medium,PingFang-SC;">
      <div style="text-align:center;margin:0 1rem;">
          <el-popover
            placement="bottom"
            trigger="hover">
            <img :src="androidCode" alt="安卓" title="安卓" style="width: 208px;height:208px;">
          <el-button type="text" slot="reference" style="font-size: 12px;color:#fff;">安卓版</el-button>
        </el-popover>
      </div>

      <div style="text-align:center;margin:0 1rem;">
          <el-popover
            placement="bottom"
            trigger="hover">
            <img :src="iosCode" alt="苹果" title="苹果" style="width: 208px;height:208px;">
          <el-button type="text" slot="reference" style="font-size: 12px;color:#fff;">苹果版</el-button>
        </el-popover>
      </div>
      <div></div>
    </section>

    <section style="width:52rem;height:460px;
     font-family: PingFang-SC-Medium, PingFang-SC;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);">
      <section style="background:#fff;border-radius:12px;display: flex; align-items: center;">
        <div style="position:relative">
          <p style="position:absolute;top:41px;left:41px;color:#9A93E8;">
           <img :src="logoTextloginUrl" alt="" style="width:71px;height: 25px;">
           <span style="margin: 0 8px;">|</span>
           <span>教育 Demo</span>
          </p>
          <img :src="formLeftImg" alt="" style="height:440px;">
        </div>
        
        <div class="login">
         <el-form class="form" :model="ruleForm" :rules="rules" :label-position="labelPosition" size="mini"
            ref="ruleForm" >
            <el-form-item label="房间名称/room" prop="room"  >
              <el-input v-model="ruleForm.room" class="input_size"></el-input>
            </el-form-item>
            <el-form-item label="房间密码/Key" prop="password">
              <el-input v-model="ruleForm.password" :type="pwdStatus?'password':'text'" class="input_size">
                  <img
                    :src="pwdStatus?pwdHide:pwdShow"
                    slot="suffix"
                    alt=""
                    style="padding-right:5px;width:18px;height:12px;"
                    @click="pwdStatus=!pwdStatus"
                  >
              </el-input>
            </el-form-item>
            <el-form-item label="房间类型/Class" prop="roomType">
              <el-select v-model="ruleForm.roomType" placeholder="请选择" class="input_size">
                <el-option label="一对一" value="one"></el-option>
                <el-option label="小班课" value="small"></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="用户名称/Name" prop="userName">
              <el-input v-model="ruleForm.userName" class="input_size"></el-input>
            </el-form-item>
            <el-form-item style="text-align: center;" prop="personType">
              <el-radio-group v-model="ruleForm.personType">
                <el-radio label="老师"></el-radio>
                <el-radio label="学生"></el-radio>
              </el-radio-group>
            </el-form-item>
            <el-form-item style="text-align:center;">
              <el-button style="width:100%;height:32px;background:linear-gradient(178deg, #8F86E3 0%, #7066D1 100%);color:#fff;" @click="submitForm('ruleForm')">加入房间</el-button>
            </el-form-item>
          </el-form>
        </div>

      </section>
      
      <section style="width:100%;">
        <p class="footer_text">©本产品由环信提供<span style="margin:0 0.75rem;">当前版本:</span>1.4.1</p>
      </section>
    </section>
    
  </div>
</template>

<script>
import {mapActions} from 'vuex'
import { Entry } from "@/api/conference"

export default {
  data() {
    return {
      labelPosition: 'top',
      iosCode:require("../../assets/ios.png"),//ios下载二维码
      androidCode:require('../../assets/android.png'),//安卓下载二维码
      formLeftImg:require("@/assets/form-left.png"),
      titleLogoUrl:require("@/assets/logo-text-login.png"),
      loginLogoUrl:require("@/assets/logo.png"), 
      logoTextloginUrl:require("@/assets/form-left-text.png"), 
      pwdShow:require("@/assets/pwd-show.png"), 
      pwdHide:require("@/assets/pwd-hide.png"), 
      pwdStatus:true,
      ruleForm: {
          room: '',
          password: '', 
          roomType: '',
          userName: '',
          personType:'老师'
      },
      rules: { 
        room: [{ required: true, message: "请输入房间名", trigger: "focus" }],
        password: [{ required: true, message: "请输入房间密码", trigger: "focus" }],
        roomType: [{ required: true, message: "请输入房间类型", trigger: "focus" }],
        userName: [{ required: true, message: "请输入用户名称", trigger: "focus" }],
      },
      userSaved: false,
      sending: false,
    };
  },
  created() {
    //回车键登录
    let that = this;
    document.onkeypress = function (e) {
      let keycode = document.all ? event.keyCode : e.which;
      if (keycode == 13) {
        that.submitForm("ruleForm"); // 登录方法名
        return false;
      }
    };
  },
  mounted(){
    
  //  location.reload();
  },
  destroyed() {
  
  },
  methods: {
    ...mapActions(['userSysTokenFuncAsync','onLogin','initWhiteBoard']),
      submitForm(formName) {
        this.$refs[formName].validate((valid) => {
          if (valid) {
            let paramsObj = {
              name:this.ruleForm.room,
              username: this.ruleForm.userName,
              password: this.ruleForm.password,
              role:this.ruleForm.personType == "老师" ? "teacher" : "student",
              confrType:this.ruleForm.roomType == "one" ? "one" : "small"
            };
            let storage = window.localStorage;
            storage.removeItem('userInfo');
            storage.removeItem('conference');
            storage.removeItem('smallConference');
            storage.removeItem('whiteboardUrl');
            storage.removeItem('whiteboards-roomId');
            storage.removeItem('message');
            storage.removeItem('chatMember');
            storage.removeItem('memeberStopChat');

            
            Entry(paramsObj).then((data) => {
                if(data){
                  if(data.code == 1){
                    let name = data.data.EmName;
                    let access_token = data.data.EmToken;
                    let chatId = data.data.EmChatId;
                    let confrId = data.data.EmconfrId;
                    let sysToken = data.data.SysToken;

                    let userObj = {
                      houseName:this.ruleForm.room,//房间名称
                      houseType:this.ruleForm.roomType == "one" ? "一对一" : "小班课",//房间类型 1v1 小班课
                      personType:this.ruleForm.personType == "老师" ? "teacher" : "students",//老师or学生
                      userName:name,
                      nickName: this.ruleForm.userName,
                      //password:1,
                      password:this.ruleForm.password,
                      easemobKey:'',
                      easemobPwd:'',
                      accessToken:access_token,
                      sysToken:sysToken,
                      chatId:chatId,
                      confrId:confrId,
                    };
                    this.onLogin(userObj);
                    this.initWhiteBoard(userObj);//初始化环信互动白板
                    this.userSysTokenFuncAsync(sysToken);
                    setTimeout(() => {
                      this.$router.push("/Index");
                    }, 1000);
                  } 
                }
            });
          } else {
            console.log('error submit!!');
            return false;
          }
        });
      },
     
  }
};
</script>

<style lang="scss" src="./style.scss" scoped></style>
 