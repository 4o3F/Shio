<template>
    <div class="flex flex-col h-screen w-full">
        <div class="flex-grow">
            <div v-if="currentPage == 0">
                <Inbound />
            </div>
            <div v-if="currentPage == 1">
                <Config />
            </div>
        </div>

        <nut-tabbar @tab-switch="tabSwitch" v-model="currentPage">
            <nut-tabbar-item tab-title="入场" :icon="Scan"></nut-tabbar-item>
            <nut-tabbar-item tab-title="配置" :icon="Home"></nut-tabbar-item>
        </nut-tabbar>
    </div>
</template>

<script lang="ts">
export default {
    name: "index"
}
</script>

<script setup lang="ts">
import {Scan, Home} from '@nutui/icons-vue-taro';
import {ref} from "vue";
import Taro from "@tarojs/taro";
import Config from "../config/config.vue";
import Inbound from "../inbound/inbound.vue";

const currentPage = ref(0)

function tabSwitch(item, index) {
    currentPage.value = index
}

Taro.eventCenter.on("login", () => {
    currentPage.value = 0
})
</script>
