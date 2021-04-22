import Vue from 'vue'
import Axios from 'axios'
// 按需引入element-ui组件
import { Message } from 'element-ui';

let needLoadingRequestCount = 0; //需要loading请求个数
let loading = "";

//声明一个对象用于存储合并请求个数
function showFullScreenLoading() {
    if (needLoadingRequestCount === 0) {
        startLoading();
    }
    needLoadingRequestCount++;
}

function tryHideFullScreenLoading() {
    if (needLoadingRequestCount <= 0) return;
    needLoadingRequestCount--;
    if (needLoadingRequestCount === 0) {
        endLoading();
    }
}

function startLoading() {
    loading = Vue.prototype.$loading({
        lock: true,
        text: "加载中...",
        spinner: "el-icon-loading",
        background: "rgba(0, 0, 0, 0.3)"
    });
    return loading
}

function endLoading() {
    loading.close();
}

// 创建axios实例
const axios = Axios.create({
    baseURL: process.env.VUE_APP_URL,// process.env.NODE_ENV 会自动区分是开发环境还是生产环境，会自动切换对应的VUE_APP_URL
    timeout: 10000,  // 请求超时时间
    headers: {
        'Content-Type': 'application/json',
        /**
         * 避免接口缓存：IE get 请求会有缓存
         * https://support.microsoft.com/en-us/help/234067/how-to-prevent-caching-in-internet-explorer
         */
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
    }                                  
})
axios.defaults.withCredentials = false; //跨域安全策略

// 请求拦截器
axios.interceptors.request.use(
    config => {
        if (window.localStorage.getItem('Authorization')) {
            config.headers.Authorization = 'Bearer '+ localStorage.getItem('Authorization');
        }
        showFullScreenLoading();
        return config;
    },error => {
        tryHideFullScreenLoading();
        return Promise.reject(error);
    }
);
// 响应拦截器
axios.interceptors.response.use(
    response => {
        //window.console.log(response, '===>响应拦截器成功');
        if (response.status == 200) {
            tryHideFullScreenLoading();
            return response;
        }else{
            Message({
                message: '服务器响应失败,请稍后重试!',
                type: 'error',
                duration: 3 * 1000
            });
        }
    },
    err => {
        //window.console.log(err, '===>响应拦截器失败');
        tryHideFullScreenLoading();
        //请求报错处理
        switch (err.response.status) {
            case 400:
                {
                    Message({
                        message: '请求出错',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 401:
                {   
                    Message({
                        message: '未授权,请重新登录',
                        type: 'error',
                        duration:3000
                    });
                    window.localStorage.removeItem('Authorization');
                    window.setTimeout(() => {
                        window.location.href = "/";
                    }, 1000)
                    break;
                }

            case 403:
                {
                    Message({
                        message: '拒绝访问',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 404:
                {
                    Message({
                        message: '请求地址出错',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 408:
                {
                    Message({
                        message: '请求超时',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 500:
                {
                    Message({
                        message: '服务器内部错误',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 501:
                {
                    Message({
                        message: '服务未实现',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 502:
                {
                    Message({
                        message: '网关错误',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 503:
                {
                    Message({
                        message: '服务不可用',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 504:
                {
                    Message({
                        message: '网关超时',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            case 505:
                {
                    Message({
                        message: 'HTTP版本不受支持',
                        type: 'error',
                        duration:3000
                    });
                    break;
                }

            default:
                return Promise.reject(err);
        }
    }
);

function Xhr({ url, body = null, method = 'get' }) {
    if (method == "get") {
        return axios
            .get(url)
            .then(response => {
                if (response.status == 200 && response.data.code == 1) {
                    return response.data.data;
                } else {
                    Message({
                        message: response.message,
                        type: 'error',
                        duration:3000
                    });
                }
            })
            .catch('');
    } else if (method == "post") {
        return axios
            .post(url, body)
            .then(response => {
                if (response.status == 200 && response.data.code == 1) {
                    return response.data;
                } else if(response.data.code == -15){
                    Message({
                        message: '失败,老师已存在',
                        type: 'error',
                        duration:3000
                    });
                } else if(response.data.code == -16){
                    Message({
                        message: '失败,学生已存在',
                        type: 'error',
                        duration:3000
                    });
                } else{
                    Message({
                        message: '服务器响应失败,请稍后重试!',
                        type: 'error',
                        duration:3000
                    });
                }
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

export {axios,Xhr,AppendParam};