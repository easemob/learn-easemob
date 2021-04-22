
/**
 * webIM聊天功能
 */
import config from "./WebIMConfig";
import websdk from "easemob-websdk"
import emedia from "easemob-emedia";
// import webrtc from "easemob-webrtc";
import { Toast as VanToast} from 'vant';
function ack(message) {
	var bodyId = message.id; // 需要发送已读回执的消息id
	var msg = new WebIM.message("read", WebIM.conn.getUniqueId());
	msg.set({
		id: bodyId,
		to: message.from
	});
	WebIM.conn.send(msg.body);
}

// 初始化IM SDK
var WebIM = {};
WebIM = window.WebIM = websdk;
WebIM.config = config;
WebIM.conn = new WebIM.connection({
	appKey: WebIM.config.appkey,
	isHttpDNS: WebIM.config.isHttpDNS,
	isMultiLoginSessions: WebIM.config.isMultiLoginSessions,
	https: WebIM.config.https,
	url: WebIM.config.xmppURL,
	apiUrl: WebIM.config.apiURL,
	isAutoLogin: true,
	heartBeatWait: WebIM.config.heartBeatWait,
	autoReconnectNumMax: WebIM.config.autoReconnectNumMax,
	autoReconnectInterval: WebIM.config.autoReconnectInterval,
	isStropheLog: WebIM.config.isStropheLog,
	delivery: WebIM.config.delivery
});
if (!WebIM.conn.apiUrl) {
	WebIM.conn.apiUrl = WebIM.config.apiURL;
}
let mesData = [];//保存所有的聊天记录
let memberData = [];//保存那个成员被禁言的用户iD

