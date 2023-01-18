#NoEnv
#SingleInstance, Force
#Persistent
SendMode, Input
SetWorkingDir, %A_ScriptDir%

class TSM
{
    static subastar = ["TSM_subastar", "TSM_subastar-active"]
    static mail = ["TSM_openMail", "TSM_openMail-hover", "TSM_openMail-disable"]
    static cancelar = ["TSM_cancelar", "TSM_cancelar-hover"]
    static post = ["TSM_post", "TSM_post-hover"]
    static craftNext = ["TSM_craftNext", "TSM_craftNext-hover"]
    static destroyNext = ["TSM_destroyNext", "TSM_destroyNext-hover"]
    static exitScan = ["TSM_exitScan", "TSM_exitScan-hover"]
    static cancelScan = ["TSM_cancelScan", "TSM_cancelScan-hover"]
    static postScan = ["TSM_postScan", "TSM_postScan-hover"]
    varLastCancel := new Var("vars", "lastCancelScan")

    __New(window)
    {
        this.window := window
        this.control := new Control(window)
        this.images := new BotImage(window)
    }

    scanRoutine()
    {
        if this.__readyForCancelScan()
            this.executeScan(TSM.cancelScan)
        while (this.images.isFound(["TSM_mailNotification"]))
        {
            this.openMail()
            this.executeScan(TSM.postScan)
        }
    }

    executeScan(buttons)
    {
        this.goToAuctionHouse()
        this.waitAuctionHouse()
        this.__comprobateScanInProgres()
        log.warn("Ejecutando", buttons[1])
        this.images.foreground.click(Mouse.I, buttons)
        sleep(300, 500)
        ; this.images.wait(["TSM_doneCanceling"]) ; todo: implementar caso en que no hay nada que cancelar / postear
        this.searchButton()
    }

    waitAuctionHouse()
    {
        log.trace("Esperando subasta")
        switch % this.images.searchImages(x, y, TSM.subastar,,,,, 9000)
        {
        case 0:
            log.critial("No se encontró la subasta") sleep(0, 250)
            this.goToAuctionHouse()
            this.waitAuctionHouse()
        case 1:
            log.warn("Abriendo subastar") sleep(150, 350)
            this.control.foreground.sendClick(Mouse.I, x, y)
        case 2:
            log.info("Subastar abierto")
        Default:
        }
        sleep(50, 350)
    }

    openMail()
    {
        log.critical("Abrir el correo")
        TrayTip, WoW, Abrir el correo

        this.images.wait(["TSM_menuMail"],,,,, 5*60*1000)
        sleep(500, 700)
        if !this.images.isFound(TSM.mail[3])
        {
            this.images.foreground.click(Mouse.I, [].concat(TSM.mail[1]).concat(TSM.mail[2]))
            log.warn("Abriendo correo") sleep(500)
            this.images.wait(TSM.mail,,,,, 2*60*1000)
            sleep(50, 500)
        }

        log.info("Correo revisado")
    }

    __comprobateScanInProgres()
    {
        switch % this.images.isFound([].concat(TSM.cancelar).concat(TSM.post).concat(TSM.exitScan))
        {
        case 1, 2: buttonsFound := TSM.cancelar
        case 3, 4: buttonsFound := TSM.post
        case 5, 6: buttonsFound := ""
        default: return false
        }
        log.warn("Escaneo en curso")
        if !isEmpty(buttonsFound)
            this.pressMacro(buttonsFound)
        sleep(300, 500)
        this.images.foreground.click(Mouse.I, TSM.exitScan)
    }

    pressMacro(buttons, maxWheel := 4, time := 5000)
    {
        this.__getRandomCoor(xPosRand, yPosRand)
        while this.images.wait(buttons,,,,, time)
        {
            log.warn("Presionando macro")
            this.humanWheelUp(xPosRand, yPosRand, maxWheel)
            log.trace("Esperando", buttons[1]) sleep(250, 400)
        }
    }

    searchButton()
    {
        log.trace("Esperando botón TSM")

        this.__clearMouse()
        buttons := [].concat(TSM.cancelar).concat(TSM.post).concat(TSM.craftNext)
            .concat(TSM.destroyNext).concat(TSM.mail)
        switch this.images.wait(buttons,,,,, 5*60*1000)
        {
        case 1, 2:
            this.pressMacro(TSM.cancelar, 7)
            this.varLastCancel.set(A_TickCount)
        case 3, 4: this.pressMacro(TSM.post, 7)
        case 5, 6: this.pressMacro(TSM.craftNext,, 30000)
        case 7, 8: this.pressMacro(TSM.destroyNext)
        case 9, 10:
            this.openMail()
            this.executeScan(TSM.postScan)
        case 11:
        Default:
        }

        log.info("Ejecución finalizada")
        TrayTip, TSM, Ejecución finalizada
    }

    goToAuctionHouse()
    {
        if this.images.isFound(["TSM_menuAH"])
            return
        log.trace("Camino a subasta")
        this.control.sendKey("3")
        sleep(50, 150)
        this.__getRandomCoor(x, y)
        this.control.sendClick(Mouse.MD, x, y)
        ;Todo: implementar caminar automático
    }

    humanWheelUp(x, y, maxWheel)
    {
        loop % rand(3, maxWheel)
        {
            this.control.sendClick(Mouse.MU, x, y)
            ; log.err("Rueda (" A_Index ")")
            sleep(15, rand(1, 3) == 1 ? 100 : 70)
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

    __readyForCancelScan()
    {
        return A_TickCount - this.varLastCancel.get() > 5*60*1000
    }
}

#Include <Libraries>
initWindow()

tsm := new TSM(window)
; tsm.scanRoutine()

xButton2::
ExitApp
Return

xButton1::
    tsm.searchButton()
Return

F1::
    tsm.scanRoutine()
Return

initWindow()
{
    log.trace("Iniciando Bot")
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