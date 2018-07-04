Attribute VB_Name = "reg"
Public Const ExeName = "CH语言编辑框"
Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Private Declare Function RegSetValueExLong Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, lpValue As Long, ByVal cbData As Long) As Long
Private Declare Function RegQueryValueExString Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, ByVal lpData As String, lpcbData As Long) As Long
Private Declare Function RegQueryValueExLong Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Long, lpcbData As Long) As Long
Private Declare Function RegQueryValueExNULL Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, ByVal lpData As Long, lpcbData As Long) As Long
Private Declare Function RegSetValueExString Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, ByVal lpValue As String, ByVal cbData As Long) As Long
Const REG_SZ As Long = 1
Const REG_DWORD As Long = 4
Const HKEY_LOCAL_MACHINE = &H80000002
Const HKEY_CURRENT_USER = &H80000001
Const KEY_ALL_ACCESS = &H3F
Const KEY_WOW64_64KEY = &H100 '访问的是64位的注册表。
Const KEY_WOW64_32KEY = &H200 '访问的是32位的注册表。
Private Function QueryValue(ByVal lPredefinedKey As Long, ByVal sKeyName As String, ByVal sValueName As String)
       Dim lRetVal As Long
       Dim hKey As Long
       Dim vValue As Variant
       lRetVal = RegOpenKeyEx(lPredefinedKey, sKeyName, 0, KEY_ALL_ACCESS, hKey)
       lRetVal = QueryValueEx(hKey, sValueName, vValue)
       QueryValue = Replace(vValue, Chr(0), "")
       RegCloseKey (hKey)
End Function
Private Function QueryValue64(ByVal lPredefinedKey As Long, ByVal sKeyName As String, ByVal sValueName As String)
       Dim lRetVal As Long
       Dim hKey As Long
       Dim vValue As Variant
       lRetVal = RegOpenKeyEx(lPredefinedKey, sKeyName, 0, KEY_ALL_ACCESS Or KEY_WOW64_64KEY, hKey)
       lRetVal = QueryValueEx(hKey, sValueName, vValue)
       QueryValue64 = vValue
       RegCloseKey (hKey)
End Function
Function QueryValueEx(ByVal lhKey As Long, ByVal szValueName As String, ByRef vValue As Variant) As Long
    Dim cch As Long
    Dim lrc As Long
    Dim lType As Long
    Dim lValue As Long
    Dim sValue As String
    On Error GoTo QueryValueExError
    lrc = RegQueryValueExNULL(lhKey, szValueName, 0&, lType, 0&, cch)
    If lrc <> 0 Then Error 5
    Select Case lType
        Case REG_SZ:
            sValue = String(cch, 0)
            lrc = RegQueryValueExString(lhKey, szValueName, 0&, lType, sValue, cch)
            If lrc = 0 Then
                vValue = Left$(sValue, cch)
            Else
                vValue = Empty
            End If
        Case REG_DWORD:
            lrc = RegQueryValueExLong(lhKey, szValueName, 0&, lType, lValue, cch)
            If lrc = 0 Then vValue = lValue
        Case Else
            lrc = -1
    End Select
QueryValueExExit:
    QueryValueEx = lrc
    Exit Function
QueryValueExError:
    Resume QueryValueExExit
End Function
Public Function pan(ByRef s As String, ByVal va As String) As Boolean
s = Split(s, "HKEY_LOCAL_MACHINE\")(1)
If QueryValue(HKEY_LOCAL_MACHINE, s, va) = "" Then
pan = False
Else
pan = True
End If
Exit Function
s = Split(s, "HKEY_LOCAL_MACHINE\")(1)
Dim phkResult     As Long
Dim backs     As Long
backs = RegOpenKeyEx(HKEY_LOCAL_MACHINE, s, 0&, KEY_ALL_ACCESS, phkResult)
If backs = ERROR_SUCCESS Then
pan = True
RegCloseKey (phkResult) '关闭打开项的句柄
Else
pan = False
End If

Exit Function
On Error GoTo no:
Dim WSH
Set WSH = CreateObject("WSCRIPT.SHELL")
Call WSH.RegRead(s)
pan = True
Exit Function
no:
pan = False
Set WSH = Nothing

End Function
Public Function ReadReg(ByVal Program As String, ByVal Value As String) As String
If Program = "" Then Program = ExeName
Dim WSH
Set WSH = CreateObject("WSCRIPT.SHELL")
If Not pan("HKEY_LOCAL_MACHINE\SOFTWARE\" & Program, Value) Then
ReadReg = ""
Else
ReadReg = WSH.RegRead("HKEY_LOCAL_MACHINE\Software\" & Program & "\" & Value)
End If
Set WSH = Nothing
End Function
Public Sub WriteReg(ByVal Program As String, ByVal Value As String, ByVal Str As String)
If Program = "" Then Program = ExeName
Dim WSH
Set WSH = CreateObject("WSCRIPT.SHELL")
If Not pan("HKEY_LOCAL_MACHINE\SOFTWARE\" & Program, Value) Then
WSH.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\" & Program & "\", 1, "REG_BINARY"
WSH.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\" & Program & "\" & Value, Str, "REG_SZ"
Else
WSH.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\" & Program & "\" & Value, Str, "REG_SZ"
End If
Set WSH = Nothing
End Sub
Public Function SetValueEx(ByVal hKey As Long, sValueName As String, lType As Long, vValue As Variant) As Long
    Dim lValue As Long
    Dim sValue As String
    Select Case lType
        Case REG_SZ
            sValue = vValue
            SetValueEx = RegSetValueExString(hKey, sValueName, 0&, lType, sValue, Len(sValue))
        Case REG_DWORD
            lValue = vValue
            SetValueEx = RegSetValueExLong(hKey, sValueName, 0&, lType, lValue, 4)
        End Select
End Function
Public Function SetKeyValue(ByVal lPredefinedKey As Long, ByVal sKeyName As String, ByVal sValueName As String, ByVal vValueSetting As Variant, ByVal lValueType As Long)
      Dim lRetVal As Long
      Dim hKey As Long

      lRetVal = RegOpenKeyEx(lPredefinedKey, sKeyName, 0, KEY_ALL_ACCESS Or KEY_WOW64_64KEY, hKey)
      lRetVal = SetValueEx(hKey, sValueName, lValueType, vValueSetting)
      RegCloseKey (hKey)
End Function
Public Function SetKeyValue32(ByVal lPredefinedKey As Long, ByVal sKeyName As String, ByVal sValueName As String, ByVal vValueSetting As Variant, ByVal lValueType As Long)
      Dim lRetVal As Long
      Dim hKey As Long

      lRetVal = RegOpenKeyEx(lPredefinedKey, sKeyName, 0, KEY_ALL_ACCESS, hKey)
      lRetVal = SetValueEx(hKey, sValueName, lValueType, vValueSetting)
      RegCloseKey (hKey)
End Function
Private Function Howmuch(ByVal Text As String, ByVal zi As String)
    Howmuch = (Len(Text) - Len(Replace(Text, zi, ""))) / Len(zi)
End Function
