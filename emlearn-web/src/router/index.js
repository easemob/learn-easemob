import Vue from 'vue'
import Router from 'vue-router'
import store from "../store/index";

/**
 *  重写路由的push方法
 *  防止控制台报错 "NavigationDuplic {_name: "NavigationDuplicated", name: "NavigationDuplicated"}"
 */
const originalPush = Router.prototype.push
Router.prototype.push = function push(location) {return originalPush.call(this, location).catch(err => err)}

Vue.use(Router);

const router = new Router({
    mode: "hash", //history hash
    routes: [
        {
            path: '/',
            name: "登陆",
            meta: ['登陆'],
            component: ()=>import("@/pages/login/login.vue"),
        },
        {
            path: '/Index',
            name: "登陆",
            meta: ['登陆'],
            component: ()=>import("@/pages/index/index.vue"),
        },
    ]
});

export default router;

