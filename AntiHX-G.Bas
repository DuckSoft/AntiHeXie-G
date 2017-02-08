#Include Once "windows.bi"
#Include Once "win/shellapi.bi"
#Include "file.bi"
#Include "rsrc.bi"

Declare Function ProlongPath(ByRef inPath As String) As String
Declare Function DlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
Declare Sub ProcessFile(ByRef inFile As String)



	Dim Shared hLst As HWND
	Dim As HINSTANCE hInstance=GetModuleHandle(NULL)
	
	If Command() <> "" Then
		MessageBox(NULL, "Just open the program and use please!", "Hint",MB_OK Or MB_ICONINFORMATION Or MB_SYSTEMMODAL)
		ExitProcess(NULL)
	EndIf
	DialogBoxParam(hInstance, Cast(ZString Ptr,frmMain), NULL, @DlgProc, NULL)


	ExitProcess(NULL)
	End


Function DlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Select Case uMsg
		Case WM_DROPFILES
			hLst = GetDlgItem(hWin,lstLog)
			
			Dim As Integer filenum = DragQueryFile(Cast(HDROP, wParam), &HFFFFFFFF, NULL, 0)
			Dim As ZString*255 buf
			For i As Integer = 0 To filenum-1
				DragQueryFile(Cast(HDROP, wParam), i, @buf, 255)
				SendMessage(hLst,LB_ADDSTRING,0,@buf)
				ProcessFile(buf)
			Next
		Case WM_INITDIALOG
			Dim ico As HICON
			ico = LoadIcon(hWin,icoMain)
			SendMessage(hWin, WM_SETICON,ICON_SMALL,ico)
			SendMessage(hWin, WM_SETICON,ICON_BIG,ico)
			DragAcceptFiles(hWin, TRUE)
		Case WM_CLOSE
			EndDialog(hWin, 0)
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Sub ProcessFile(ByRef inFile As String)
	Dim As String prolonged = ProlongPath(inFile)
	Dim As Integer fillTimes = CInt(Rnd()*16384+64)
	
	' Just don't create new file
	' in consideration of speed
	
	
	'If Not FileExists(inFile) Then
	'	SendMessage(hLst,LB_ADDSTRING,0,@"File not found")
	'	Exit Sub
	'EndIf
	'
	'If FileExists(prolonged) Then 
	'	Kill(prolonged)
	'	SendMessage(hLst,LB_ADDSTRING,0,@"Overwriting output file")
	'EndIf
	
	' FileCopy inFile, prolonged
	'Open prolonged For Append As #2
	
	Open inFile For Append As #2
	For i As Integer = 0 To fillTimes
		Put #2,,Chr(0)
	Next
	
	Name inFile, prolonged
	
	Close #2
	SendMessage(hLst,LB_ADDSTRING,0,@"Processed")
End Sub

Function ProlongPath(ByRef inPath As String) As String
 	Dim As String tempStr
 	Dim As UInteger i
 	For i = Len(inPath) To 1 Step -1
 		If Mid(inPath,i,1) = "\" Then
 			Exit For
 		EndIf
 	Next
 	
 	tempStr = Mid(inPath,1,i) & "_" & Mid(inPath,i+1,Len(inPath)-i)
 	Return tempStr
End Function