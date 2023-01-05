﻿class Control
{
    __New(window := "")
    {
        this.window := window
        this.mouse := new Mouse(this.window)
        this.ketboard := new Keyboard(this.window)
    }

    sendClick(x := 0, y := 0, button := "", exactCoor := false, vectorMinRandomCoor := "", vectorMaxRandomCoor := "")
    {
        this.window.update()
        if !exactCoor
            this.__getRandomCoor(x, y, vectorMinRandomCoor, vectorMaxRandomCoor)
        if isEmpty(button)
            button := Mouse.I
        this.mouse.use(button, x, y)
    }

    sendKey(key, raw := false)
    {
        this.ketboard.use(key, raw)
    }

    moveMouse(x := 0, y := 0, speed := 0, relative := false, exactCoor := false, vectorMinRandomCoor := "", vectorMaxRandomCoor := "")
    {
        relative := relative ? "R" : ""
        if !exactCoor
            this.__getRandomCoor(x, y, vectorMinRandomCoor, vectorMaxRandomCoor)
        this.mouse.move(x, y, speed, relative)
    }

    __getRandomCoor(ByRef x, ByRef y, ByRef vectorMinRandomCoor, ByRef vectorMaxRandomCoor)
    {
        if isEmpty(vectorMinRandomCoor)
            vectorMinRandomCoor := [-5, 5]
        if isEmpty(vectorMaxRandomCoor)
            vectorMaxRandomCoor := [-5, 5]
        x := x + rand(vectorMinRandomCoor[1], vectorMinRandomCoor[2])
        y := y + rand(vectorMaxRandomCoor[1], vectorMaxRandomCoor[2])
    }
}