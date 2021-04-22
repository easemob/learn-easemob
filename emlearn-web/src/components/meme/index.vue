<template>
       <el-popover ref="popover5" placement="top-start" width="360" v-model="show">
            <img
                v-for="(v,i) in emojiList"
                :src="require(`../../../static/faces/${v}`)"
                :key="i"
                @click="selectEmoji(i)"
                class="img-style"
            />
        </el-popover>
</template>

<script>
    import emoji from "../../config/websdk.shim";
    export default {
        props:{
            show:{
                default () {
                    return false;
                },
                type:Boolean
            }
        },
         data(){
            return {
                emojiList: emoji.obj,
            }
        },
        methods:{
             selectEmoji(e) {
                let value = (this.inpMessage || "") + e;
                this.$data.showModal = false;
                this.$emit("selectEmoji", value);
            },
        }
    }
</script>

<style>

</style>