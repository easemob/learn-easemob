import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import WebIM from '../src/config/WebIM';

import "babel-polyfill"
//切换路由实现进度条
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
// 简单配置
NProgress.inc(0.2)
NProgress.configure({ easing: 'ease', speed: 500, showSpinner: false })
router.beforeEach((to,from,next) => {
  NProgress.start() 
  next()
})
router.afterEach(() => {
  NProgress.done()
})
//切换路由实现进度条

import moment from 'moment'

// 全局引入
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
Vue.use(ElementUI)
// import 'element-ui/lib/theme-chalk/index.css' //引入样式，这里是引入全部样式，你也可以单独引入某个组件样式
// 按需引入
// import { 
//   radio,
//   popover,
//   loading,
//   select,
//   option,
//   tooltip,
//   button
// } from 'element-ui';
// Vue.use(radio)
// Vue.use(select)
// Vue.use(option)
// Vue.use(loading)
// Vue.use(popover)
// Vue.use(tooltip)
// Vue.use(button)
// import 'element-ui/lib/theme-chalk/radio.css' 
// import 'element-ui/lib/theme-chalk/select.css' 
// import 'element-ui/lib/theme-chalk/option.css' 
// import 'element-ui/lib/theme-chalk/loading.css' 
// import 'element-ui/lib/theme-chalk/popover.css' 
// import 'element-ui/lib/theme-chalk/tooltip.css' 
// import 'element-ui/lib/theme-chalk/button.css' 

// 全局引入
// import VueMaterial from 'vue-material'
// import 'vue-material/dist/vue-material.min.css' 
// import 'vue-material/dist/theme/default.css'
// Vue.use(VueMaterial)
// 按需引入
import { MdButton, MdContent, MdCard,MdField,MdMenu,MdList } from 'vue-material/dist/components'
Vue.use(MdButton)
Vue.use(MdContent)
Vue.use(MdCard)
Vue.use(MdField)
Vue.use(MdMenu)
Vue.use(MdList)
import 'vue-material/dist/vue-material.min.css'
import 'vue-material/dist/theme/default.css'

// 全局引入
// import Vant from 'vant';
// import 'vant/lib/index.css';
// 按需引入
import { 
  Image as VanImage ,
  Field as VanField,
  Icon as VanIcon,
  Dialog as VanDialog,
  Swipe, SwipeItem,
  Overlay,
  Button as VanButton,
  Slider as VanSlider,
  Toast as VanToast,
  Popup as VanPopup,
} from 'vant';
// import 'vant/lib/index.css';
Vue.use(VanImage);
Vue.use(VanIcon);
Vue.use(VanDialog);
Vue.use(Swipe);
Vue.use(SwipeItem);
Vue.use(Overlay);
Vue.use(VanButton);
Vue.use(VanSlider);
Vue.use(VanToast);
Vue.use(VanField);
Vue.use(VanPopup);

Vue.prototype.$VanDialog = VanDialog;//赋值使用
Vue.prototype.$VanToast = VanToast;//赋值使用

// 引入模块后自动生效
import '@vant/touch-emulator'

Vue.prototype.$moment = moment;//赋值使用
Vue.config.productionTip = false

new Vue({
  router,
  store,
  WebIM,
  render: h => h(App),
}).$mount('#app')
