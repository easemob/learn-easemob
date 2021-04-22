
function getUrl(){
    var apiUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//a1.easemob.com'
    var socketUrl = '//im-api-v2.easemob.com/ws'
    if(window.location.href.indexOf('webim-h5.easemob.com') !== -1 ){
        apiUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//a1.easemob.com'
        socketUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//im-api-v2.easemob.com/ws'
    }
    else if(window.location.href.indexOf('webim-hsb-ly.easemob.com') !== -1){
        apiUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//a1-hsb.easemob.com'
        socketUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//im-api-v2-hsb.easemob.com/ws'
    }
    else if(window.location.href.indexOf('localhost') !== -1){
        apiUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//a1.easemob.com'
        socketUrl = (window.location.protocol === 'https:' ? 'https:' : 'http:') + '//im-api-v2.easemob.com/ws'
    }
    return {
        apiUrl: apiUrl,
        socketUrl: socketUrl,
        sandBoxApiUrl: 'https://a1-hsb.easemob.com',
        sandboxSocketUrl: 'https://im-api-v2-hsb.easemob.com/ws'
    }
}

let config = {
    xmppURL: getUrl().socketUrl,
    apiURL: getUrl().apiUrl,
    // appkey: "easemob-demo#chatdemoui",
    appkey: "1108200509113038#chatapp",
    Host: "easemob.com",
    https: true,
    isHttpDNS: false,
    isMultiLoginSessions: true,
    isWindowSDK: false,
    isSandBox: false,
    isDebug: true,
    isStropheLog: false,
    autoReconnectNumMax: 5,
    autoReconnectInterval: 2,
    isWebRTC: true, //window.RTCPeerConnection && /^https\:$/.test(window.location.protocol),
    i18n: "us",
    isAutoLogin: true,
    p2pMessageCacheSize: 500,
    delivery: true,
    groupMessageCacheSize: 200,
    loglevel: "ERROR",
    enableLocalStorage: true
}
export default config

