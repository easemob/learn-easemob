import Vue from 'vue';
import Vuex from "vuex";
import WebIM from '../config/WebIM' //引入环信webIM聊天功能
import whiteBoards from 'easemob-whiteboards' //引入环信白板sdk
import { Toast as VanToast} from 'vant';
import { set } from 'core-js/fn/dict';

Vue.use(Vuex);

 //初始化
let whiteBoard = new whiteBoards({
    restApi: 'https://wbrtc.easemob.com',
    appKey: "1108200509113038#chatapp"
});
const store =  new Vuex.Store({
    state:{
        Authorization: window.localStorage.getItem('Authorization') ? window.localStorage.getItem('Authorization') : '',
        user: window.localStorage.getItem('userInfo') ?  {
            houseName:JSON.parse(window.localStorage.getItem('userInfo')).houseName,
            houseType:JSON.parse(window.localStorage.getItem('userInfo')).houseType,
            personType:JSON.parse(window.localStorage.getItem('userInfo')).personType,
            userName:JSON.parse(window.localStorage.getItem('userInfo')).userName,
            nickName:JSON.parse(window.localStorage.getItem('userInfo')).nickName,
            password:JSON.parse(window.localStorage.getItem('userInfo')).password,
            easemobKey:JSON.parse(window.localStorage.getItem('userInfo')).easemobKey,
            easemobPwd:JSON.parse(window.localStorage.getItem('userInfo')).easemobPwd,
            accessToken:JSON.parse(window.localStorage.getItem('userInfo')).accessToken,
            sysToken:JSON.parse(window.localStorage.getItem('userInfo')).sysToken,
            chatId:JSON.parse(window.localStorage.getItem('userInfo')).chatId,
            confrId:JSON.parse(window.localStorage.getItem('userInfo')).confrId,
        } : {},
         // 1v1课会议信息
        conference: window.localStorage.getItem('conference') ?  { 
            confrId:JSON.parse(window.localStorage.getItem('conference')).confrId,
            joinId:JSON.parse(window.localStorage.getItem('conference')).joinId,
            role:JSON.parse(window.localStorage.getItem('conference')).role,
            roleToken:JSON.parse(window.localStorage.getItem('conference')).roleToken,
        } : {},
        // 小班课会议信息
        smallConference: window.localStorage.getItem('smallConference') ?  { 
            confrId:JSON.parse(window.localStorage.getItem('smallConference')).confrId,
            joinId:JSON.parse(window.localStorage.getItem('smallConference')).joinId,
            role:JSON.parse(window.localStorage.getItem('smallConference')).role,
            roleToken:JSON.parse(window.localStorage.getItem('smallConference')).roleToken, 
        } : {},
        // 是否全员禁止学生使用白板 禁止 true 不禁止 false
        allStopWhite:JSON.parse(window.localStorage.getItem('allStopWhite')) ? JSON.parse(window.localStorage.getItem('allStopWhite')) : false,
        whiteboardUrl:window.localStorage.getItem('whiteboardUrl') ? window.localStorage.getItem('whiteboardUrl') : '',
        testArr:[],
        chatStatus:false,//聊天室状态 true禁言状态 fasle 非禁言状态
        memberChatBanned:[],//保存那些成员被禁言了
    },
    getters:{
        getWhiteboardUrl(state){
            return state.whiteboardUrl
        },
        setWhiteboardStatus(state){
            return state.allStopWhite
        },
    },
    mutations:{
        userSysTokenFunc(state, mes) { 
            state.Authorization = mes;
            window.localStorage.setItem('Authorization', mes)
        },
        
        saveUserInfoFunc(state, obj) { 
            state.user.houseName = obj.houseName;
            state.user.houseType = obj.houseType;
            state.user.personType = obj.personType;
            state.user.userName = obj.userName;
            state.user.nickName = obj.nickName;
            state.user.password = obj.password;
            state.user.easemobKey = obj.easemobKey;
            state.user.easemobPwd = obj.easemobPwd;
            state.user.accessToken = obj.accessToken; 
            state.user.sysToken = obj.sysToken; 
            state.user.chatId = obj.chatId;
            state.user.confrId = obj.confrId;
            window.localStorage.setItem('userInfo', JSON.stringify(obj))
        },
        saveConferenceFunc(state, obj) { 
            state.conference.confrId = obj.confrId;
            state.conference.joinId = obj.joinId;
            state.conference.role = obj.role;
            state.conference.roleToken = obj.roleToken;
            window.localStorage.setItem('conference', JSON.stringify(obj))
        },
        saveSmallConferenceFunc(state, obj) { 
            state.smallConference.confrId = obj.confrId;
            state.smallConference.joinId = obj.joinId;
            state.smallConference.role = obj.role;
            state.smallConference.roleToken = obj.roleToken;
            window.localStorage.setItem('smallConference', JSON.stringify(obj))
        },
       
        saveAllStopWhiteFunc(state, flag) { 
            state.allStopWhite = flag;
            window.localStorage.setItem('allStopWhite', flag)
        },
        
        saveWhiteboardUrlFunc(state, url) { 
            state.whiteboardUrl = url;
            window.localStorage.setItem('whiteboardUrl', url)
        },
        
        // 聊天窗口图标的变化
        chatCurStatus(state, flag){
            state.chatStatus = flag;
        },
        addChatMemberBannedFunc(state,obj){
            state.memberChatBanned.push(obj);
            var result = [];
            var obj = {};
            for(var i =0; i<state.memberChatBanned.length; i++){
                if(!obj[state.memberChatBanned[i].to]){
                    result.push(state.memberChatBanned[i]);
                    obj[state.memberChatBanned[i].to] = true;
                }
            }
            console.log(result);
        },
        removeChatMemberBannedFunc(state,obj){
            if(state.memberChatBanned.length > 0){
                state.memberChatBanned.map((item, index) => {
                    if(item.stream.id == obj.id ){
                        state.memberChatBanned.splice(index, 1)
                    }
                });
            }
        }
    },
    actions:{
        userSysTokenFuncAsync(context, data) {
            context.commit('userSysTokenFunc', data)
        },
       
        // 是否老师禁止全员学生操作白板 老师有权限 
        saveAllStopWhiteStatus(context,payload){
            context.commit('saveAllStopWhiteFunc',payload);
        },
        // 保存1v1课会议信息
        initConferenceInfo(context, payload){
            context.commit('saveConferenceFunc',payload);
        },
        // 保存小班课会议信息
        initSmallConferenceFunc(context, payload){
            context.commit('saveSmallConferenceFunc',payload);
        },

        // whiteBoard白板======================================START
        // 创建白板
        initWhiteBoard(context, payload){
            whiteBoard.join({
                    roomName: payload.houseName,
                    password: payload.password,
                    userName: payload.userName,
                    //level: 1,
                    layout:0,//默认0；0-底部，1-右侧，2-顶部
                    ratio:payload.houseType == '一对一' ? "2:1" :"3:1", //白板初始化尺寸：2:1（1V1）；3:1（小班课）
                    token: payload.accessToken, //应该为im用户登录之后的token 当前未设置
                    suc: (res) => {
                        if(res.status){// 白板创建成功
                           context.commit("saveWhiteboardUrlFunc",res.whiteBoardUrl);
                           window.localStorage.setItem("whiteboards-roomId",res.roomId);// roomId 保存创建成功的白板房间id
                        }
                    },
                    err: () => {
                        VanToast.fail("创建白板失败");
                        // 报错返回到登录页面
                        window.setTimeout(() => {
                            window.location.href = "/";
                        }, 500)
                    },
                })
        },
        
        // 允许单个成员操作白板
        allowOprate(context, payload){
            console.log(payload,'store')
            whiteBoard.oprateAuthority({
                userName: payload.userName,
				roomId: window.localStorage.getItem("whiteboards-roomId"),
                // members:[],
                members:payload.members,
                leval: 4,  //leval 4-8允许互动/1-3禁止互动
				isAll: false,
				token: payload.accessToken,
				suc: function(res){
                    console.log(res,'允许互动-res');
                    if(res.status){
                        VanToast.success('您已解除该成员禁止操作白板');
                    }
                },
                err: function(err){
                    console.log(err);
                    if(err.error_code == 10){
                        VanToast.fail("白板不存在");
                    }
                    else{
                        console.log(err);
                        VanToast.fail("操作白板失败");
                    }
                }
            })

        },
        // 开启单个成员禁止操作白板
        forbiteOprate(context, payload){ 
            whiteBoard.oprateAuthority({
                userName: payload.userName,
				roomId: window.localStorage.getItem("whiteboards-roomId"),
                // members:[],//操作的权限用户名数组，当isAll为true，此参数不生效，所以设置此参数时需设置isAll=false
                members:payload.members,//操作的权限用户名数组，当isAll为true，此参数不生效，所以设置此参数时需设置isAll=false
                leval: 1,  //leval 4-8允许互动/1-3禁止互动
				isAll: false,//isAll ture时操作对象为房间所有成员，默认为true
				token: payload.accessToken,
				suc: function(res){
                    console.log(res,'禁止互动-res');
                    if(res.status){
                        VanToast.success('您已开启该成员禁止操作白板');
                    }
                },
                err: function(err){
                    console.log(err);
                    if(err.error_code == 10){
                        VanToast.fail('白板不存在');
                    }
                    else{
                        console.log(err);
                        VanToast.fail('操作白板失败');
                    }
                }
            })
        },
        // 允许全体成员操作白板
        allowOprateAll(context, payload){
            whiteBoard.oprateAuthority({
                userName: payload.userName,
				roomId: window.localStorage.getItem("whiteboards-roomId"),
                members:[],
                leval: 4,  //leval 4-8允许互动/1-3禁止互动
				isAll: true,
				token: payload.accessToken,
				suc: function(res){
                    console.log(res,'允许互动-res');
                    if(res.status){
                        VanToast.success('您已解除全员禁止操作白板');
                    }
                },
                err: function(err){
                    console.log(err);
                    if(err.error_code == 10){
                        VanToast.fail("白板不存在");
                    }
                    else{
                        console.log(err);
                        VanToast.fail("操作白板失败");
                    }
                }
            })

        },
        // 开启全体成员禁止操作白板
        forbiteOprateAll(context, payload){ 
            whiteBoard.oprateAuthority({
                userName: payload.userName,
				roomId: window.localStorage.getItem("whiteboards-roomId"),
                members:[],//操作的权限用户名数组，当isAll为true，此参数不生效，所以设置此参数时需设置isAll=false
                //members:payload.members,//操作的权限用户名数组，当isAll为true，此参数不生效，所以设置此参数时需设置isAll=false
                leval: 1,  //leval 4-8允许互动/1-3禁止互动
                // isAll: false,//isAll ture时操作对象为房间所有成员，默认为true
				isAll: true,//isAll ture时操作对象为房间所有成员，默认为true
				token: payload.accessToken,
				suc: function(res){
                    console.log(res,'禁止互动-res');
                    if(res.status){
                        VanToast.success('您已开启全员禁止操作白板');
                    }
                },
                err: function(err){
                    console.log(err);
                    if(err.error_code == 10){
                        VanToast.fail('白板不存在');
                    }
                    else{
                        console.log(err);
                        VanToast.fail('操作白板失败');
                    }
                }
            })
        },
        // 删除白板
        deleteWhiteboard(context, payload){
            const roomId = window.localStorage.getItem('whiteboards-roomId');
            whiteBoard.destroy({
				userName: payload.userName,
				roomId: roomId,
				token: payload.accessToken,
				suc: function(res){
                    console.log("删除白板成功")
					// VanToast.success("删除白板成功");
                },
                err: function(err){
                    console.log("删除白板失败")
                    // VanToast.fail("删除白板失败");
                }
			})
        },
        // whiteBoard白板======================================END

        // webIM聊天相关======================================START
        // login WebIM
        onLogin: function (context, payload) {
            context.commit("saveUserInfoFunc", payload);
            WebIM.conn.open({ //使用用户名/用户密码登录环信 Web IM 
                apiUrl: WebIM.config.apiURL,
                user: payload.userName,
                pwd: 1,
                appKey: WebIM.config.appkey,
                success(token) {
                    console.log(token,'===>token登录webim成功')
                },
                error: e => {
                    console.log(e,'===>token登录webim失败')
                }
            })
        },
        // loginout WebIM
		onLogout: function (context) {
			context.commit("saveUserInfoFunc", "");
			localStorage.removeItem("userInfo");
        },
        // register WebIM
		onRegister: function (context, payload) {
			var options = {
				apiUrl: WebIM.config.apiURL,
				username: payload.username,
				password: payload.password,
				nickname: payload.nickname,
				appKey: WebIM.config.appkey,
				success: (res) => {
                    console.log('注册成功', res)
				},
				error: (err) => {
                    console.log('注册失败', err)
					if (
                        (err.data).error == "duplicate_unique_property_exists") {
						Message.error("用户已存在！")
					} else if (JSON.parse(err.data).error == "illegal_argument") {
						Message.error("用户名不合法！")
					} else if (JSON.parse(err.data).error == "unauthorized") {
						Message.error("注册失败，无权限！")
					} else if (JSON.parse(err.data).error == "resource_limited") {
						Message.error("您的App用户注册数量已达上限,请升级至企业版！")
					}
				}
			};
			WebIM.conn.registerUser(options);
        },
        //加入聊天室
        joinRoom(payload) {
            setTimeout(() => {
                WebIM.conn.joinChatRoom({
                    roomId: payload.state.user.chatId, // 聊天室id
                    success: function (res) {
                        console.log('加入聊天室成功', res)
                    }
                });
            }, 100);
        },
        //查询好友列表
        queryFriendsList() {
            WebIM.conn.getRoster().then( (res) => {
                console.log("res", res);
            });
        },
        //退出聊天室
        quitRoom(payload) {
            WebIM.conn.quitChatRoom({
                roomId: payload.state.user.chatId,// 聊天室id
                success: function (res) {
                    console.log('退出聊天室成功', res)
                }
            });
        },
      
        //获取聊天室列表
        getRoomsList() {
            let option = {
                pagenum: 1,                                 // 页数
                pagesize: 20,                               // 每页个数
                success: function (res) {
                    console.log('获取聊天室列表成功', res);
                },
                error: function (err) {
                    console.log('获取聊天室列表失败', err);
                }
            };
            WebIM.conn.getChatRooms(option);
        },
        //获取聊天室详情
        getRoomsList(payload) {
            let options = {
                chatRoomId: payload.state.user.chatId   // 聊天室id
            }
            WebIM.conn.getChatRoomDetails(options).then((res) => {
                console.log(res)
            })
        },
       
        //获取聊天室成员
        getRoomsMember(payload) {
                setTimeout(() => {
                    WebIM.conn.listChatRoomMember({
                        pageNum: 1,
                        pageSize: 10,
                        chatRoomId: payload.state.user.chatId,
                        success: function (res) {
                            console.log('获取聊天室成员', res)
                            let dataIm = res.data;
                            dataIm.map(item=>{
                                if(item.owner){
                                    let obj = {
                                        owner:item.owner,
                                        status:false //是否被禁言 true禁言 false未禁言
                                    };
                                    payload.state.testArr.push(obj);
                                }else if(item.member){
                                    let obj = {
                                        member:item.member,
                                        status:false //是否被禁言 true禁言 false未禁言
                                    };
                                    payload.state.testArr.push(obj);
                                }
                            });
                            // window.localStorage.setItem("chatMember",JSON.stringify(res.data));
                            window.localStorage.setItem("chatMember",JSON.stringify(payload.state.testArr));
                        },
                        error: function (err) {
                            console.log('获取聊天室成员失败', err)
                        }
                    })
                }, 100);
        },
        //上传/修改聊天室公告
        setChatroomAnnouncement(payload) {
            let options = {
                roomId: payload.state.user.chatId,            // 群组id   
                announcement: 'test Announcement',        // 公告内容                        
                success: function (res) {
                    console.log('设置群公告成功', res)
                },
                error: function (err) {
                    console.log('设置群公告失败', err)
                }
            };
            WebIM.conn.updateChatRoomAnnouncement(options);
        },
        //获取聊天室公告
        getChatroomAnnouncement(payload) {
            let options = {
                roomId: payload.state.user.chatId,            // 群组id                          
                success: function (res) {
                    console.log('获取群公告成功', res)
                },
                error: function (err) {
                    console.log('获取群公告失败', err)
                }
            };
            WebIM.conn.fetchChatRoomAnnouncement(options);
        },
        //将成员禁言
        setChatroomMute(payload,obj) {
            return new Promise(function(resolve, reject){
                let options = {
                    chatRoomId: payload.state.user.chatId,//聊天室id
                    username: obj.username,         // 成员用户名
                    muteDuration: -1000,               // 禁言的时长，单位是毫秒 -1000 是永久
                    success: function (res) {
                        resolve(res);
                        VanToast.success("您已将成员禁言");
                    },
                    error: function (err) {
                        console.log('成员禁言失败', err);
                        VanToast.fail("成员禁言失败");
                    }
                };
                WebIM.conn.muteChatRoomMember(options);
            });
        },
        //将成员解除禁言
        removeRoomMute(payload,obj) { 
            return new Promise(function(resolve, reject){
                let options = {
                    chatRoomId: payload.state.user.chatId,// 聊天室id
                    username: obj.username,       // 成员用户名
                    success: function (res) {
                        resolve(res);
                        VanToast.success("您已将成员解除禁言");
                    },
                    error: function (err) {
                        console.log('解除成员禁言失败', err);
                        VanToast.fail("解除成员禁言失败");
                    }
                };
                WebIM.conn.removeMuteChatRoomMember(options);
            });
        },
        //获取聊天室禁言列表
        getRoomMuteList(payload) {
            return new Promise(function(resolve, reject){
                let options = {
                    chatRoomId: payload.state.user.chatId, // 群组ID
                    success: function (res) {
                        console.log('获取禁言列表成功', res)
                        resolve(res);
                    },
                    error: function (err) {
                        console.log('获取禁言列表失败', err)
                    }
                };
                WebIM.conn.getChatRoomMuted(options);
            });
        },
        //开启聊天室全员禁言
        setMuteAll(payload) { 
            return new Promise(function(resolve, reject){
                let options = {
                    chatRoomId: payload.state.user.chatId, //群组id
                    success: function (res) {
                        resolve(res);
                        VanToast.success("您已开启全员禁言");
                    },
                    error: function (err) {
                        console.log('全员禁言失败', err);
                    }
                };
                WebIM.conn.disableSendChatRoomMsg(options);
            });
        },
        //关闭聊天室全员禁言
        removeMuteAll(payload) {
            return new Promise(function(resolve, reject){
                let options = {
                    chatRoomId: payload.state.user.chatId, //群组id
                    success: function (res) {
                        resolve(res);
                        VanToast.success("您已解除全员禁言");
                    },
                    error: function (err) {
                        console.log('解除全员禁言失败', err)
                    }
                };
                WebIM.conn.enableSendChatRoomMsg(options)
            });
        },
        //拉取漫游消息
        getHistory(payload) {
            var options = {
                queue: payload.state.user.chatId,//对方用户id（如果用户id内含有大写字母请改成小写字母）/群组id/聊天室id
                isGroup: true,// 是否是群聊，默认为false
                count: 10,// 每次拉取条数
                success: function (res) {
                    console.log('拉取消息成功', res)
                },
                fail: function (err) {
                    console.log('拉取消息成功', err)
                }
            }
            WebIM.conn.fetchHistoryMessages(options)
        },
        //将用户添加到白名单
        setRoomWhite() {
            let options = {
                chatRoomId: gid, //群组id
                users: [toID], //成员id列表
                success: function (res) {
                    console.log('添加群组白名单成功', res)
                },
                error: function (err) {
                    console.log('添加群组白名单失败', err)
                }
            };
            WebIM.conn.addUsersToChatRoomWhitelist(options);
        },
        //将用户在白名单移除
        removeRoomWhite() {
            let options = {
                chatRoomId: gid, //群组id
                userName: toID, //要移除的成员
                success: function (res) {
                    console.log('移除群组白名单成功', res)
                },
                error: function (err) {
                    console.log('移除群组白名单失败', err)
                }
            }
            WebIM.conn.rmUsersFromChatRoomWhitelist(options)
        },
        //获取聊天室白名单列表
        getRoomWhiteList() {
            let options = {
                chatRoomId: gid, //群组id
                userName: toID, //要查询的成员
                success: function (res) {
                    console.log('查询成功', res)
                },
                error: function (err) {
                    console.log('查询失败', err)
                }
            }
            WebIM.conn.getChatRoomWhitelist(options)
        },
        //查看成员是否为白名单用户
        getRoomMemberWhite() {
            let options = {
                chatRoomId: gid, //群组id
                userName: toID, //要查询的成员
                success: function (res) {
                    console.log('查询成功', res)
                },
                error: function (err) {
                    console.log('查询失败', err)
                }
            }
            WebIM.conn.isChatRoomWhiteUser(options)
        },
        //获取聊天室黑名单列表
        getRoomBlack() {
            let option = {
                chatRoomId: gid,
                success: function (res) {
                    console.log('查询群组黑名单成功', res)
                },
                error: function (err) {
                    console.log('查询群组黑名单失败', err)
                }
            };
            WebIM.conn.getChatRoomBlacklistNew(option);
        },
        //将成员加入到聊天室黑名单  /单个
        setRoomBlack() {
            let options = {
                chatRoomId: gid,                     // 群组ID
                username: toID,                         // 将要被加入黑名单的用户名
                success: function (res) {
                    console.log('加入群组黑名单成功', res)
                },
                error: function (err) {
                    console.log('加入群组黑名单失败', err)
                }
            };
            WebIM.conn.chatRoomBlockSingle(options);
        },
        //将成员移除聊天室黑名单  /单个
        removeRoomBlack() {
            let options = {
                chatRoomId: gid,                     // 群组ID              
                username: toID,                             // 需要移除的用户名
                success: function (res) {
                    console.log('移除群组黑名单成功', res)
                },
                error: function (err) {
                    console.log('移除群组黑名单失败', err)
                }
            }
            WebIM.conn.removeChatRoomBlockSingle(options);
        },
        // webIM聊天相关=======================================END
    },
})
export default store;