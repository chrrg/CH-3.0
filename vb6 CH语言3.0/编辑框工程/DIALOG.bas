Attribute VB_Name = "DIALOG"
'�ص㣺һ������ʵ�֣���������Ĭ�ϱ����ļ����ʹ��ļ���
'���ã�
'sSaveFileName = GetDialog("save", "�����ļ�", "sethc.exe")
'sOpenFileName = GetDialog("open", "���ļ�", "sethc.exe")
'============================��/���濪ʼ============================
Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOPENFILENAME As OPENFILENAME) As Long
Public Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOPENFILENAME As OPENFILENAME) As Long
Type OPENFILENAME
    lStructSize As Long
    hwndOwner As Long
    hInstance As Long
    lpstrFilter As String
    lpstrCustomFilter As String
    nMaxCustFilter As Long
    nFilterIndex As Long
    lpstrFile As String
    nMaxFile As Long
    lpstrFileTitle As String
    nMaxFileTitle As Long
    lpstrInitialDir As String
    lpstrTitle As String
    flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    lpstrDefExt As String
    lCustData As Long
    lpfnHook As Long
    lpTemplateName As String
End Type
Public Const OFN_OVERWRITEPROMPT = &H2
Public Const OFN_HIDEREADONLY = &H4
Public Const OFN_PATHMUSTEXIST = &H800
Public Const OFN_FILEMUSTEXIST = &H1000
Public Function GetDialog(ByVal sMethod As String, ByVal sTitle As String, ByVal sFileName As String, Optional exe As String) As String
    On Error GoTo myError
    Dim rtn As Long, pos As Integer
    Dim file As OPENFILENAME
    file.lStructSize = Len(file)
    file.hInstance = App.hInstance
    file.lpstrFile = sFileName & String$(255 - Len(sFileName), 0)
    file.nMaxFile = 255
    file.lpstrFileTitle = String$(255, 0)
    file.nMaxFileTitle = 255
    file.lpstrInitialDir = ""
    If exe = "exe" Then
        file.lpstrFilter = "��ִ���ļ�(*.exe)" & Chr$(0) & "*.exe" & Chr$(0) & "�����ļ�(*.*)" & Chr$(0) & "*.*" & Chr$(0)
    Else
        file.lpstrFilter = "�����ļ�(*.ch3)" & Chr$(0) & "*.ch3" & Chr$(0) & "�����ļ�(*.*)" & Chr$(0) & "*.*" & Chr$(0)
    End If
    file.lpstrTitle = sTitle
    If UCase(sMethod) = "OPEN" Then
        file.flags = OFN_HIDEREADONLY + OFN_PATHMUSTEXIST + OFN_FILEMUSTEXIST
        rtn = GetOpenFileName(file)
    Else
        file.lpstrDefExt = "ch3"
        file.flags = OFN_HIDEREADONLY + OFN_PATHMUSTEXIST + OFN_OVERWRITEPROMPT
        rtn = GetSaveFileName(file)
    End If
    If rtn > 0 Then
        pos = InStr(file.lpstrFile, Chr$(0))
        If pos > 0 Then
            GetDialog = Left$(file.lpstrFile, pos - 1)
        End If
    End If
    Exit Function
myError:
    MsgBox "δ֪ԭ���²���ʧ�ܣ�", vbCritical + vbOKOnly, APP_NAME
End Function
'============================��/�������============================
