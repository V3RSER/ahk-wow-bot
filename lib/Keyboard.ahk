class Keyboard
{
    __New(window) {
        this.window := window
        ;Todo: implementar primer plano con Send, %key%
    }

    use(key, raw)
    {
        log.debug("Key: [" . key . "]")
        this.window.activate()
        ; SetControlDelay -1
        if raw
            ControlSendRaw,, %key%, % this.window.title
        else
            ControlSend,, %key%, % this.window.title
    }
}