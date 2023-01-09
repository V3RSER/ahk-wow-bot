class BotImage
{
    __New(window := "", variation := 30, controlBackground := "")
    {
        this.window := window
        this.variation := variation
        this.control := new Control(this.window, controlBackground)
    }

    searchImages(byref foundX, byref foundY, nameImages := "", x := 0, y := 0, _x := "", _y := "", maxWaitingTime := 5000)
    {
        this.window.update()
        this.window.comprobateCoorLimit(_x, _y)

        pToken := Gdip_Startup()
        imagesToSearch := this.__createImagesToSearch(nameImages, x, y, _x, _y)
        imageWindow := new Image(this.window, "area-de-busqueda")
        indexFoundImage := 0
        startTime := A_TickCount
        while ((A_TickCount - startTime) <= maxWaitingTime)
        {
            imageWindow.getFromWindow()
            ; imageWindow.editFromWindowByCoor(x, y, _x, _y)

            for index, image in imagesToSearch
            {
                ; image.editFromFileByCoor()
                if (foundImage := Gdip_ImageSearch(imageWindow.bitmap, image.bitmap, foundXY, x, y, _x, _y, this.variation))
                {
                    indexFoundImage := index
                    break
                }
            }
            imageWindow.dispose()

            if (foundImage > 0)
            {
                coordinates := StrSplit(foundXY, ","), foundX := coordinates[1], foundY := coordinates[2]
                foundImage := indexFoundImage
                break
            }
            else if (not maxWaitingTime or foundImage < 0)
                break
            else
                sleep(16) ; sleep(33)
        }

        for index, image in imagesToSearch
        {
            image.dispose()
        }

        VarSetCapacity(imagesToSearch, 0)
        Gdip_Shutdown(pToken)
        return foundImage
    }

    __createImagesToSearch(nameImages, x, y, _x, _y)
    {
        imagesToSearch := []
        loop, % nameImages.Length()
        {
            image := new Image(this.window, nameImages[A_Index])
            imagesToSearch.Push(image)
            if !imagesToSearch[A_Index].getFromFile()
            {
                imagesToSearch[A_Index].__interfaceNotExistImage(x, y, _x, _y)
                imagesToSearch[A_Index].getFromFile()
            }
        }
        return imagesToSearch
    }

    isFound(nameImages := "", x := 0, y := 0, _x := "", _y := "") {
        return this.searchImages(foundX, foundY, nameImages, x, y, _x, _y, 0)
    }

    wait(nameImages := "", x := 0, y := 0, _x := "", _y := "", waitingTime := 5000) {
        return this.searchImages(foundX, foundY, nameImages, x, y, _x, _y, waitingTime)
    }

    click(button := "", nameImages := "", x := 0, y := 0, _x := "", _y := "", maxWaitingTime := 5000, exactCoor := false)
    {
        isFound := this.searchImages(foundX, foundY, nameImages, x, y, _x, _y, maxWaitingTime)
        if (isFound > 0)
            this.control.sendClick(button, foundX, foundY, exactCoor)
        return isFound
    }
}
