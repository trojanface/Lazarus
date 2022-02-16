#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Global Variables
global bookings := combine_files(A_ScriptDir)
global Name

;GUI
Gui , Add, Text,, Name/Email/Number/Transaction Number/Phone
Gui , Add, Edit, w200 vName,
Gui , Add, Button, x80 w80 h40 vSearchContr Default gSearch, Search
Gui , Show
return

;Search Function
Search:
global bookings
;pulls the contents of the gui control 'Name' and places it in a variable called 'Name'
GuiControlGet , Name, , Name
;splits the bookings into an array
bookings2 := StrSplit(bookings, "`n")
;searches each element in the array
for i, element in bookings2
    {
        ;splits the element into a smaller array
        line := StrSplit(element, ",")
        ;searches the smaller array
        for j, element2 in line 
            {
                ;detects if keyword 'name' is in the array
                if InStr(element2, Name) {
                    ;if it is then define our variables based on the other details in the array
                    needle := chr(34)
                    name2 := JEE_StrReplaceChars(line[22], needle, "", 1) 
                    booking2 := JEE_StrReplaceChars(line[23], needle, "", 1) 
                    tickets2 :=JEE_StrReplaceChars(line[25], needle, "", 1) 
                    Email := JEE_StrReplaceChars(line[33], needle, "", 1) 
                    Location2 := JEE_StrReplaceChars(line[2], needle, "", 1) 
                    Screen := JEE_StrReplaceChars(line[21], needle, "", 1) 
                    Movie := JEE_StrReplaceChars(line[17], needle, "", 1) 
                    MovieTime := JEE_StrReplaceChars(line[18], needle, "", 1) 
                    Phone := JEE_StrReplaceChars(line[31], needle, "", 1) 
                    ;user confirms if this is who they want
                    Msgbox 4, ,Are these the droids you're looking for?`n`n%name2%`n%booking2%`n%Phone%`n%Location2%`n%Movie%`n%MovieTime%`n%tickets2%`n%Email% 
IfMsgBox No
	break
    IfMsgBox Yes
    ;open an outlook email and preload information into it
                    try
                        outlookApp := ComObjActive("Outlook.Application")
                    catch
                        outlookApp := ComObjCreate("Outlook.Application")
                    Recipient := Email
                    Subject := "Your Online Booking"
                    Body = 
                    (Join
                        <p>Hi %name2%</p>
                        <p>We apologise for your booking confirmation not automatically sending. Please see your regenerated details below...</p>
                        <br>
                        <h5>Booking Name: %name2%</h5>
                        <h5>Booking Number: %booking2%</h5>
                        <h5>Film: %Movie%</h5>
                        <h5>Session: %MovieTime%</h5>
                        <h5>Cinema: %Location2%</h5>
                        <h5>Tickets: %tickets2%</h5>
                    )
                    oloutlookApp := 0
                    outlookApp := ComObjActive("Outlook.Application").CreateItem(oloutlookApp)
                    olFormatHTML := 2
                    outlookApp.BodyFormat := olFormatHTML
                    outlookApp.Subject := Subject
                    outlookApp.HTMLBody := Body
                    Recipient := outlookApp.Recipients.Add(Recipient)
                    Recipient.Type := 1 ; To: CC: = 2 BCC: = 3
                    outlookApp.Display
                 goto, finish
                 return
             }
            }
           
}

               finish:
return

;function that loads all the .csv files into a single variable
combine_files(Directory)
{
	files =
	Loop %Directory%\*.csv
	{
		FileRead, readFile, %Directory%\%A_LoopFileName%
        returnVar := returnVar . readFile
	}
    
	return returnVar
}

;function that replaces a specific character in a string
JEE_StrReplaceChars(vText, vNeedles, vReplaceText:="", ByRef vCount:="")
{
	vCount := StrLen(vText)
	Loop, Parse, % vNeedles
		vText := StrReplace(vText, A_LoopField, vReplaceText)
	vCount := vCount-StrLen(vText)
	return vText
}

;TO DO ;back button, lookup via phone number