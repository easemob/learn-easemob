import * as request from '../utils/request';

export const GetCur = (obj) => {
    let tmpUrl = "/User/GetCur";
    return request.Xhr({
		url: tmpUrl,
		method: 'get',
	}).then((response) => {
		return response
	})
};

export const GetNickName = (confrKey,userName) => {
	let tmpUrl = "/User/GetNickName";
	tmpUrl = request.AppendParam(tmpUrl, 'confrKey',confrKey)  
	tmpUrl = request.AppendParam(tmpUrl, 'userName',userName)  
    return request.Xhr({
		url: tmpUrl,
		method: 'get',
	}).then((response) => {
		return response
	})
};









