<template>
    <nut-toast
        :msg="toast.msg"
        v-model:visible="toast.show"
        :type="toast.type"
        :cover="toast.cover"
    />
    <nut-notify
            :type="notify.type"
            v-model:visible="notify.show"
            :msg="notify.desc"
    />
    <div class="grid grid-cols-1 gap-5">
        <div class="flex justify-center p-10 pt-13">
            <nut-button
                    type="primary"
                    color="linear-gradient(to right, #A6E3E9, #71C9CE)"
                    size="large"
                    @click="scanEntranceCode"
            >
                扫描入场码
            </nut-button>
        </div>
        <div class="flex justify-center p-5">
            未同步数据: {{idsWaitingSync.length}} 条
        </div>
        <div class="flex justify-center p-10">
            <nut-button
                type="primary"
                color="linear-gradient(to right, #424874, #A6B1E1)"
                size="large"
                @click="syncEntranceIDs"
            >
                同步入场数据
            </nut-button>
        </div>
    </div>
</template>

<script lang="ts">
export default {
    name: "inbound"
}
</script>
<script setup lang="ts">
import {reactive, ref} from "vue";
import Taro from "@tarojs/taro";
import {SHA256} from "crypto-js"
import {BASE_API_URL, ENTRANCE_CODE_LENGTH} from "../../utils/constants";

const notify = reactive({
    show: false,
    desc: '',
    type: 'primary',
    duration: 3000
})
const toast = reactive({
    msg: 'toast',
    type: 'text',
    show: false,
    cover: false,
    title: '',
    bottom: '',
    center: true
})

const idsWaitingSync = ref(JSON.parse(Taro.getStorageSync("ids_waiting_sync").length == 0 ? "[]" : Taro.getStorageSync("ids_waiting_sync")))

function audienceEntrance(id: number) {
    idsWaitingSync.value.push(id)
    Taro.setStorageSync("ids_waiting_sync", JSON.stringify(idsWaitingSync.value))
}


function scanEntranceCode() {
    Taro.scanCode({
        onlyFromCamera: true,
        success: (res) => {
            // 二维码由Audience ID和EntranceCode两部分组成，中间由@隔开
            let data = res.result.split('@')
            let audienceID = data[0]
            let audienceEntranceCode = data[1]
            let realAudienceEntranceCode = SHA256(audienceID + Taro.getStorageSync("entrance_code_salt")).toString().substring(0, ENTRANCE_CODE_LENGTH)
            console.log(audienceID + "/" + audienceEntranceCode + "/" + realAudienceEntranceCode)
            if (audienceEntranceCode == realAudienceEntranceCode) {
                audienceEntrance(+audienceID)
                notify.desc = "ID: " + audienceID + " 入场成功"
                notify.type = "success"
                notify.show = true
            } else {
                notify.desc = "入场码校验失败"
                notify.type = "danger"
                notify.show = true
            }
        }

    })
}

function syncEntranceIDs() {
    toast.cover = true
    toast.type = 'loading'
    toast.msg = '同步中'
    toast.show = true
    Taro.request({
        url: BASE_API_URL + "/audience/enter",
        method: 'POST',
        header: {
            "Authorization": "Bearer " + Taro.getStorageSync("api_key")
        },
        data:{
            "aids": idsWaitingSync.value
        },
        success: (response) => {
            if (response.data.code == 200) {
                idsWaitingSync.value = []
                Taro.setStorageSync("ids_waiting_sync", JSON.stringify(idsWaitingSync.value))

                toast.show = false
                notify.desc = response.data.message
                notify.type = 'success'
                notify.show = true
            } else {
                toast.show = false
                notify.desc = response.data.message
                notify.type = 'danger'
                notify.show = true
            }
        }

    })
}
</script>