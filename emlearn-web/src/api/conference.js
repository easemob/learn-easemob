import * as request from '../utils/request';

export const Entry = (obj) => {
    let tmpUrl = "/Conference/Entry";
    let params = {
        "username":obj.username,
        "password":obj.password,
        "name":obj.name,
        "role":obj.role,
        "confrType":obj.confrType,
    }
    return request.Xhr({
		url: tmpUrl,
		method: 'post',
		body:params,
	}).then((response) => {
		return response
	})
};

/**
 * 
 * @param {会议ID} confrId 
 * @param {用户名称} userName 
 */
export const LeaveConference = (confrId,userName) => {
  let tmpUrl = "/Conference/Leave";
  let params = {
    "confrId":confrId,
    "userName":userName,
  }
  return request.Xhr({
  url: tmpUrl,
  method: 'post',
  body:params,
}).then((response) => {
  return response
})
};



export const GetConfrOper = (confrId) => {
    let tmpUrl = "/Conference/GetConfrOper";
    tmpUrl = request.AppendParam(tmpUrl, 'confrId',confrId)  
    return request.Xhr({
		url: tmpUrl,
		method: 'get',
	}).then((response) => {
		return response
	})
};

/**
 * 设置聊天室禁言/解除禁言
 * @param {会议ID} confrId 
 * @param {用户ID} userNames   userNames[] 全体静音，否则指定某个角色静音['']
 * @param {用户ID} isOpen     参数1 解除禁言 参数-1 全体禁言
 */
export const SetChatroomMute = (confrId,isOpen,userNames) => {
    let tmpUrl = "/Conference/SetChatroomMute";
    let params = {
        "confrId":confrId,
        "isOpen":isOpen,
        "userNames":userNames,
    }
    return request.Xhr({
      url: tmpUrl,
      method: 'post',
      body:params,
  }).then((response) => {
    return response
  })
};

/**
 * 设置白班开启/关闭
 * @param {会议ID} confrId 
 * @param {用户ID} userNames   userNames[] 全体静音，否则指定某个角色静音['']
 * @param {用户ID} isOpen     参数1 开启白板 参数-1 关闭白板
 */
export const SetWhiteStatus = (confrId,isOpen,userNames) => {
  let tmpUrl = "/Conference/SetWhiteStatus";
  let params = {
      "confrId":confrId,
      "isOpen":isOpen,
      "userNames":userNames,
  }
  return request.Xhr({
    url: tmpUrl,
    method: 'post',
    body:params,
}).then((response) => {
  return response
})
};

/**
 * 设置白班开启/关闭
 * @param {会议ID} confrId 
 * @param {用户ID} userName   用户
 * @param {用户ID} role     role设置角色 3主播 7管理员
 */
export const SetRole = (confrId,role,userName) => {
  let tmpUrl = "/Conference/Role";
  let params = {
      "confrId":confrId,
      "role":role,
      "userName":userName,
  }
  return request.Xhr({
    url: tmpUrl,
    method: 'post',
    body:params,
}).then((response) => {
  return response
})
};






