<template>
    <nut-notify
            :type="notify.type"
            v-model:visible="notify.show"
            :msg="notify.desc"
    />
    <nut-input v-model="apiKey" placeholder="API密钥" type="password"/>
    <nut-input v-model="entranceCodeSalt" placeholder="入场码盐值" type="password" clearable>
        <template #left>
            <Link></Link>
        </template>
        <template #right>
            <nut-button type="primary" size="small" @click="getEntranceCodeSalt">自动获取</nut-button>
        </template>
    </nut-input>
    <div class="flex justify-center p-4">
        <nut-button type="default" size="large" @click="saveConfig">保存配置</nut-button>
    </div>
</template>

<script lang="ts">
export default {
    name: "config"
}
</script>
<script setup lang="ts">
import {Link} from "@nutui/icons-vue-taro";
import {ref, reactive} from "vue";
import Taro from "@tarojs/taro";
import {BASE_API_URL} from "../../utils/constants";


const notify = reactive({
    show: false,
    desc: '',
    type: 'primary',
    duration: 3000
})
const apiKey = ref(Taro.getStorageSync("api_key"))
const entranceCodeSalt = ref(Taro.getStorageSync("entrance_code_salt"))

function saveConfig() {
    Taro.setStorageSync("api_key", apiKey.value)
    Taro.setStorageSync("entrance_code_salt", entranceCodeSalt.value)
    notify.desc = "保存成功"
    notify.type = 'success'
    notify.show = true
}

function getEntranceCodeSalt() {
    Taro.request({
        url: BASE_API_URL + "/common/getEntranceCodeSalt",
        method: 'GET',
        header: {
            "Authorization": "Bearer " + Taro.getStorageSync("api_key")
        },
        success: (response) => {
            if (response.data.code == 200) {
                entranceCodeSalt.value = response.data.data.salt
                notify.desc = response.data.message
                notify.type = 'success'
                notify.show = true
            } else {
                notify.desc = response.data.message
                notify.type = 'danger'
                notify.show = true
            }
        }

    })
}
</script>

<style scoped>

</style>