import emedia from 'easemob-emedia';
//开始共享桌面 调用完回调用onStreamAdded接口
export const startShareDesktop = (confrId/*会议id */,stopShareDesktop/*停止共享桌面回调 */) => {
    var options = {
        withAudio:true,
        confrId,
        stopSharedCallback: () => stopShareDesktop()
    }
    await emedia.mgr.shareDesktopWithAudio(options);
}

//停止共享桌面
export const stopShareDesktop = (desktopStream/*共享桌面流 */) => {
    emedia.mgr.unpublish(desktopStream);
}