#NoEnv
#SingleInstance, Force
#Persistent
SendMode, Input
SetWorkingDir, %A_ScriptDir%

class Wow {
    __New(window)
    {
        this.window := window
        this.botImage := new BotImage(window)
        this.botImageForeground := new BotImage(window,, false)
        this.control := new Control(window)
        this.controlForeground := new Control(window, false)
    }

    scanRoutine()
    {
        ; this.TSM_executeScan(["TSM_cancelScan", "TSM_cancelScan-hover"])
        while (this.botImage.isFound(["TSM_mailNotification"]))
        {
            this.TSM_openMail()
            this.TSM_executeScan(["TSM_postScan", "TSM_postScan-hover"])
        }
    }

    TSM_executeScan(buttons)
    {
        this.goToAuctionHouse()
        this.TSM_subastar()
        this.__comprobateScanInProgres()
        log.warn("Ejecutando", buttons[1])
        this.botImageForeground.click(Mouse.I, buttons)
        sleep(300, 500)
        ; this.botImage.wait(["TSM_doneCanceling"]) ; todo: implementar caso en que no hay nada que cancelar / postear
        this.searchButtonTSM()
    }

    TSM_subastar()
    {
        log.trace("Esperando subasta")
        Switch % this.botImage.searchImages(x, y, ["TSM_subastar", "TSM_subastar-active"],,,,, 8000)
        {
        Case 0:
            log.critial("No se encontró la subasta")
            sleep(0, 2000)
            this.goToAuctionHouse()
            this.TSM_subastar()
        Case 1:
            log.warn("Abriendo subastar")
            sleep(150, 350)
            this.controlForeground.sendClick(Mouse.I, x, y)
        Case 2: log.info("Subastar abierto")
        Default:
        }
        sleep(250, 350)
    }

    __comprobateScanInProgres()
    {
        switch % this.botImage.isFound(["TSM_cancelar", "TSM_cancelar-hover", "TSM_post", "TSM_post-hover", "TSM_exitScan", "TSM_exitScan-hover"])
        {
        case 1, 2:
            buttonsFound := ["TSM_cancelar", "TSM_cancelar-hover"]
        case 3, 4:
            buttonsFound := ["TSM_post", "TSM_post-hover"]
        case 5, 6 :
            buttonsFound := ""
        default:
            return false
        }
        log.warn("Escaneo en curso")
        if !isEmpty(buttonsFound)
            this.TSM_macro(buttonsFound, 5000)
        sleep(300, 500)
        this.botImageForeground.click(Mouse.I, ["TSM_exitScan", "TSM_exitScan-hover"])
    }

    TSM_macro(buttons, time)
    {
        this.__getRandomCoor(xPosRand, yPosRand)
        while this.botImage.wait(buttons,,,,, time)
        {
            log.warn("Presionando macro")
            this.humanWheelUp(xPosRand, yPosRand)
            log.trace("Esperando", buttons[1])
            sleep(250, 400)
        }
    }

    TSM_openMail()
    {
        log.critical("Abrir el correo")
        TrayTip, WoW, Abrir el correo
        this.botImage.wait(["TSM_menuMail"],,,,, 5*60*1000)
        sleep(250, 400)
        if !this.botImage.isFound(["TSM_openMail-disable"])
        {
            this.botImageForeground.click(Mouse.I, ["TSM_openMail", "TSM_openMail-hover"])
            log.warn("Abriendo correo")
            sleep(500)
            this.botImage.wait(["TSM_openMail", "TSM_openMail-hover", "TSM_openMail-disable"],,,,, 2*60*1000)
            sleep(50, 500)
        }
        log.info("Correo revisado")
    }

    goToAuctionHouse()
    {
        if this.botImage.isFound(["TSM_menuAH"])
            return
        log.trace("Camino a subasta")
        this.control.sendKey("3")
        sleep(50, 150)
        this.__getRandomCoor(x, y)
        this.control.sendClick(Mouse.MD, x, y)
    }

    searchButtonTSM()
    {
        log.trace("Esperando botón TSM")
        this.__clearMouse()
        Switch this.botImage.wait(["TSM_cancelar", "TSM_post", "TSM_craftNext", "TSM_destroyNext"],,,,, 5*60*1000)
        {
        Case 1: this.TSM_macro(["TSM_cancelar", "TSM_cancelar-hover"], 5000)
        Case 2: this.TSM_macro(["TSM_post", "TSM_post-hover"], 5000)
        Case 3: this.TSM_macro(["TSM_craftNext", "TSM_craftNext-hover"], 30000)
        Case 4: this.TSM_macro(["TSM_destroyNext", "TSM_destroyNext-hover"], 5000)
        Default:
        }
        log.info("Ejecución finalizada")
        TrayTip, TSM, Ejecución finalizada
    }

    humanWheelUp(x, y)
    {
        loop % rand(1, 4)
        {
            this.control.sendClick(Mouse.MU, x, y)
            ; log.err("Rueda (" A_Index ")")
            sleep(15, 100)
        }
    }

    __getRandomCoor(ByRef x, ByRef y)
    {
        x := Rand(10, this.window.w / 8)
        y := Rand(150, this.window.h - 250)
    }

    __clearMouse()
    {
        this.__getRandomCoor(x, y)
        this.control.moveMouse(x, y)
    }
}

#Include <Libraries>
initWindow()

wow := new WoW(window)

xButton2::
ExitApp
Return

xButton1::
    wow.searchButtonTSM()
Return

F1::
    wow.scanRoutine()
Return
initWindow()
{
    log.trace("Iniciando Bot")
    ; Winset, AlwaysOnTop, , WoW.ahk
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