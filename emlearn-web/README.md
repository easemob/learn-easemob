# hh

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).




==== 一、介绍 ==== 
  白板（Easemob-WhiteBoard）服务端基于sockt.io，页面基于svg.js开发，所以兼容性参考上述两项即可。SDK提供了创建白板、加入白板、销毁白板三个API。加入到白板中的用户都可以在实时共享的画布上运用提供工具进行元素的绘制、拖动等操作，同时支持通过上传图片文档等作为白板页面的背景。  创建白板后会返回一个白板地址链接，客户端通过直接使用页面、ifram 或者 webview等方式集成。
==== 二、集成 ====
	1.引入sdk 
		<script type="text/javascript" src="*/whiteboardsSdk.js"></script>
		任何引入方式都可以，没有限制
	2.初始化
		var WDSdk = new whiteBoards({
			restApi: "http://turn2.easemob.com:8031",
			appKey: "222#111"
		});
	3.API
		有两种方式创建白板：
		1. 通过房间名加入，没有房间创建房间，有房间加入房间
		<code javascript>
			/**
			 * @param {string} roomName 房间名
			 * @param {string} password 房间密码
			 * @param {string} userName im用户名
			 * @param {string} token im登录token
			 * @param {function} suc 成功的回调
			 * @param {function} error 失败的回调
			*/

			WDSdk.join({
				roomName: 'roomName',
				password: 'password',
				userName: 'userName',
				token: 'token',
				suc: (res) => {
					res.whiteBoardUrl; 为白板房间地址
				},
				error: () => {},
			})
		</code>
		
		2.通过单独api去创建、加入
			a.创建白板 (WDSdk.create)
				<code javascript>
				/**
				 * @param {string} roomName 房间名
				 * @param {string} password 房间密码
				 * @param {string} userName im用户名
				 * @param {string} token im登录token
				 * @param {function} suc 成功的回调
				 * @param {function} error 失败的回调
				*/
			
				WDSdk.create({
					userName: 'userName',
					roomName: 'roomName',
					password: 'password',
					token: 'token',
					suc: (res) => {
						window.location = res.whiteBoardUrl;
					},
					error: () => {}
				});
				</code>
			b.加入白板 
				加入白板2中方式分别是：
				1.joinByRoomId 通过已经创建的房间ID加入；
				2.joinByRoomName 通过已经创建的房间名称加入；
				<code javascript>
				/**
				 * 1 通过房间ID加入
				 * @param {string} roomId 房间Id
				 * @param {string} password 房间密码
				 * @param {string} userName im用户名
				 * @param {string} token im登录token
				 * @param {function} suc 成功的回调
				 * @param {function} error 失败的回调
				*/
				WDSdk.joinByRoomId({
					userName: userName,    //im用户名
					roomId: roomId,        //im用户名
					token: "token",         //im登陆后token
					suc: function(res){
						window.location = res.whiteBoardUrl;
					},
					error: function(err){
						console.log("err", err);
					}
				});

				/**
				 * 2 通过房间名加入
				 * @param {string} roomId 房间Id
				 * @param {string} password 房间密码
				 * @param {string} userName im用户名
				 * @param {string} token im登录token
				 * @param {function} suc 成功的回调
				 * @param {function} error 失败的回调
				*/
				WDSdk.joinByRoomName({
					userName: userName,
					roomName: roomName,
					token: "token",
					suc: function(res){
						window.location = res.whiteBoardUrl;  //同joinByRoomId返回
					},
					error: function(err){
						console.log("err", err);
					}
				});
				</code>

		3.销毁白板
			<code javascript>
			WDSdk.destroy({
				roomId: roomId,
				token: "1233",
				suc: function(res){
					console.log(res);
				},
				error: function(err){
					console.log("err", err);
				}
			});
			</code>


