<template>
  <div>
    <template v-for="(val,index) in renderData">
        <component :is = val.components v-if="val.isLoad" :key="index"></component>
    </template>
  </div>
</template>

<script>
import comOneToone from '@/components/oneToone/index';
import comSmallClass from '@/components/smallClass/index';

export default {
    data(){
        return {
            renderData:[
                {label:"一对一",name:"pageLayout",isLoad:false,components: comOneToone},
                {label:"小班课",name:"cdnPerformance",isLoad:false,components: comSmallClass},
            ],
        }
    },
    mounted(){
        const TYPE = this.$store.state.user.houseType;
        if(TYPE){
            this.renderData.map(res=>{
                if(res.label == TYPE){
                    res.isLoad = true;
                }else{
                    res.isLoad = false;
                }
            });
        }
    },
}
</script>
