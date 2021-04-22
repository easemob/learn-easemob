import * as net from './iso_network';


const BASE = "https://a1.easemob.com";

let org_name = "1108200509113038"
let app_name = "chatapp"
let register_url = `${BASE}/${org_name}/${app_name}/users`;
let login_url = `${BASE}/${org_name}/${app_name}/token`;


export const Register = (params) => {
    return net.Xhr({
		url: register_url,
        method: 'post',
        body:params,
	}).then((response) => {
		return response
	})
};

export const Login = (params) => {
    return net.Xhr({
		url: login_url,
        method: 'post',
        body:params,
	}).then((response) => {
		return response
	})
};

