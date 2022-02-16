#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.
#Persistent

FileReadLine , settingOne, saleItems.txt, 1
FileGetTime , OutputVar, 20211209_ConcessionItemListing.CSV
var1 = %OutputVar%	; replace file date variable with var1
var2 = %A_Now%	; replace current time variable with var2
EnvSub , var2, %var1%, days	; variables = days // subtract the two
global offset = 0
global Name
global arrItems := []
global searchItems := []
if (settingOne != "") {

    if (var2 >= 1)
    {
        ItemGet()
    }
} else {
    ItemGet()
}

Gui , searchBar: Add, Text, , Search for Item
    Gui , searchBar: Add, Edit, vNam
Gui , searchBar: Add, Button, gFindItemSub, Search
Gui , searchBar: Show, y0
return

ItemGet() {
    FileDelete , saleItems.txt

    loop , read, 20211209_ConcessionItemListing.CSV
    {
        FileReadLine , currentLine, 20211209_ConcessionItemListing.CSV, %A_Index%
        itemLoad := StrSplit(currentLine, ",")
        ;msgbox % itemLoad[55]

        if (itemLoad[55] != "Component" && itemLoad[61] > 0 && !InStr(itemLoad[61], "/") && !InStr(itemLoad[61], ":")) {
            ;msgbox %currentLine%
            FileAppend , %currentLine%`n, saleItems.txt
            arrItems.Push(currentLine)
        }
    }
}

FindItemSub:
    global Name
    Name =
        GuiControlGet , Name, , Nam
    FindItem(Name)
    return

    FindItem(Name)
    {
        global offset

        Gui , itemList: Destroy

        searchItems := []
        ;msgbox %Name%

        loop , read, saleItems.txt
        {
            FileReadLine , currentLine, saleItems.txt, %A_Index%
            itemLoad := StrSplit(currentLine, ",")
            ; if (HasVal(itemLoad, Name) > 0) {
            ;     searchItems.Push(currentLine)
            ; }
            If (InStr(itemLoad[49], Name)) {
                searchItems.Push(currentLine)
            }
        }
        vCount := NumGet(&searchItems + 4 * A_PtrSize)
        Gui , itemList: Add, Text, , Results: %vCount%
        for index, element in searchItems
        {
            itemLoad := StrSplit(element, ",")
            min := 0 + offset
            max := 20 + offset
            if (A_Index > min) && (A_Index < max) {
                Gui , itemList: Add, Button, h30, % itemLoad[49] itemLoad[61]
            }
        }
        if (offset > 0) {
            Gui , itemList: Add, Button, gPreviousSub, Previous
        }
        if (offset < vCount) {
            Gui , itemList: Add, Button, gNextSub, Next
        }
        Gui , itemList: Show, y100 w400
    }

NextSub:
    Next()
    return

PreviousSub:
    Previous()
    return

    Next()
    {
        global offset
        global Name
        ;msgbox %Name%
        offset += 20
        FindItem(Name)
    }

    Previous()
    {
        global offset
        global Name
        if (offset > 0) {
            offset += -20
        }
        FindItem(Name)
    }

    HasVal(haystack, needle)
    {
        for index, value in haystack
            IfInString , value, %needle%
        return index
        if !(IsObject(haystack))
            throw Exception("Bad haystack!", -1, haystack)
        return 0
    }