// 注册监听回调
WebIM.conn.listen({
	onOpened: function (message) { // 连接成功回调
		//连接成功回调
		let myDate = new Date().toLocaleString();
		console.log(myDate + "登陆成功");
		console.log("%c [opened] 连接已成功建立", "color: green");
	},
	onClosed: function (message) {//连接关闭回调
		console.log("连接关闭回调", message);
	},
	onTextMessage: function (message) {//收到文本消息
		const { from, to, type,data,ext } = message;
		let mesObj = {
			from:from,
			to:to,
			type:type,
			data:data,
			ext:ext,
			time:new Date().getTime()
		};
		mesData.push(mesObj);
		window.localStorage.setItem("message",JSON.stringify(mesData));
		console.log("收到文本消息", message);
	},
	onEmojiMessage: function (message) {//收到表情消息
		console.log("收到表情消息", message);
		console.log("onPicMessage: ", message);
		$("#xxx").append("<div><img src = " + message.url + "/></div>")
	}, 
	onPictureMessage: function (message) {//收到图片消息
		console.log("收到图片消息", message);
	}, 
	onCmdMessage: function (message) { // 收到命令消息
		console.log("onCmdMessage", message);
	},
	onAudioMessage: function (message) {// 收到音频消息
		console.log("收到音频消息", message);
	}, 
	onLocationMessage: function (message) { // 收到位置消息
		console.log("onLocationMessage", message);
	},
	onFileMessage: function (message) {// 收到文件消息
		console.log("收到文件消息", message);
	}, 
	onVideoMessage: function (message) { // 收到视频消息
		console.log("收到视频消息", message);
	},
	onPresence: function (message) {// 处理“广播”或“发布-订阅”消息，如联系人订阅请求、处理群组、聊天室被踢解散等消息
		console.log("处理“广播”或“发布-订阅”消息", message);
		switch(message.type){
			case 'rmChatRoomMute':
			  // 解除聊天室一键禁言
			  console.log('已解除聊天室全员禁言',message)
			  window.localStorage.setItem('allStopChat',false);
			  break;
			case 'muteChatRoom':
			  // 聊天室一键禁言
			  console.log('已开启聊天室全员禁言',message)
			  window.localStorage.setItem('allStopChat',true);
			  break;
			case 'removeMute':
			  // 解除禁言
			  console.log('解除禁言',message)
			//   let memberInfo = JSON.parse(window.localStorage.getItem("memeberStopChat"));
			//   console.log(memberInfo)
			//   if(memberInfo.length > 0){
			// 	memberInfo.map((item, index) => {
			// 		console.log(item)
			// 		console.log(index)
			// 		if(item.to == message.to){
			// 			memberInfo.splice(index, 1)
			// 		}
			// 	});
			//   };
			//   window.localStorage.setItem("memeberStopChat",JSON.stringify(memberInfo));
			  break;
			case 'addMute': 
			  // 禁言
			  	console.log('禁言',message)
				let mesObj = {
					to:message.to,
					type:message.type
				};

				// Vue.$store.commit('addChatMemberBannedFunc',mesObj);
				// memberData.push(mesObj);
				// window.localStorage.setItem("memeberStopChat",JSON.stringify(memberData));
			  break;
			case "memberJoinPublicGroupSuccess": // 成员加入聊天室成功回调
			 console.log('？？？已加入群组',message)
			  break;
			case 'rmUserFromChatRoomWhiteList':
			  // 删除聊天室白名单成员
			  console.log('删除聊天室白名单成员',message)
			  break;
			case 'addUserToChatRoomWhiteList':
			  // 增加聊天室白名单成员
			  console.log('增加聊天室白名单成员',message)
			  break;
			case 'deleteFile':
			  // 删除聊天室文件
			  console.log('删除聊天室文件',message)
			  break;
			case 'uploadFile':
			  // 上传聊天室文件
			  console.log('上传聊天室文件',message)
			  break;
			case 'deleteAnnouncement':
			  // 删除聊天室公告
			  console.log('删除聊天室公告',message)
			  break;
			case 'updateAnnouncement':
			  // 更新聊天室公告
			  console.log('更新聊天室公告',message)
			  break;
			case 'removeAdmin':
			  // 移除管理员
			  console.log('移除管理员',message)
			  break;
			case 'addAdmin':
			  // 添加管理员
			  console.log('添加管理员',message)
			  break;
			case 'changeOwner':
			  // 转让聊天室
			  console.log('转让聊天室',message)
			  break;
			case 'leaveChatRoom':
			  // 退出聊天室
			  console.log('退出聊天室',message)
			  break;
			case 'memberJoinChatRoomSuccess':
			  // 加入聊天室
			  console.log('加入聊天室',message)
			  break;
			case 'leave':
			  // 退出群
			  console.log('退出群',message)
			  break;
			case 'join':
			  // 加入群
			  console.log('加入群',message)
			  break;
			default:
			  break;
		}
	}, 
	onRoster: function (message) {// 处理好友申请
		console.log("处理好友申请", message);
	}, 
	onInviteMessage: function (message) {// 处理群组邀请
		console.log("处理群组邀请", message);
	}, 
	onOnline: function () {
		console.log("onOnline 网络已连接");
	}, // 本机网络连接成功
	onOffline: function () {
		console.log("onOffline 网络已断开");
	}, 
	onError: function (message) {// 本机网络掉线
		console.log(message,'message')
		if (message.type == 0) {
			VanToast.fail("请输入账号密码");
		} else if (message.type == 28) {
			VanToast.fail("webIM未登陆");
		} else if (JSON.parse(message.data.data).error_description == "user not found") {
			VanToast.fail("用户名不存在！");
		} else if (JSON.parse(message.data.data).error_description == "invalid password") {
			VanToast.fail("密码无效！");
		} else if (JSON.parse(message.data.data).error_description == "user not activated") {
			VanToast.fail("用户已被封禁！");
		} else if (message.type == "504") {
			VanToast.fail("消息撤回失败");
		}
		// 报错返回到登录页面
		window.setTimeout(() => {
			window.location.href = "/";
		}, 500)
		// Vue.$router.push({ path: '/login' });
	}, // 失败回调
	onBlacklistUpdate: function (list) {       //黑名单变动
        // 查询黑名单，将好友拉黑，将好友从黑名单移除都会回调这个函数，list则是黑名单现有的所有好友信息
        console.log('黑名单变动',list);
    },
    onRecallMessage: function(message){ //收到撤回消息回调
		console.log("撤回消息", message);
	},     
    onReceivedMessage: function(message){//收到消息送达服务器回执
		console.log("收到消息送达服务器回执", message);
	},    
    onDeliveredMessage: function(message){ //收到消息送达客户端回执
		console.log("收到消息送达客户端回执", message);
	},  
    onReadMessage: function(message){ //收到消息已读回执
		console.log("收到消息已读回执", message);
	},       
    onCreateGroup: function(message){//创建群组成功回执（需调用createGroupNew）
		console.log("创建群组成功回执（需调用createGroupNew）", message);
	},        
	onMutedMessage: function(message){ //如果用户在A群组被禁言，在A群发消息会走这个回调并且消息不会传递给群其它成员
		alert("您已被禁言")
		console.log("如果用户在A群组被禁言，在A群发消息会走这个回调并且消息不会传递给群其它成员", message);
	}       
});

// WebIM.WebRTC = webrtc;
WebIM.EMedia = emedia;
export default WebIM;
