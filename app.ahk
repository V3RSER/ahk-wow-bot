#NoEnv
#SingleInstance, Force
#Persistent
SendMode, Input
SetWorkingDir, %A_ScriptDir%

#Include <Libraries>
; TrayTip para notificaciones

initWindow()

xButton2::
ExitApp
Return

xButton1::
    botImage := new BotImage(window)
    TrayTip, TSM, Búsqueda botón TSM
    log.err("Búsqueda botón TSM")
    Switch botImage.wait(["TSM_cancelar", "TSM_post", "TSM_craftNext", "TSM_destroyNext"],,,,, 5*60*1000)
    {
    Case 1: TSM(["TSM_cancelar", "TSM_cancelar-hover"], 5000)
    Case 2: TSM(["TSM_post", "TSM_post-hover"], 5000)
    Case 3: TSM(["TSM_craftNext", "TSM_craftNext-hover"], 30000)
    Case 4: TSM(["TSM_destroyNext", "TSM_destroyNext-hover"], 5000)
    Default:
    }
    log.info("Finaliza búsqueda")
    TrayTip, TSM, Finaliza búsqueda
Return

TSM(buttons, time)
{
    xPosRand := Rand(10, window.w / 8 - 10)
    yPosRand := Rand(10, window.h - 10)
    mouse.__getCoor(lastX, lastY)
    while botImage.wait(buttons,,,,, time)
    {
        humanWheelUp(xPosRand, yPosRand)
        log.critical(buttons[1])
        sleep(150, 400)
    }
}

humanWheelUp(x, y) {
    global window
    mouse := new Mouse(window)

    loop % rand(1, 4) {
        mouse.use(Mouse.MU, x, y)
        log.warn("Rueda (" A_Index ")")
        sleep(15, 100)
    }
}

initWindow()
{
    log.info("Iniciando Bot")
    Winset, AlwaysOnTop, , C:\Program Files\AutoHotkey\AutoHotkey.exe

    global window := new Window()
    if !window.wait()
    {
        MsgBox, No se encuentra WoW
        ExitApp
    }
    window.activate()
    window.update()
    ; window.move(0, 0, 800, 800)
}