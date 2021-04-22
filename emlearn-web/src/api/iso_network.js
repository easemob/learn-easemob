import Axios from 'axios'




// 创建axios实例
const isolatedAxios = Axios.create({
    timeout: 10000,  // 请求超时时间
    headers: {
        'Content-Type': 'application/json',
    }                                  
})
isolatedAxios.defaults.withCredentials = false; //跨域安全策略




function Xhr({ url, body = null, method = 'get' }) {
    if (method == "get") {
        return isolatedAxios
            .get(url)
            .then(response => {
                return response.data;
            })
            .catch('');
    } else if (method == "post") {
        return isolatedAxios
            .post(url, body)
            .then(response => {
                return response.data;
            })
            .catch('');
    } else {
        throw new TypeError("not support method", method)
    }
}

function AppendParam(url, name, value) {
    if (url && name) {
        name += '=';
        if (url.indexOf(name) === -1) {
            if (url.indexOf('?') !== -1) {
                url += '&';
            } else {
                url += '?';
            }
            url += name + encodeURIComponent(value);
        }
    }
    return url;
}

export {Xhr,AppendParam};