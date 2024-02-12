package com.requiemz.overlay_pop_up

import io.flutter.plugin.common.BasicMessageChannel

interface PlatformCommunicator {
    public fun sendMessage(message: Any?, reply: BasicMessageChannel.Reply<Any?>)
}