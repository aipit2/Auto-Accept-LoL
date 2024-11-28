#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=include\icon.ico
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt("TrayAutoPause",0)
Opt("TrayMenuMode",1)
Opt("TrayOnEventMode",1)
Opt("GUIOnEventMode",1)

TrayCreateItem("Exit")
TrayItemSetOnEvent(-1,"_Exit")

#include 'include/_HttpRequest.au3'

Global $PORT

; Check quyền Admin
If (Not IsAdmin()) Then
	MsgBox(16 + 4096 + 262144, "Code By Trần Hùng", "Vui lòng mở tool bằng quyền Administrator!")
	Exit
EndIf

Func Lcu_Setup()
	Local $sProc = "LeagueClientUx.exe"
	Local $iPID = ProcessExists($sProc)
	If ($iPID == 0) Then
		MsgBox(48 + 8192 + 262144, "Thông báo", "Vui lòng mở Liên Minh trước!", 2)
		$iPID = ProcessWait($sProc)
		Sleep(1000) ; Chờ mở Client Liên Minh
	EndIf
	; Get LCU path
	Local $sDir = StringTrimRight(_WinAPI_GetProcessFileName($iPID), StringLen($sProc))
	; Read the lockfile and get port + password
	Local $sLockfile = FileReadLine($sDir & 'lockfile')
	Local $arrayToken = StringSplit($sLockfile, ':', 2)
	$PORT = $arrayToken[2]
	_HttpRequest_SetAuthorization("riot", $arrayToken[3]) ; Pass
EndFunc

Func API($url)
	Return 'https://127.0.0.1:' & $PORT & $url
EndFunc

Func Accept()
	ConsoleWrite('+ Accept Function' & @CRLF)
	_HttpRequest(2,API('/lol-matchmaking/v1/ready-check/accept'),'','','','','POST')
EndFunc

Func whereAmI() ; Check xem đã trong trận chưa
	ConsoleWrite("+ whereAmI Function")
	Local $rq = _HttpRequest(2,API('/lol-gameflow/v1/gameflow-phase'))
	Switch $rq
		Case '"InProgress"' 	; Đang trong trận
			Return 'InProgress'
		Case '"Matchmaking"' 	; Đang tìm trận
			Return 'Matchmaking'
		Case '"Lobby"' 			; Đang trong phòng
			Return 'Lobby'
		Case '"None"' 			; Đang ở ngoài Menu chính
			Return 'None'
		Case '"ReadyCheck"'		; Đang ở phần chấp thuận trận đấu
			Return 'ReadyCheck'
		Case Else 				; Không biết đang ở đâu luôn
			Return False
	EndSwitch
EndFunc

Func Main()

	Lcu_Setup()

	MsgBox(64 + 8192 + 262144,'Auto accept','Auto accept is ready',2)

	While 1
		Local $whereAmI = whereAmI()
		ConsoleWrite(' ==> ' & $whereAmI & @CRLF)
		Switch $whereAmI
			Case 'ReadyCheck'
				Accept()
				Sleep(5000)
			Case 'InProgress'
				Sleep(10000)
			Case 'Matchmaking'
				Sleep(5000)
			Case Else
				Sleep(10000)
		EndSwitch
	WEnd
EndFunc

Func _Exit()
    Exit
EndFunc

Main()
