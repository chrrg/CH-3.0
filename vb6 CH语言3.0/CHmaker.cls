VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CHmaker"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private Declare Function SafeArrayGetDim Lib "oleaut32.dll" (ByRef saArray() As Any) As Long
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function GetTickCount Lib "kernel32" () As Long

''''''''''''''''EXE输出
Private Declare Function BeginUpdateResource Lib "kernel32" Alias "BeginUpdateResourceA" (ByVal pFileName As String, ByVal bDeleteExistingResources As Long) As Long
Private Declare Function UpdateResource Lib "kernel32" Alias "UpdateResourceA" (ByVal hUpdate As Long, ByVal lpType As String, ByVal lpName As String, ByVal wLanguage As Long, lpData As Any, ByVal cbData As Long) As Long
Private Declare Function EndUpdateResource Lib "kernel32" Alias "EndUpdateResourceA" (ByVal hUpdate As Long, ByVal fDiscard As Long) As Long

''''''''''''''''API调用
Private Type VariableBuffer
    VariableParameter() As Byte
End Type
Private Declare Function LoadLibrary Lib "kernel32" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As Long
Private Declare Function GetProcAddress Lib "kernel32" (ByVal hModule As Long, ByVal lpProcName As String) As Long
Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hwnd As Long, ByVal msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
Private Declare Function FreeLibrary Lib "kernel32" (ByVal hLibModule As Long) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (lpDest As Any, lpSource As Any, ByVal cBytes As Long)
Private m_opIndex As Long
Private m_OpCode()       As Byte




Dim MakeCode As String
Const CHMakerVersion = "3.0.10"
'Private Type CHprocessData
'    name As String
'    CHID As Long
'    id As Long
'    Status As Long
'End Type


Private Type codeblockdata
names As String
canshu() As String
Code As String
End Type


Private Type CHbianliangData
    name As String
    type As Long '为0 则为"字符串"有转义符 1 则为 '字符串'
    Parents As String
    text As String
End Type

Private Type ChObjects
    obj As Object
    names As String
    type As String '0 为object   1为dll对象
    hwnd As Long
End Type

'Private 过程数 As Long
'Public 线程数 As Long
'Private 线程(100) As CHprocessData


Private 代码块数 As Long
Private 代码块(1000) As codeblockdata

Private 对象(100) As ChObjects
Private 对象数 As Long

Private 变量数 As Long
Private Const 最大变量数 As Long = 5000
Private 变量(最大变量数) As CHbianliangData
Private 变量NoMoney As Boolean

Public Event GetERRORLog(inf As String)
Public Event GetLog(inf As String)
Public Event DebugEvent(inf As String)

Public CHDebug As Boolean
Public CHDebugPath As String
Private ErrDescription As String
Private ErrNumber As Long
Private ExitFunction As Boolean
Private StopProgram As Boolean

Private ErrorIgnore As Boolean

Sub Init()

End Sub

Function CreateApi(names As String, LibPath As String) As Long
    If RealRun Then On Error GoTo creerr:
    对象(对象数).names = names
    对象(对象数).type = 1
    对象(对象数).hwnd = CreAPI(LibPath)
    CreateApi = 对象(对象数).hwnd
    对象数 = 对象数 + 1
    
    Exit Function
creerr:
End Function
Function BindApi(names As String, hProcAddress As Long) As Long
    If RealRun Then On Error GoTo creerr:
    对象(对象数).names = names
    对象(对象数).type = 1
    对象(对象数).hwnd = hProcAddress
    BindApi = 对象(对象数).hwnd
    对象数 = 对象数 + 1
    
    Exit Function
creerr:
End Function
Function ExistApi(names As String) As Long
    Dim objn As Long
    For objn = 0 To 对象数 - 1
        对象(objn).names = names
        ExistApi = 对象(objn).hwnd
        Exit Function
    Next
    ExistApi = 0
End Function
Function CallApi(names As String, FuncName As String, Parameter As String) As String
    Dim objn As Long
    For objn = 0 To 对象数 - 1
        If 对象(objn).names = names Then
            CallApi = ExecuteAPI(对象(objn).hwnd, FuncName, Parameter)
            Exit Function
        End If
    Next
End Function


Function GetCode()
    GetCode = MakeCode
End Function
Function getVersion()
    getVersion = CHMakerVersion
End Function
Public Sub Delay(Msec As Long)
    Dim EndTime As Long
    EndTime = GetTickCount + Msec
    Do
        Sleep 1
        DoEvents
    Loop While GetTickCount < EndTime
End Sub
Function AppPath()
    AppPath = IIf(Right(App.Path, 1) = "\", App.Path, App.Path & "\")
End Function


''''''''''''''''''''''''''API调用Start
Private Function CreAPI(LibPath As String) As Long
    CreAPI = LoadLibrary(ByVal LibPath) '读取API库
End Function
Private Function FreeAPI(hModule As Long) As Long
    FreeAPI = FreeLibrary(hModule)
End Function
Private Function ExecuteAPI(hModule As Long, APIScript As String, Optional FunctionParameter As String) As Long
    Dim hProcAddress As Long, X As Long, Y As Long
    Dim FunctionName As String
    Dim LongCount As Long, StringInfo As String, StrByteArray()       As VariableBuffer
    Dim StringSize As Long, ByteArray()       As Byte, IsHaveParameter As Boolean
    Dim ParameterArray()       As String, OutputArray()       As Long
    StringSize = 0
    ReDim StrByteArray(StringSize)
    IsHaveParameter = Len(FunctionParameter) <> 0
    FunctionName = APIScript
    If IsHaveParameter Then
        IsHaveParameter = True
        分割参数 ParameterArray, FunctionParameter, True 'ParameterArray = Split(FunctionParameter, ",")
        ReDim OutputArray(UBound(ParameterArray))
        For X = 0 To UBound(ParameterArray)
            If IsNumeric(Trim(ParameterArray(X))) = True Then
                    LongCount = CLng(Trim(ParameterArray(X)))
                    OutputArray(X) = LongCount
            Else
                    StringInfo = Mid(Trim(ParameterArray(X)), 2, Len(ParameterArray(X)) - 3)
                    If Len(StringInfo) = 0 Then
                        OutputArray(X) = CLng(VarPtr(Null))
                    Else
                        ReDim Preserve StrByteArray(StringSize)
                        ByteArray = StrConv(StringInfo, vbFromUnicode)
                        ReDim Preserve StrByteArray(StringSize).VariableParameter(UBound(ByteArray) + 1)
                        CopyMemory StrByteArray(StringSize).VariableParameter(0), ByteArray(0), UBound(ByteArray) + 1
                        OutputArray(X) = CLng(VarPtr(StrByteArray(StringSize).VariableParameter(0)))
                        StringSize = StringSize + 1
                    End If
            End If
        Next X
        ReDim m_OpCode(400 + 6 * UBound(OutputArray))
    End If
    hProcAddress = GetProcAddress(hModule, ByVal FunctionName)
    If hProcAddress = 0 Then
            ExecuteAPI = 0       '函数读取失败
            'FreeLibrary hModule
            Exit Function
    End If
    If IsHaveParameter = True Then
            ExecuteAPI = CallWindowProc(GetCodeStart(hProcAddress, OutputArray), 0, 1, 2, 3)
    Else
            ExecuteAPI = CallWindowProc(hProcAddress, 0, 1, 2, 3)
    End If
    'FreeLibrary hModule
End Function
Private Function FreeDLL(hModule As Long) As Long
    FreeLibrary hModule
    FreeDLL = 0
End Function

Private Function ExecuteParaAPI(hModule As Long, APIScript As String, FunctionParameter() As String) As Long
    Dim hProcAddress As Long, X As Long, Y As Long
    Dim FunctionName As String
    Dim LongCount As Long, StringInfo As String, StrByteArray()       As VariableBuffer
    Dim StringSize As Long, ByteArray()       As Byte, IsHaveParameter As Boolean
    Dim ParameterArray()       As String, OutputArray()       As Long
    StringSize = 0
    ReDim StrByteArray(StringSize)
    IsHaveParameter = UBound(FunctionParameter) <> 0
    FunctionName = APIScript
    If IsHaveParameter Then
        ParameterArray = FunctionParameter
        ReDim OutputArray(UBound(ParameterArray))
        For X = 0 To UBound(ParameterArray)
            If IsNumeric(Trim(ParameterArray(X))) = True Then
                    LongCount = CLng(Trim(ParameterArray(X)))
                    OutputArray(X) = LongCount
            Else
                    'StringInfo = Mid(Trim(ParameterArray(X)), 2, Len(ParameterArray(X)) - 3)
                    StringInfo = ParameterArray(X)
                    If Len(StringInfo) = 0 Then
                        OutputArray(X) = CLng(VarPtr(Null))
                    Else
                        ReDim Preserve StrByteArray(StringSize)
                        ByteArray = StrConv(StringInfo, vbFromUnicode)
                        ReDim Preserve StrByteArray(StringSize).VariableParameter(UBound(ByteArray) + 1)
                        CopyMemory StrByteArray(StringSize).VariableParameter(0), ByteArray(0), UBound(ByteArray) + 1
                        OutputArray(X) = CLng(VarPtr(StrByteArray(StringSize).VariableParameter(0)))
                        StringSize = StringSize + 1
                    End If
            End If
        Next X
        ReDim m_OpCode(400 + 6 * UBound(OutputArray))
    End If
    hProcAddress = GetProcAddress(hModule, ByVal FunctionName)
    If hProcAddress = 0 Then
            ExecuteParaAPI = 0       '函数读取失败
            'FreeLibrary hModule
            Exit Function
    End If
    If IsHaveParameter = True Then
            ExecuteParaAPI = CallWindowProc(GetCodeStart(hProcAddress, OutputArray), 0, 1, 2, 3)
    Else
            ExecuteParaAPI = CallWindowProc(hProcAddress, 0, 1, 2, 3)
    End If
    'FreeLibrary hModule
End Function
Private Function GetAddressAPI(hModule As Long, FunctionName As String) As Long
    GetAddressAPI = GetProcAddress(hModule, ByVal FunctionName)
End Function

Private Function ExecuteAddressAPI(hProcAddress As Long, FunctionParameter() As String) As Long
    Dim X As Long, Y As Long
    Dim FunctionName As String
    Dim LongCount As Long, StringInfo As String, StrByteArray()       As VariableBuffer
    Dim StringSize As Long, ByteArray()       As Byte, IsHaveParameter As Boolean
    Dim ParameterArray()       As String, OutputArray()       As Long
    StringSize = 0
    ReDim StrByteArray(StringSize)
    IsHaveParameter = UBound(FunctionParameter) <> 0
    If FunctionParameter(0) <> "" Then IsHaveParameter = True
    If IsHaveParameter Then
        ParameterArray = FunctionParameter
        ReDim OutputArray(UBound(ParameterArray))
        For X = 0 To UBound(ParameterArray)
            If IsNumeric(Trim(ParameterArray(X))) = True Then
                    LongCount = CLng(Trim(ParameterArray(X)))
                    OutputArray(X) = LongCount
            Else
                    'StringInfo = Mid(Trim(ParameterArray(X)), 2, Len(ParameterArray(X)) - 3)
                    StringInfo = ParameterArray(X)
                    If Len(StringInfo) = 0 Then
                        OutputArray(X) = CLng(VarPtr(Null))
                    Else
                        ReDim Preserve StrByteArray(StringSize)
                        ByteArray = StrConv(StringInfo, vbFromUnicode)
                        ReDim Preserve StrByteArray(StringSize).VariableParameter(UBound(ByteArray) + 1)
                        CopyMemory StrByteArray(StringSize).VariableParameter(0), ByteArray(0), UBound(ByteArray) + 1
                        OutputArray(X) = CLng(VarPtr(StrByteArray(StringSize).VariableParameter(0)))
                        StringSize = StringSize + 1
                    End If
            End If
        Next X
        ReDim m_OpCode(400 + 6 * UBound(OutputArray))
    End If

    If IsHaveParameter = True Then
            ExecuteAddressAPI = CallWindowProc(GetCodeStart(hProcAddress, OutputArray), 0, 1, 2, 3)
    Else
            ExecuteAddressAPI = CallWindowProc(hProcAddress, 0, 1, 2, 3)
    End If
    'FreeLibrary hModule
End Function


Private Function GetCodeStart(ByVal lngProc As Long, arrParams() As Long) As Long
        Dim lngIndex As Long, lngCodeStart As Long
        lngCodeStart = (VarPtr(m_OpCode(0)) Or &HF) + 1
        m_opIndex = lngCodeStart - VarPtr(m_OpCode(0))
        For lngIndex = 0 To m_opIndex - 1
                m_OpCode(lngIndex) = &HCC
        Next lngIndex
        For lngIndex = UBound(arrParams) To 0 Step -1
            AddByteToCode &H68
            AddLongToCode arrParams(lngIndex)
        Next lngIndex
        AddByteToCode &HE8
        AddLongToCode lngProc - VarPtr(m_OpCode(m_opIndex)) - 4
        AddByteToCode &HC2
        AddByteToCode &H10
        AddByteToCode &H0
        GetCodeStart = lngCodeStart
End Function
Private Sub AddLongToCode(lData As Long)
        CopyMemory m_OpCode(m_opIndex), lData, 4
        m_opIndex = m_opIndex + 4
End Sub
Private Sub AddIntToCode(iData As Integer)
        CopyMemory m_OpCode(m_opIndex), iData, 2
        m_opIndex = m_opIndex + 2
End Sub
Private Sub AddByteToCode(bData As Byte)
        m_OpCode(m_opIndex) = bData
        m_opIndex = m_opIndex + 1
End Sub
''''''''''''''''''''''''''API调用END


Function TrimCodeBlock(ByVal Code As String) As String
DoEvents
Dim centertext As String, posdn1 As Long, posdn2 As Long, sposn1 As Long, sposn2 As Long, tempcode As String
If InStr(1, Code, "{") <> 0 Then
    sposn1 = 1
    Do
        posdn1 = InStr(sposn1, Code, "{") '''a(){2{1}3}e{1e2}
        sposn1 = 1 + posdn1
        If posdn1 <> 0 Then
            sposn2 = sposn1
            Do
                posdn2 = InStr(sposn2, Code, "}")
                sposn2 = 1 + posdn2
                If posdn2 = 0 Then SendError "}丢失！"
                centertext = Mid(Code, posdn1 + 1, posdn2 - posdn1 - 1)
                Dim dkhnn As Boolean
                dkhnn = Howmuch(centertext, "{") = Howmuch(centertext, "}")
                If dkhnn Then
                    tempcode = TrimCodeBlock(centertext)
                    'rowcoden = Len(code)
                    Code = Replace(Code, "{" & centertext & "}", AddCodeBlock(tempcode))
                    'sposn1 = sposn1 - Len(code) + rowcoden
                End If
            Loop Until dkhnn
        End If
    Loop Until posdn1 = 0
End If
TrimCodeBlock = Code
End Function
Private Function BytesToBstr(strBody, CodeBase)
Dim ObjStream
Set ObjStream = CreateObject("Adodb.Stream")
With ObjStream
.type = 1
.Mode = 3
.open
.Write strBody
.Position = 0
.type = 2
.Charset = CodeBase
BytesToBstr = .ReadText
.Close
End With
Set ObjStream = Nothing
End Function
Function AddCodeBlock(Code As String) As String
    代码块(代码块数).Code = Code
    代码块(代码块数).names = "ch_" & Format(代码块数, "00000000")
    AddCodeBlock = "ch_" & Format(代码块数, "00000000")
    代码块数 = 代码块数 + 1
End Function
Function AddCusFunc(FuncName As String, Code As String, canshu() As String) As String
    代码块(代码块数).Code = Code
    代码块(代码块数).names = FuncName
    Dim Canshuele, CanShuEleN As Long
    If SafeArrayGetDim(canshu) <> 0 Then
        ReDim 代码块(代码块数).canshu(UBound(canshu))
        For Each Canshuele In canshu
        代码块(代码块数).canshu(CanShuEleN) = Canshuele
        CanShuEleN = CanShuEleN + 1
        Next
    End If
    AddCusFunc = FuncName
    代码块数 = 代码块数 + 1
End Function
Function Run(Code As String)
    重置
    Code = TrimCode(Code)
    If Right(Code, 1) <> ";" Then Code = Code & ";"
    Code = Code & "die;"
    If Not CheckCode(Code) Then Run = False: Exit Function '如果代码有误，直接退出
    Code = 计算表达式(Code)
    MakeCode = Code
    Run = True
End Function

Function CheckCode(Code As String) '检查代码是否有问题
    'If singles(Code, """") Then CheckCode = False: Exit Function
    'If singles(Code, "'") Then CheckCode = False: Exit Function
    CheckCode = True
End Function


Function TrimCode(Code As String) '修建代码 如 删注释 删换行等
    
    'Dim codezu() As String, codes As String, ifcode As Variant
    'codezu = Split(Code, ";")
    'Dim n As Long
    'For Each ifcode In codezu
    '    codes = Trim(ifcode)
    '    If Len(codes) >= 2 Then
    '        If Left(codes, 2) = "//" Then codezu(n) = ""
    '    End If
    '    n = n + 1
    'Next
    'Code = Join(codezu, ";")
    
    
    'Code = Replace(Code, vbCrLf, "")
    '123;/*46;*/678;
    Dim n  As Long
    n = 0
    Dim n2 As Long, nn As Long
    nn = 1
    While InStr(nn, Code, "//") <> 0
        n2 = InStr(nn, Code, "//")
        n = InStr(n2 + 2, Code, vbCrLf)
        If n <> 0 Then
            Code = Mid(Code, nn, n2 - nn) & Mid(Code, n)
        Else
            Code = Mid(Code, nn, n2 - nn)
            n = Len(Code)
        End If
    Wend
    Code = Replace(Code, vbCrLf, "")
    n = 0
    nn = 1
    While InStr(nn, Code, "/*") <> 0
        n2 = InStr(nn, Code, "/*")
        n = InStr(n2 + 2, Code, "*/")
        If n = 0 Then SendError "注释/**/未关闭": Exit Function
        Code = Mid(Code, nn, n2 - nn) & Mid(Code, n + 2)
    Wend
    Code = 转储字符串(Code)
    Code = Replace(Code, Chr(9), "")
    Code = 不区分大小写(Code)
    Code = CodeBlockSave(Code)
    'Code = Replace(Code, vbCrLf, "")
    
    TrimCode = Trim(Code)
End Function
Function CodeBlockSave(Code As String) As String
    代码块数 = 0
    Dim ttcode
    ttcode = Code
    CodeBlockSave = TrimCodeBlock(ttcode)
End Function
Private Function Howmuch(s As String, t As String) '常用函数
    Howmuch = (Len(s) - Len(Replace(s, t, ""))) / Len(t)
End Function

Private Function Much(s As String, t As String) As Boolean '判断字符串中有吗？
    Much = InStr(1, s, t)
End Function

Private Function Singles(s As String, t As String) As Boolean '判断字符串s中是单数个t吗
Dim charn As Long
    charn = Howmuch(s, t)
    If Int(charn / 2) <> charn / 2 Then Singles = True
End Function

Private Function SingleNum(s As String) As Boolean
    If Int(s / 2) <> s / 2 Then SingleNum = True
End Function
Public Function 输出exe(Code As String, TargetFile As String) As Boolean
If RealRun Then On Error GoTo errs:
'MsgBox ComText
    Dim FSO As Object, selfpath As String
    If CHDebug Then
        selfpath = AppPath & "link.exe"
    Else
        selfpath = AppPath & App.EXEName & ".exe"
    End If
    Set FSO = CreateObject("Scripting.FileSystemObject")
    SendLog vbCrLf & Now & "启动" & vbCrLf
    
    If Code = "" Then
        SendLog Now & "操作停止！不允许空代码！" & String(10, "-") & vbCrLf
        Exit Function
    End If
    SendLog String(30, "-") & vbCrLf & Now & "开始" & String(10, "-") & "当前版本：" & CHMakerVersion & vbCrLf
    SendLog "输出路径：" & TargetFile
    If Dir(selfpath, vbNormal) = "" Then
        SendLog Now & "操作停止！无法找到：" & selfpath & String(10, "-") & vbCrLf
        Exit Function
    End If

    FSO.Copyfile selfpath, TargetFile
    If Dir(TargetFile, vbNormal) = "" Then
        SendLog Now & "输出可能失败...文件无法输出：" & TargetFile & vbCrLf
        Exit Function
    End If
    SendLog Now & "输出中..." & vbCrLf
    
    Dim hRes As Long
    Dim Mystr() As Byte
    Mystr = StrConv(Code, vbFromUnicode)
    hRes = BeginUpdateResource(TargetFile, False)
    Dim mystr2 As String
    mystr2 = LenB(StrConv(Code, vbFromUnicode))
    UpdateResource hRes, "CUSTOM", "101", 2052, Mystr(0), mystr2
    EndUpdateResource hRes, False
    SendLog "操作完成" & String(10, "-") & vbCrLf
    输出exe = True
    
Exit Function
errs:
SendLog "操作出现错误：错误号：" & Err.Number & "详细错误：" & vbCrLf & Err.Description & String(10, "-") & vbCrLf
End Function
Private Function 不区分大小写(texts As String) '将不是引号的部分全部转为小写
    Dim nunnn As Long
    Dim ntexx() As String
    Dim nusns As Long
    If texts = "" Then Exit Function
    nunnn = Howmuch(texts, """")
    ntexx = Split(texts, """")
    If nunnn / 2 = Int(nunnn / 2) Then
        For nusns = 0 To nunnn Step 2
            ntexx(nusns) = LCase(ntexx(nusns))
        Next
    End If
    不区分大小写 = Join(ntexx, """")
End Function
Private Sub 加变量(names As String, texts As String, types As Long) '需手动trim
If Not 检测变量合法性(names) Then SendError "变量名不正确！": Exit Sub
Dim bln As Long
For bln = 0 To 变量数 - 1
    If names = 变量(bln).name Then
        变量(bln).text = texts
        变量(bln).type = types
        Exit Sub
    End If
Next
    变量(变量数).name = names  '变量前面要加$  这里存储不加$
    变量(变量数).text = texts
    变量(变量数).type = types
    变量数 = 变量数 + 1
End Sub
Private Function 读变量(names As String) '需手动trim
    Dim bianliangn As Long
    For bianliangn = 0 To 变量数 - 1
        If 变量(bianliangn).name = names Then 读变量 = 变量(bianliangn).text: Exit Function
    Next
End Function
Private Function 取变量地址(names As String)
    Dim i As Long
    For i = 0 To 变量数 - 1
        If 变量(i).text = names Then
            取变量地址 = 变量(i).name
            Exit For
        End If
    Next
End Function
Private Function 判断变量类型(names As String)
    Dim bianliangn As Long
    For bianliangn = 0 To 变量数
        If 变量(bianliangn).name = names Then 判断变量类型 = 变量(bianliangn).type: Exit Function
    Next
End Function
Function 第一运算优先(表达式 As String)
    Dim tempbiaodashi As String
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String, c3 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, posn As Long
    Dim result As String, str As String, strs As String
    Dim 符号 As String
    Dim dengyu As Boolean
    Dim noact As Boolean
    'If 表达式 <> "" Then
    '    If Right(表达式, 1) <> ";" Then
    '        If Much(表达式, ";") Then
    '            表达式 = 表达式 & ";"
    '        End If
    '    End If
    'End If
    posn = 1
    n1 = InStr(posn, 表达式, "(")
    n2 = InStr(posn, 表达式, ";")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "("
        n = n1
    End If
    If n2 < n And n2 <> 0 Then
        符号 = ";"
        n = n2
    End If

    If n = 999999 Then n = 0
    While n <> 0
        c1 = ""
        c2 = ""

        For pos2 = n - 1 To 1 Step -1 '前面的
            If 符号 = "(" Then
                If Much("+-*/\%&|.^!=", Mid(表达式, pos2, 1)) Then
                    pos2 = pos2 + 1
                    Exit For
                Else
                    If Mid(表达式, pos2, 1) = "=" Then
                        If pos2 = n - 1 Then
                            
                            
                        Else
                            pos2 = pos2 + 1
                        End If
                        Exit For
                            
                    End If
                End If
                
            End If
            If pos2 = 1 Then Exit For
        Next
        If pos2 = 0 Then c1 = "" Else c1 = Trim(Mid(表达式, pos2, n - pos2))
        For pos1 = n + 1 To Len(表达式) '后面的
            If 符号 = ";" Then
                If Much(";", Mid(表达式, pos1, 1)) Then
                    c2 = Trim(Mid(表达式, n + 1, pos1 - n))
                    If Howmuch(c2, "(") = Howmuch(c2, ")") Then
                        pos1 = pos1 - 1
                        c2 = Trim(Mid(表达式, n + 1, pos1 - n))
                        Exit For
                    End If
                End If
            End If
            If 符号 = "(" Then
                If Much(")", Mid(表达式, pos1, 1)) Then
                
                    str = Mid(表达式, n + 1, pos1 - n - 1)
                    If Howmuch(str, "(") = Howmuch(str, ")") Then
                        'pos1 = pos1 - 1
                        Exit For
                    End If
                End If
            End If
            If pos1 = Len(表达式) Then Exit For
        Next
        If pos1 > Len(表达式) Then pos1 = Len(表达式)
            
        If c2 <> "" Then
            'c2 = c2
        Else
            'If 符号 = ";" Then n = n - 1
            If pos1 - n - 1 >= 0 Then
                If 符号 = ";" Then
                    c2 = Trim(Mid(表达式, n + 1, pos1 - n))
                Else
                    c2 = Trim(Mid(表达式, n + 1, pos1 - n - 1))
                End If
            Else
                n = n - 1
                c2 = Trim(Mid(表达式, n + 1, pos1 - n - 1))
            End If
            c3 = ""
            If InStr(pos1 + 1, 表达式, ";") - pos1 - 1 > 0 Then
                c3 = Mid(表达式, pos1 + 1, InStr(pos1 + 1, 表达式, ";") - pos1 - 1)
            End If
            pos1 = pos1 + Len(c3)
        End If
        result = ""
        Select Case 符号
            Case "("
                If Not ExitFunction Then result = 执行函数(c1, c2, c3)
                If StopProgram Then Exit Function
            Case ";"
                result = ""
                If c1 = "" And c2 = "" Then
                Else
                    If c1 <> "die" And c1 <> "" Then
                        If Not ExitFunction Then
                            result = 计算表达式(c1)
                        End If
                    End If
                    If StopProgram Then Exit Function

                    If c2 <> "die" And c2 <> "" Then
                        If Not ExitFunction Then
                            result = 计算表达式(c2)
                        End If
                    End If
                    If StopProgram Then Exit Function

                End If
        End Select
        'result = 转添字符串(result)
        'If result = """""" Then result = ""
        'If result = "''" Then result = ""
        
        'If result <> "True" And result <> "False" And result <> "" Then result = 转添字符串(result)
        If result <> "" Then result = 转添字符串(result)
        If pos2 = 0 Then pos2 = 1
        'result = 转字符串(result)
        'result = ""
        'If result = "" Then result = "''"
        If Len(表达式) < pos1 Then pos1 = Len(表达式)
        表达式 = Left(表达式, pos2 - 1) & result & Right(表达式, Len(表达式) - pos1)
        If Left(表达式, 1) = ";" Then 表达式 = Mid(表达式, 2)
        If posn = 0 Then posn = 1 '       '123/r/n354'
        posn = Len(result) + pos2
        If 表达式 = "" Then posn = 0
        If posn <> 0 Then
            n1 = InStr(posn, 表达式, "(")
            n2 = InStr(posn, 表达式, ";")
            n = 999999
            If n1 < n And n1 <> 0 Then
                符号 = "("
                n = n1
            End If
            If n2 < n And n2 <> 0 Then
                符号 = ";"
                n = n2
            End If
            If n = 999999 Then n = 0
        Else
            n = 0
        End If
    Wend
    第一运算优先 = 表达式
    Debug.Print 表达式
End Function
Function 单目运算优先(表达式 As String)
''''''!true  false
''''''++$a
''''''--$a
''''''$a++
''''''$a--

    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim dengyu As Boolean
    Dim noact As Boolean
    posn = 1
    n1 = InStr(posn, 表达式, "!")
    n2 = InStr(posn, 表达式, "+")
    n3 = InStr(posn, 表达式, "-")
    
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "!"
        n = n1
    End If
    If n2 < n And n2 <> 0 Then
        符号 = "+"
        n = n2
    End If
    If n3 < n And n3 <> 0 Then
        符号 = "-"
        n = n3
    End If
    If n = 999999 Then n = 0
    While n <> 0
        c1 = ""
        c2 = ""
        dengyu = False
        noact = False
        For pos2 = n - 1 To 1 Step -1 '前面的
            If Much("+-!&|=<>^", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
            If pos2 = 1 Then Exit For
        Next
        If pos2 = 0 Then pos2 = 1
        If pos2 = 0 Then c1 = "" Else c1 = Trim(Mid(表达式, pos2, n - pos2))
        If 符号 = "+" Or 符号 = "-" Then
            If 符号 = "+" Then
                If Mid(表达式, n + 1, 1) = "+" Then dengyu = True
            End If
            
            If 符号 = "-" Then
                If Mid(表达式, n + 1, 1) = "-" Then dengyu = True
            End If
            If Not dengyu Then
                If 符号 = "+" Then noact = True
                If 符号 = "-" Then
                    If c1 <> "" Then noact = True
                End If
            End If
        End If
        If dengyu Then n = n + 1
        For pos1 = n + 1 To Len(表达式) '后面的
            If 符号 = "+" Or 符号 = "-" Then
                If Much("+-!&|=^<>", Mid(表达式, pos1, 1)) Then
                    If dengyu Then pos1 = pos1 - 1: Exit For
                End If
            End If
            If 符号 = "!" Then
                If Much("+-&|=^<>", Mid(表达式, pos1, 1)) Then
                    pos1 = pos1 - 1: Exit For
                End If
            End If

            If pos1 = Len(表达式) Then Exit For
        Next
        'If much(表达式, "&&") Or much(表达式, "||") Then noact = True
        If pos1 > Len(表达式) Then pos1 = Len(表达式)
        If dengyu Then n = n - 1
        If (符号 = "+" Or 符号 = "-") And dengyu = True Then
            If c1 <> "" And c2 <> "" Then
                SendError "单目运算错了？"
                result = 0
                noact = True
            End If
        ElseIf 符号 = "+" And Not dengyu Then
            noact = True
        End If
        If 符号 = "!" Then
            c2 = Trim(Mid(表达式, n + 1, pos1 - n))
            If c2 = "" Then noact = True
        End If
        If Not noact Then
            
            If dengyu Then n = n + 1
            If c2 <> "" Then
                c2 = c2 '计算表达式(c2)
            Else
                If pos1 - n < 0 Then pos1 = n
                c2 = Trim(Mid(表达式, n + 1, pos1 - n))
            End If
            
            Select Case 符号
                Case "!"
                    If c1 = "" And c2 <> "" Then
                        result = 计算表达式(c2)
                        If result = "True" Then
                            result = False
                        ElseIf result = "False" Then
                            result = True
                        End If
                    End If
                Case "+"
                    If dengyu Then
                        If c1 = "" And c2 <> "" Then
                            result = Val(读变量(c2)) + 1
                            加变量 c2, Val(读变量(c2)) + 1, 2
                        ElseIf c1 <> "" And c2 = "" Then
                            result = Val(读变量(c1))
                            加变量 c1, Val(读变量(c1)) + 1, 2
                        End If
                    End If
                Case "-"
                    If dengyu Then
                        If c1 = "" And c2 <> "" Then
                            result = Val(读变量(c2)) - 1
                            加变量 c2, Val(读变量(c2)) - 1, 2
                        ElseIf c1 <> "" And c2 = "" Then
                            result = Val(读变量(c1))
                            加变量 c1, Val(读变量(c1)) - 1, 2
                        End If
                    Else
                        If c1 = "" And c2 <> "" Then result = 转储字符串("-" & c2) Else noact = True
                    End If
                    
            End Select
            If pos2 = 0 Then
                表达式 = Left(表达式, pos2) & result & Right(表达式, Len(表达式) - pos1)
            Else
                表达式 = Left(表达式, pos2 - 1) & result & Right(表达式, Len(表达式) - pos1)
            End If
            If posn = 0 Then posn = 1
            posn = Len(result) + pos2
        Else
            posn = posn + 2
        End If
        If posn <> 0 Then
            n1 = InStr(posn, 表达式, "!")
            n2 = InStr(posn, 表达式, "+")
            n3 = InStr(posn, 表达式, "-")
            n = 999999
            If n1 < n And n1 <> 0 Then
                符号 = "!"
                n = n1
            End If
            If n2 < n And n2 <> 0 Then
                符号 = "+"
                n = n2
            End If
            If n3 < n And n3 <> 0 Then
                符号 = "-"
                n = n3
            End If
            If n = 999999 Then n = 0
        Else
            n = 0
        End If
    Wend
    单目运算优先 = 表达式
    Debug.Print 表达式


Exit Function
    'Dim pos1 As Long, pos2 As Long
    'Dim c1 As String, c2 As String
    'Dim n As Long, n1 As Long, n2 As Long, n3 As Long, posn As Long
    'Dim result As String, str As String
    'Dim 符号 As String
    'Dim dengyu As Boolean
    'Dim noact As Boolean
    posn = 1
    n1 = InStr(posn, 表达式, "!")
    n2 = InStr(posn, 表达式, "+")
    n3 = InStr(posn, 表达式, "-")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "!"
        n = n1
    End If
    If n2 < n And n2 <> 0 Then
        符号 = "+"
        n = n2
    End If
    If n3 < n And n3 <> 0 Then
        符号 = "-"
        n = n3
    End If
    If n = 999999 Then n = 0
    While n <> 0
        dengyu = False
        noact = False
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("+-!&|=", Mid(表达式, pos1, 1)) Then
                If dengyu Then pos1 = pos1 - 1: Exit For
                
                If 符号 = "+" Then
                    If Mid(表达式, pos1, 1) = "+" Then dengyu = True Else pos1 = pos1 - 1: Exit For
                ElseIf 符号 = "-" Then
                    If Mid(表达式, pos1, 1) = "-" Then dengyu = True Else pos1 = pos1 - 1: Exit For
                End If
                If 符号 = "!" Then pos1 = pos1 - 1: Exit For
            ElseIf 符号 <> "-" Then
                noact = True
                Exit For
                
                'If 符号 = "+" Then
                '    If Mid(表达式, pos1, 1) = "+" Then dengyu = True Else pos1 = pos1 - 1: Exit For
                'ElseIf 符号 = "-" Then
                '    If Mid(表达式, pos1, 1) = "-" Then dengyu = True Else pos1 = pos1 - 1: Exit For
                'End If
                'If 符号 = "-" Then pos1 = pos1 - 1: Exit For
            End If
            If pos1 = Len(表达式) Then Exit For
        Next
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("+-!&|", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        If Not noact And ((dengyu = True And 符号 = "+") Or 符号 = "-" Or 符号 = "!") Then
            If pos2 = 0 Then
            'pos2 = 1
            c1 = ""
            Else
            c1 = 计算表达式(Trim(Mid(表达式, pos2, n - pos2)))
            End If
            If dengyu Then n = n + 1
            c2 = 计算表达式(Trim(Mid(表达式, n + 1, pos1 - n)))
            Select Case 符号
                Case "!"
                    If c1 = "" And c2 <> "" Then
                        result = c2
                        If LCase(c2) = "true" Then result = False
                        If LCase(c2) = "false" Then result = True
                    End If
                Case "+"
                    If dengyu Then
                        'result = False
                        '读变量()
                        result = 520
                    End If
                Case "-"
                    If dengyu Then
                        result = 521
                    End If
                    If c1 = "" Then result = 转储字符串("-" & c2) Else noact = True
            End Select
                
            If (result <> "" Or 符号 <> "!") And Not noact Then
                
                表达式 = Left(表达式, pos2) & result & Right(表达式, Len(表达式) - pos1)
                If pos2 = 0 Then pos2 = 1
                posn = Len(result) + pos2
            Else
                posn = posn + 2
            End If
            'DoEvents
        Else
            posn = posn + 2
        End If
        If posn <> 0 Then
            n1 = InStr(posn, 表达式, "!")
            n2 = InStr(posn, 表达式, "+")
            n3 = InStr(posn, 表达式, "-")
            n = 999999
            If n1 < n And n1 <> 0 Then
                符号 = "!"
                n = n1
            End If
            If n2 < n And n2 <> 0 Then
                符号 = "+"
                n = n2
            End If
            If n3 < n And n3 <> 0 Then
                符号 = "-"
                n = n3
            End If
            If n = 999999 Then n = 0
        End If
    Wend
    单目运算优先 = 表达式
    Debug.Print 表达式
End Function
Function 双目运算合并(表达式)
    If IsNumeric(表达式) Then 双目运算合并 = 表达式: Exit Function
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim noact As Boolean
    posn = 1
    n1 = InStr(posn, 表达式, "+")
    n2 = InStr(posn, 表达式, ".")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "&"
        n = n1
    End If
    
    If n2 < n And n2 <> 0 Then
        符号 = "."
        n = n2
    End If
    
    If n = 999999 Then n = 0
    While n <> 0
        noact = False
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("<>=%&.!^", Mid(表达式, pos1, 1)) Then pos1 = pos1 - 1: Exit For
            If pos1 = Len(表达式) Then Exit For
        Next
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("<>=%&.!^", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        If pos2 = 0 Then
        Else
        c1 = Trim(Mid(表达式, pos2, n - pos2))
        End If
        c2 = Trim(Mid(表达式, n + 1, pos1 - n))
        If Singles(c1, """") Or Singles(c1, "'") Then
            noact = True
        End If
        If Singles(c2, """") Or Singles(c2, "'") Then
            noact = True
        End If
        If 符号 = "." Then
            If IsNumeric(c1) And IsNumeric(c2) Then
                noact = True
            End If
        End If
        If c1 = "" Then noact = True
        If Not noact Then
            Select Case 符号
            Case "+"
                result = 计算表达式(c1) & 计算表达式(c2)
            Case "."
                If IsNumeric(c2) And IsNumeric(c1) Then
                    noact = True
                Else
                    result = 转添字符串(计算表达式(c1) & 计算表达式(c2))
                End If
            End Select
            str = Mid(表达式, pos2, pos1 - pos2 + 1)
            表达式 = Replace(表达式, str, result)
            'DoEvents
            posn = Len(result) + pos2
        Else
            posn = posn + 2
        End If
        n1 = InStr(posn, 表达式, "&")
        n2 = InStr(posn, 表达式, ".")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "+"
            n = n1
        End If
        
        If n2 < n And n2 <> 0 Then
            符号 = "."
            n = n2
        End If
        
        If n = 999999 Then n = 0
        
    Wend
    双目运算合并 = 表达式
    Debug.Print 表达式
End Function

Function 双目运算加减(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim noact As Boolean
    posn = 1
    n1 = InStr(posn, 表达式, "+")
    n2 = InStr(posn, 表达式, "-")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "+"
        n = n1
    End If
    
    If n2 < n And n2 <> 0 Then
        符号 = "-"
        n = n2
    End If
    
    If n = 999999 Then n = 0
    While n <> 0
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("+-\%<>=!&|^", Mid(表达式, pos1, 1)) Then pos1 = pos1 - 1: Exit For
            If pos1 = Len(表达式) Then Exit For
        Next
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("+-\%<>=!&|^", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        
        If pos2 = 0 Then
            c1 = 0
        Else
            c1 = Trim(Mid(表达式, pos2, n - pos2))
        End If
        c2 = Trim(Mid(表达式, n + 1, pos1 - n))
        'c1 = 计算表达式(c1)
        'c2 = 计算表达式(c2)
        If Singles(c1, """") Or Singles(c1, "'") Or c1 = "" Then
            noact = True
        End If
        If Singles(c2, """") Or Singles(c2, "'") Or c2 = "" Then
            noact = True
        End If
        
        If Not noact Then
            Select Case 符号
                Case "+"
                    c1 = 计算表达式(c1)
                    c2 = 计算表达式(c2)
                    If IsNumeric(c1) And IsNumeric(c2) Then
                        result = Val(c1) + Val(c2)
                    Else
                        result = 转字符串(c1 & c2)
                    End If
                    
                Case "-"
                    c1 = 计算表达式(c1)
                    c2 = 计算表达式(c2)
                    If IsNumeric(c1) And IsNumeric(c2) Then
                        'c1 = 计算表达式(c1)
                        'c2 = 计算表达式(c2)
                        result = c1 - c2
                    Else
                        'result = c1 - c2
                        SendError "字符串怎么减你告诉我！"
                        Exit Function
                    End If
            End Select
            If pos2 = 0 Then pos2 = 1
            str = Mid(表达式, pos2, pos1 - pos2 + 1)
            表达式 = Replace(表达式, str, result)
            '表达式 = Left(表达式, n - 1) & result & Right(表达式, Len(表达式) - pos1 - pos2 - 1)
            'DoEvents
            posn = Len(result) + pos2
        Else
            posn = posn + 1
        End If
        n1 = InStr(posn, 表达式, "+")
        n2 = InStr(posn, 表达式, "-")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "+"
            n = n1
        End If
        
        If n2 < n And n2 <> 0 Then
            符号 = "-"
            n = n2
        End If
        
        If n = 999999 Then n = 0
        
    Wend
    双目运算加减 = 表达式
    Debug.Print 表达式
End Function
Function 双目运算优先(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, n4 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim noact As Boolean
    posn = 1
    n1 = InStr(posn, 表达式, "^")

    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "^"
        n = n1
    End If

    If n = 999999 Then n = 0
    While n <> 0
        noact = False
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("+-*/^\!%&|><=", Mid(表达式, pos1, 1)) Then pos1 = pos1 - 1: Exit For
            If pos1 = Len(表达式) Then Exit For
        Next
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("+-*/^\!%&|><=", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        If pos2 = 0 Then pos2 = 1
        c1 = 计算表达式(Mid(表达式, pos2, n - pos2))
        c2 = 计算表达式(Mid(表达式, n + 1, pos1 - n))
        If Singles(c1, """") Or Singles(c1, "'") Or c1 = "" Then
            noact = True
        End If
        If Singles(c2, """") Or Singles(c2, "'") Or c2 = "" Then
            noact = True
        End If
        If Not IsNumeric(c1) And Not IsNumeric(c2) Then
            SendError "双目运算需要数字！"
            noact = True
        End If
        If Not noact Then
            Select Case 符号
            Case "^"
                result = Val(c1) ^ Val(c2)
            End Select
            If Int(Val(result)) <> result Then result = Format(result, "0.###############")
                If Much(result, "E+") Then result = Format(result, "#")
                If Much(result, "E-") Then result = Format(result, "0.################")
            str = Mid(表达式, pos2, pos1 - pos2 + 1)
            表达式 = Replace(表达式, str, result)
            'DoEvents
            posn = Len(result) + pos2 - 1
        Else
            posn = posn + 1
        End If

        n1 = InStr(posn, 表达式, "^")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "^"
            n = n1
        End If
        If n = 999999 Then n = 0
    Wend
    双目运算优先 = 表达式
End Function
Function 双目运算乘除(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, n4 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim noact As Boolean
    posn = 1
    n1 = InStr(posn, 表达式, "*")
    n2 = InStr(posn, 表达式, "/")
    n3 = InStr(posn, 表达式, "%")
    n4 = InStr(posn, 表达式, "\")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "*"
        n = n1
    End If
    
    If n2 < n And n2 <> 0 Then
        符号 = "/"
        n = n2
    End If
    If n3 < n And n3 <> 0 Then
        符号 = "%"
        n = n3
    End If
    If n4 < n And n4 <> 0 Then
        符号 = "\"
        n = n4
    End If
    If n = 999999 Then n = 0
    While n <> 0
        noact = False
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("+-*/\!%&|><=", Mid(表达式, pos1, 1)) Then pos1 = pos1 - 1: Exit For
            If pos1 = Len(表达式) Then Exit For
        Next
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("+-*/\!%&|><=", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        If pos2 = 0 Then pos2 = 1
        c1 = 计算表达式(Mid(表达式, pos2, n - pos2))
        c2 = 计算表达式(Mid(表达式, n + 1, pos1 - n))
        If Singles(c1, """") Or Singles(c1, "'") Or c1 = "" Then
            noact = True
        End If
        If Singles(c2, """") Or Singles(c2, "'") Or c2 = "" Then
            noact = True
        End If
        If Not IsNumeric(c1) And Not IsNumeric(c2) Then
            SendError "乘除运算需要要数字！"
            noact = True
        End If
        If Not noact Then
            Select Case 符号
            Case "*"
                result = c1 * c2
            Case "/"
                If c2 = 0 Then SendError "除数为0！": Exit Function
                result = c1 / c2
            Case "%"
                result = c1 Mod c2
            Case "\"
                result = c1 \ c2
            End Select
            If Int(Val(result)) <> result Then result = Format(result, "0.###############")
            If Much(result, "E+") Then result = Format(result, "#")
            If Much(result, "E-") Then result = Format(result, "0.################")
            str = Mid(表达式, pos2, pos1 - pos2 + 1)
            表达式 = Replace(表达式, str, result)
            'DoEvents
            posn = Len(result) + pos2 - 1
        Else
            posn = posn + 1
        End If

        n1 = InStr(posn, 表达式, "*")
        n2 = InStr(posn, 表达式, "/")
        n3 = InStr(posn, 表达式, "%")
        n4 = InStr(posn, 表达式, "\")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "*"
            n = n1
        End If
        
        If n2 < n And n2 <> 0 Then
            符号 = "/"
            n = n2
        End If
        
        If n3 < n And n3 <> 0 Then
            符号 = "%"
            n = n3
        End If
        
        If n4 < n And n4 <> 0 Then
            符号 = "\"
            n = n4
        End If
        If n = 999999 Then n = 0
    Wend
    双目运算乘除 = 表达式
End Function
Function 双目运算逻辑(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim dengyu As Boolean

    dengyu = False
    posn = 1
    n1 = InStr(posn, 表达式, "&")
    n2 = InStr(posn, 表达式, "|")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "&"
        n = n1
    End If
    
    If n2 < n And n2 <> 0 Then
        符号 = "|"
        n = n2
    End If
    
    If n = 999999 Then n = 0
    While n <> 0
        dengyu = False
        'n = 5
        If 符号 = "&" Then
            If Mid(表达式, n + 1, 1) = "&" Then dengyu = True
        ElseIf 符号 = "|" Then
            If Mid(表达式, n + 1, 1) = "|" Then dengyu = True
        End If
        If dengyu Then n = n + 1
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("&|", Mid(表达式, pos1, 1)) Then
            'If dengyu Then Exit For 'pos1 = pos1 - 1
                pos1 = pos1 - 1
                Exit For

            End If
            If pos1 = Len(表达式) Then Exit For
        Next
        If dengyu Then n = n - 1
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("&|", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        n = n + 1
        c1 = ""
        If pos2 <> 0 Then c1 = Trim(Mid(表达式, pos2, n - pos2 - 1))
        If Not dengyu Then n = n - 1
        c2 = Trim(Mid(表达式, n + 1, pos1 - n))
        
        'If str = "True" Then c1 = True Else c1 = False
        'str = 计算表达式(Trim(Mid(表达式, n + 1, pos1 - n + 1)))
        'If str = "True" Then c2 = True Else c2 = False
        
        Select Case 符号
        Case "&"
            If dengyu Then
                result = False
                If 计算表达式(c1) = "True" Then
                    If 计算表达式(c2) = "True" Then
                        result = True
                    End If
                End If
            Else
                If 计算表达式(c1) = "True" And 计算表达式(c2) = "True" Then
                    result = True
                Else
                    result = False
                End If
            End If
        Case "|"
            If dengyu Then
                result = False
                If 计算表达式(c1) = "True" Then
                    result = True
                ElseIf 计算表达式(c2) = "True" Then
                    result = True
                End If
            Else
                If 计算表达式(c1) = "True" Or 计算表达式(c2) = "True" Then
                    result = True
                Else
                    result = False
                End If
            End If
        End Select
        str = ""
        If pos2 <> 0 Then str = Mid(表达式, pos2, pos1 - pos2 + 1)
        表达式 = Replace(表达式, str, result)
        'DoEvents
        posn = Len(result) + pos2 - 1
        
        n1 = InStr(posn, 表达式, "&")
        n2 = InStr(posn, 表达式, "|")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "&"
            n = n1
        End If
        
        If n2 < n And n2 <> 0 Then
            符号 = "|"
            n = n2
        End If
        
        If n = 999999 Then n = 0
        
    Wend
    双目运算逻辑 = 表达式
    Debug.Print 表达式
End Function

Function 双目运算赋值(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim dengyu As Boolean
    Dim noact As Boolean
    dengyu = False
    posn = 1
    n1 = InStr(posn, 表达式, "=")
    'n2 = InStr(posn, 表达式, "|")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "="
        n = n1
    End If
    
    'If n2 < n And n2 <> 0 Then
    '    符号 = "|"
    '    n = n2
    'End If
    
    If n = 999999 Then n = 0
    While n <> 0
        noact = False
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much(";", Mid(表达式, pos1, 1)) Then
                pos1 = pos1 - 1: Exit For
                
            End If
            If pos1 = Len(表达式) Then Exit For
        Next
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much(";", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        If pos2 = 0 Then pos2 = 1
        c1 = Trim(Mid(表达式, pos2, n - pos2))
        If c1 = "" Then noact = True
        If Not noact Then
            If dengyu Then n = n + 1
            c2 = 计算表达式(Trim(Mid(表达式, n + 1, pos1 - n)))
            'If c2 <> True And c2 <> False Then
            'If c2 <> "" And c2 <> "True" And c2 <> "False" Then c2 = 转字符串(c2)
            'End If
            Select Case 符号
            Case "="
                加变量 c1, c2, 1
                result = c2
            End Select
            str = Mid(表达式, pos2, pos1 - pos2 + 1)
            表达式 = Replace(表达式, str, result)
            'DoEvents
            posn = Len(result) + pos2 - 1
        Else
            posn = posn + 1
        End If
        n1 = InStr(posn, 表达式, "=")
        'n2 = InStr(posn, 表达式, "|")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "&"
            n = n1
        End If
        
        'If n2 < n And n2 <> 0 Then
        '    符号 = "|"
        '    n = n2
        'End If
        
        If n = 999999 Then n = 0
        
    Wend
    双目运算赋值 = 表达式
    Debug.Print 表达式
End Function


Function 双目运算判断(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim dengyu As Boolean
    dengyu = False
    posn = 1
    n1 = InStr(posn, 表达式, ">")
    n2 = InStr(posn, 表达式, "<")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = ">"
        n = n1
    End If
    
    If n2 < n And n2 <> 0 Then
        符号 = "<"
        n = n2
    End If
    
    If n = 999999 Then n = 0
    While n <> 0
        dengyu = False
        If Mid(表达式, n + 1, 1) = "=" Then
            dengyu = True
        End If
        For pos1 = n + 1 To Len(表达式) '后面的
            'If much("<>=&|!", Mid(表达式, pos1, 1)) Then
            '    pos1 = pos1 - 1
            '    If Mid(表达式, pos1 + 1, 1) = "=" Then dengyu = True: n = n + 1
            '    Exit For
            'End If
            If pos1 = Len(表达式) Then Exit For
        Next
        If pos1 > Len(表达式) Then pos1 = Len(表达式)
        For pos2 = n - 1 To 1 Step -1 '前面的
            If pos2 = 1 Then Exit For
            If Much("<>=&|!", Mid(表达式, pos2, 1)) Then
                pos2 = pos2 + 1: Exit For
            End If
        Next
        c1 = 计算表达式(Mid(表达式, pos2, n - pos2))
        If dengyu Then n = n + 1
        c2 = 计算表达式(Mid(表达式, n + 1, pos1 - n))
        Select Case 符号
        Case ">"
            If dengyu Then
                result = Val(c1) >= Val(c2)
            Else
                result = Val(c1) > Val(c2)
            End If
        Case "<"
            If dengyu Then
                result = Val(c1) <= Val(c2)
            Else
                result = Val(c1) < Val(c2)
            End If
        End Select
        str = Mid(表达式, pos2, pos1 - pos2 + 1)
        表达式 = Replace(表达式, str, result)
        'DoEvents
        posn = Len(result) + pos2 - 1
        
        n1 = InStr(posn, 表达式, ">")
        n2 = InStr(posn, 表达式, "<")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = ">"
            n = n1
        End If
        
        If n2 < n And n2 <> 0 Then
            符号 = "<"
            n = n2
        End If
        
        If n = 999999 Then n = 0
        
    Wend
    双目运算判断 = 表达式
    Debug.Print 表达式
End Function
Function 双目运算等于(表达式)
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String
    Dim n As Long, n1 As Long, n2 As Long, posn As Long
    Dim result As String, str As String
    Dim 符号 As String
    Dim dengyu As Boolean
    dengyu = False
    posn = 1
    n1 = InStr(posn, 表达式, "!")
    n2 = InStr(posn, 表达式, "=")
    n = 999999
    If n1 < n And n1 <> 0 Then
        符号 = "!"
        n = n1
    End If
    
    If n2 < n And n2 <> 0 Then
        符号 = "="
        n = n2
    End If
    
    If n = 999999 Then n = 0
    While n <> 0
        dengyu = False
        If 符号 = "!" Then
            If Mid(表达式, n + 1, 1) = "=" Then dengyu = True
        ElseIf 符号 = "=" Then
            If Mid(表达式, n + 1, 1) = "=" Then dengyu = True
        End If
        If dengyu Then n = n + 1
        For pos1 = n + 1 To Len(表达式) '后面的
            If Much("!=&|", Mid(表达式, pos1, 1)) Then
                pos1 = pos1 - 1: Exit For
            End If
            If pos1 = Len(表达式) Then Exit For
        Next
        If dengyu Then
            For pos2 = n - 2 To 1 Step -1 '前面的
                If pos2 = 1 Then Exit For
                If Much("!=&|", Mid(表达式, pos2, 1)) Then
                    pos2 = pos2 + 1: Exit For
                End If
            Next
            If pos2 = 0 Then
                c1 = ""
            Else
                c1 = 计算表达式(Trim(Mid(表达式, pos2, n - pos2 - 1)))
            End If

            c2 = 计算表达式(Trim(Mid(表达式, n + 1, pos1 - n)))
            Select Case 符号
            Case "!"
                If dengyu Then
                    If c1 <> c2 Then
                        result = True
                    Else
                        result = False
                    End If
                Else
                    result = c2
                    If LCase(c2) = "true" Then result = "false"
                    If LCase(c2) = "false" Then result = "true"
                     '优先级应该提前
                End If
            Case "="
                If dengyu Then
                    If c1 = c2 Then
                        result = True
                    Else
                        result = False
                    End If
                Else
                    加变量 c1, c2, 0
                    result = c2
                End If
            End Select
            If pos2 = 0 Then pos2 = 1
            str = Mid(表达式, pos2, pos1 - pos2 + 1)
            表达式 = Replace(表达式, str, result)
            'DoEvents
            posn = Len(result) + pos2
        Else
            posn = posn + 1
        End If
        n1 = InStr(posn, 表达式, "!")
        n2 = InStr(posn, 表达式, "=")
        n = 999999
        If n1 < n And n1 <> 0 Then
            符号 = "!"
            n = n1
        End If
        
        If n2 < n And n2 <> 0 Then
            符号 = "="
            n = n2
        End If
        
        If n = 999999 Then n = 0
        
    Wend
    双目运算等于 = 表达式
    Debug.Print 表达式
End Function
Sub SendError(错误信息 As String, Optional ErrNum As Long = 0, Optional ErrDes As String = "")
    If ErrNum <> 0 Then
        ErrNumber = Err.Number
    Else
        If ErrNum = 0 Then
            ErrNumber = -100
        Else
            ErrNumber = ErrNum
        End If
    End If
    If ErrDes <> "" Then
        ErrDescription = ErrDes
    Else
        If Err.Description <> "" Then
            ErrDescription = Err.Description
        Else
            ErrDescription = 错误信息
        End If
    End If

If CHDebug Then
    RaiseEvent GetERRORLog(错误信息)
    If Not ErrorIgnore Then StopProgram = True
Else
    If Not ErrorIgnore Then
        MsgBox "ERROR：" & 错误信息, vbCritical, "CH Runtime Error"
        End
    End If
End If
End Sub
Sub SendLog(信息 As String)
    RaiseEvent GetLog(信息)
End Sub
Sub SendDebugEvent(信息 As String)
    RaiseEvent DebugEvent(信息)
End Sub
Function 分割参数(ByRef ResArray() As String, 参数 As String, Optional 计算 As Boolean = False)
    Dim s As String
    ReDim ResArray(0)
    'Exit Function
    Dim nn As Long, n As Long, nnn As Long, num As Long
    If Much(参数, ",") Then
        nn = 1
        nnn = 1
        Do
            Do
                n = InStr(nn, 参数, ",")
                If n <> 0 Then
                    s = Mid(参数, nnn, n - nnn)
                    'MsgBox ResArray(1)
                    nn = n + 1
                Else
                    s = Mid(参数, nnn)
                    nn = Len(参数) + 1
                    Exit Do
                End If
            
            Loop Until Howmuch(s, "(") = Howmuch(s, ")")
            nnn = nn
            
            If 计算 Then ResArray(num) = 计算表达式(s) Else ResArray(num) = s
            num = num + 1
            n = InStr(nn, 参数, ",")
            If n <> 0 Then ReDim Preserve ResArray(num)
        Loop Until n = 0
        s = Mid(参数, nn)
        If s = "" Then
            num = num - 1
        Else
            ReDim Preserve ResArray(num)
            If 计算 Then ResArray(num) = 计算表达式(s) Else ResArray(num) = s
        End If
        'MsgBox ResArray(3)
    Else
        If 计算 Then ResArray(num) = 计算表达式(参数) Else ResArray(num) = 参数
    End If
End Function
Function RealRun() As Boolean
On Error GoTo errs:
    Debug.Print 0 / 0
    RealRun = True
Exit Function
errs:
    RealRun = False
End Function
Function 执行函数(函数名 As String, 参数 As String, Optional 附加代码块 As String) As String
    If RealRun Then On Error GoTo errsh:
    If 函数名 = "" Then 执行函数 = 计算表达式(参数): Exit Function
    Dim c() As String
    Dim num As Long, LimiterN As Long
    分割参数 c(), 参数
    num = UBound(c)

'MsgBox c(1)

    Dim canshun As Long
    Dim canshu As Variant
    Dim temp As String
    Dim ret As Boolean
    For Each canshu In c
        If c(canshun) <> "" Then
            Select Case 函数名
                Case "def", "try", "function", "ch", "if", "iif", "for", "while", "do", "f", "i", "w", "d", "re", "重复", "循环", "gc", "switch", "case", "choose"
                Case Else
                    c(canshun) = 计算表达式(Trim(c(canshun)))
                    If StopProgram Then Exit Function
            End Select
        End If
        canshun = canshun + 1
    Next
    
    
    Dim customblockn As Long
    For customblockn = 0 To 代码块数 - 1
        If 代码块(customblockn).names = 函数名 Then
            Dim CanShuShuZuN As Long, CanShuShuZuN1, customblockn2 As Long
            Dim tempcanshu As String
            If SafeArrayGetDim(代码块(customblockn).canshu) <> 0 Then
                For Each CanShuShuZuN1 In 代码块(customblockn).canshu '代码块(customblockn).canshu
                    Dim CanShuShuZu As String
                    CanShuShuZu = CanShuShuZuN1
                    加变量 CanShuShuZu, c(CanShuShuZuN), 0
                    CanShuShuZuN = CanShuShuZuN + 1
                Next
            
            End If
            
            For customblockn2 = 0 To 代码块数 - 1
                If 代码块(customblockn2).names = 代码块(customblockn).Code Then
                    执行函数 = 计算表达式(代码块(customblockn2).Code)
                    ExitFunction = False
                    Exit Function
                End If
            Next
            执行函数 = 计算表达式(代码块(customblockn).Code)
            ExitFunction = False
            Exit Function
        End If
    Next
    Dim ObjTempN As Long
    For ObjTempN = 0 To 对象数 - 1
        If LCase(对象(ObjTempN).names) = 函数名 Then
            执行函数 = ExecuteAddressAPI(对象(ObjTempN).hwnd, c)
            Exit Function
        End If
    Next
    
    Select Case 函数名
        Case "="
            执行函数 = 计算表达式(c(0))
        Case "!", "not"
            If LCase(c(0)) = "false" Then
                执行函数 = True
            Else
                执行函数 = False
            End If
        Case "and", "和"
            If c(0) And c(1) Then 执行函数 = True Else 执行函数 = False
        Case "switch"
            Dim switchtj As String
            Dim tempswitch As Long
            switchtj = 计算表达式(c(0))
            For tempswitch = 0 To Int(num / 2) - 1
                If switchtj = 计算表达式(c(tempswitch * 2 + 1)) Then
                    If ExitFunction Then
                        ExitFunction = False
                        执行函数 = 计算表达式(c(tempswitch * 2 + 2))
                        ExitFunction = True
                    Else
                        执行函数 = 计算表达式(c(tempswitch * 2 + 2))
                    End If
                End If
                If ExitFunction Then Exit For
                If StopProgram Then Exit Function
            Next
            ExitFunction = False
        Case "case"
            Dim switchtj2 As String
            Dim tempswitch2 As Long
            switchtj2 = 计算表达式(c(0))
            For tempswitch2 = 0 To Int(num / 2) - 1
                If switchtj2 = 计算表达式(c(tempswitch2 * 2 + 1)) Then
                    执行函数 = 计算表达式(c(tempswitch2 * 2 + 2))
                    Exit Function
                End If
                If ExitFunction Then Exit For
                If StopProgram Then Exit Function
            Next
            If num Mod 2 = 1 Then
                执行函数 = 计算表达式(c(num))
            End If
            ExitFunction = False
        Case "choose"
            Dim tempchoose As Long
            tempchoose = Val(计算表达式(c(0)))
            If num > tempchoose And tempchoose >= 0 Then
                执行函数 = 计算表达式(c(tempchoose + 1))
            Else
                SendError "choose 所需的第一个参数必须大于等于0！"
            End If
        Case "if", "iif", "如果", "i"
            Select Case num
            Case 1
                ret = 计算表达式(c(0)) = "True"
                If ret Then 执行函数 = 计算表达式(c(1))
            Case Is >= 2
                ret = 计算表达式(c(0)) = "True"
                If ret Then 执行函数 = 计算表达式(c(1))
                If Not ret Then 执行函数 = 计算表达式(c(2))
            End Select
        Case "exit"
            ExitFunction = True
        Case "end"
            StopProgram = True
        Case "try"
            ErrNumber = 0
            If Not ErrorIgnore Then
                ErrorIgnore = True
                执行函数 = 计算表达式(c(0))
                ErrorIgnore = False
            Else
                执行函数 = 计算表达式(c(0))
            End If
            ExitFunction = False
            If num >= 1 And ErrNumber <> 0 Then GoTo tryerrs:
            Exit Function
tryerrs:
            If ErrNumber <> 0 Then
                加变量 c(1), ErrNumber & "," & ErrDescription, 0
                计算表达式 c(2)
            End If
            ExitFunction = False
        Case "def", "function", "func"
            Dim FuncCan() As String
            If num > 1 Then '2
                ReDim FuncCan(num - 2) As String
                Dim FuncN As Long
                For FuncN = 0 To num - 2
                    FuncCan(FuncN) = c(FuncN + 1)
                Next
            End If
            If num >= 1 Then
                AddCusFunc c(0), c(num), FuncCan
                执行函数 = True
            Else
                执行函数 = False
            End If
        Case "command"
            执行函数 = Command
        Case "creapi", "getdll"
            执行函数 = CreateApi(c(0), c(1))
        Case "api"
            Dim retpre As Long
            retpre = ExistApi(c(0))
            执行函数 = ExecuteAPI(retpre, c(1), c(2))
        Case "defapi", "bindapi"
            执行函数 = BindApi(c(0), Int(c(1)))
            
        Case "getapi"
            执行函数 = GetAddressAPI(Int(c(0)), c(1))
        Case "freeapi", "freedll"
            执行函数 = FreeAPI(Int(c(0)))
        Case "ch"
        Case "for", "f"
            计算表达式 (c(0))
            temp = c(1)
            If num < 3 Then 执行函数 = False: Exit Function
            Dim result As String, forcode As String
            forcode = c(3)
            While 计算表达式(temp) And Not ExitFunction
                执行函数 = 计算表达式(forcode)
                If Not ExitFunction Then
                    计算表达式 (c(2))
                    temp = c(1)
                End If
                If StopProgram Then Exit Function
            Wend
            ExitFunction = False
        Case "deflim"
            If c(0) = "True" Then
                变量NoMoney = True
            Else
                变量NoMoney = False
            End If
            执行函数 = 变量NoMoney
        Case "hinst"
        
            执行函数 = App.hInstance
        Case "re", "重复", "循环"
            If IsNumeric(c(0)) Then
                Dim i As Long
                For i = 1 To c(0)
                    执行函数 = 计算表达式(c(1))
                    If ExitFunction Then Exit For
                    If StopProgram Then Exit Function
                Next
                ExitFunction = False
            Else
                执行函数 = False
            End If
        Case "doevents"
            DoEvents
        Case "vb", "vbs"
            Dim objScrCtlvb As Object
            Set objScrCtlvb = CreateObject("MSScriptControl.ScriptControl")
            objScrCtlvb.Language = "vbs"
            执行函数 = objScrCtlvb.Eval(c(0))
            Set objScrCtlvb = Nothing
        Case "js", "javascript"
            Dim objScrCtljs As Object
            Set objScrCtljs = CreateObject("MSScriptControl.ScriptControl")
            objScrCtljs.Language = "JavaScript"
            执行函数 = objScrCtljs.Eval(c(0))
            Set objScrCtljs = Nothing
        Case "while", "w"
            temp = c(0)
            
            While 计算表达式(temp) = "True" And Not ExitFunction
                执行函数 = 计算表达式(c(1))
                temp = c(0)
                If StopProgram Then Exit Function
            Wend
            ExitFunction = False
        Case "do", "d"
            Dim tempstr As String
            If num < 1 Then
                tempstr = False
            Else
                tempstr = c(1)
            End If
            Do
                执行函数 = 计算表达式(c(0))
                If ExitFunction Then Exit Do
                If StopProgram Then Exit Function
            Loop Until 计算表达式(tempstr) = True
            ExitFunction = False
        Case "msgbox", "out", "tc", "message", "messagebox", "弹出消息", "消息", "弹窗", "alert", "messagebox", "m"
            If num = 0 Then
                执行函数 = MsgBox(c(0), , "")
            ElseIf num = 1 Then
                执行函数 = MsgBox(c(0), c(1), "")
            ElseIf num = 2 Then
                执行函数 = MsgBox(c(0), c(1), c(2))
            End If
        Case "print"
            SendLog c(0)
        Case "cls"
            SendDebugEvent "cls"
        Case "errcls"
            Err.Clear
            ErrNumber = 0
            ErrDescription = ""
        Case "errnum"
            执行函数 = ErrNumber
        Case "errdes"
            执行函数 = ErrDescription
        Case "printl", "line", "newline"
            SendLog c(0) & vbCrLf
        Case "lprint"
            SendLog vbCrLf & c(0)
        Case "msg"
            If num = 0 Then
                MsgBox c(0), , ""
            ElseIf num = 1 Then
                MsgBox c(0), c(1), ""
            ElseIf num = 2 Then
                MsgBox c(0), c(1), c(2)
            End If
            执行函数 = c(0)
        Case "split", "delimiter"
            If num >= 2 Then
                执行函数 = Split(c(0), c(1))(c(2))
            Else
                SendError "函数所需的参数不够！"
            End If
        Case "howmuch"
            If num >= 1 Then
                执行函数 = Howmuch(c(0), c(1))
            Else
                SendError "函数所需的参数不够！"
            End If
        Case "much", "isin"
            If num >= 1 Then
                执行函数 = Much(c(0), c(1))
            Else
                SendError "函数所需的参数不够！"
            End If
        Case "gc" 'GC
            If c(0) = "$" Then
                重置 2
            ElseIf c(0) = "all" Then
                重置 1
            Else
                Dim TempGCFor As Long
                For TempGCFor = 0 To 变量数 - 1
                    If 变量(TempGCFor).name = c(0) Then
                        变量(TempGCFor).name = ""
                        变量(TempGCFor).text = ""
                        执行函数 = True
                        Exit Function
                    End If
                Next

                For TempGCFor = 0 To 代码块数 - 1
                    If 代码块(TempGCFor).names = c(0) Then
                        Erase 代码块(TempGCFor).canshu
                        代码块(TempGCFor).Code = ""
                        代码块(TempGCFor).names = ""
                        执行函数 = True
                        Exit Function
                    End If
                Next
            End If
        Case "jiafa", "jia", "加法", "加"
            执行函数 = Val(c(0)) + Val(c(1))
        Case "jianfa", "jian", "减法", "减"
            执行函数 = Val(c(0)) - Val(c(1))
        Case "chengfa", "cheng", "乘法", "乘"
            执行函数 = Val(c(0)) * Val(c(1))
        Case "chufa", "chu", "除法", "除"
            执行函数 = Val(c(0)) / Val(c(1))
        Case "quyu", "yu", "取余", "余", "qy"
            执行函数 = Val(c(0)) Mod Val(c(1))
        Case "true", "真"
            执行函数 = True
        Case "false", "假"
            执行函数 = False
        Case "eval", "计算" '再执行字符串
            c(0) = TrimCode(c(0))
            If Right(c(0), 1) <> ";" Then c(0) = c(0) & ";"
            c(0) = c(0) & "die;"
            If Not CheckCode(c(0)) Then
                SendError "eval计算表达式错误！"
                执行函数 = False
            Else
                执行函数 = 计算表达式(c(0))
            End If
        Case "compile"
            执行函数 = 输出exe(c(0), c(1))
        Case "void", "空函数"
            执行函数 = ""
        Case "address", "取地址"
            执行函数 = 取变量地址(c(0))
        Case "cr"
            执行函数 = vbCr
        Case "lf"
            执行函数 = vbLf
        Case "crlf"
            If c(0) <> "" Then SendLog vbCrLf & c(0) & vbCrLf
            执行函数 = vbCrLf
        Case "error"
            If c(0) = "False" Then
                ErrorIgnore = True
            Else
                ErrorIgnore = False
            End If
            执行函数 = ErrorIgnore
        Case "int", "quzheng", "取整", "qz"
            If c(0) = "" Or Not IsNumeric(c(0)) Then
                执行函数 = 0
            Else
                执行函数 = Int(c(0))
            End If
        Case "val"
            执行函数 = Val(c(0))
        Case "sleep"
            If IsNumeric(c(0)) Then
                Sleep (c(0))
                执行函数 = True
            Else
                执行函数 = False
            End If
        Case "delay"
            If IsNumeric(c(0)) Then
                Delay (c(0))
                执行函数 = True
            Else
                执行函数 = False
            End If
        Case "gettickcount"
            执行函数 = GetTickCount
        Case "timer"
            执行函数 = Timer
        Case "string"
            执行函数 = String(c(0), c(1))
        Case "space"
            执行函数 = Space(Int(c(0)))
        Case "inputbox", "输出框", "in" '从这里为VB内置函数
            If num = 0 Then
                执行函数 = InputBox(c(0), "", "")
            ElseIf num <= 2 Then
                执行函数 = InputBox(c(0), c(1), c(2))
            Else
                执行函数 = InputBox(c(0), c(1), c(2), c(3), c(4))
            End If
        Case "xyz"
            执行函数 = 读变量(c(0))
        Case "round"
            If num = 1 Then
                执行函数 = Round(c(0), c(1))
            Else
                执行函数 = Round(c(0))
            End If
        Case "left", "左"
            执行函数 = Left(c(0), c(1))
        Case "right", "右"
            执行函数 = Right(c(0), c(1))
        Case "mid"
            If num = 2 Then
                执行函数 = Mid(c(0), c(1), c(2))
            ElseIf num = 1 Then
                执行函数 = Mid(c(0), c(1))
            End If
        Case "fix"
            执行函数 = Fix(c(0))
        Case "len", "长度", "取长度"
            执行函数 = Len(c(0))
        Case "lenfile", "filelen", "文件长度", "文件大小", "wjcd", "wjdx", "取文件长度"
            执行函数 = FileLen(c(0))
        Case "abs", "取绝对值", "绝对值"
            If IsNumeric(c(0)) Then
                执行函数 = Abs(c(0))
            End If
        Case "pi"
            执行函数 = 3.14159265358979
        Case "sin"
            If IsNumeric(c(0)) Then 执行函数 = Sin(c(0))
        Case "cos"
            If IsNumeric(c(0)) Then 执行函数 = Cos(c(0))
        Case "tan"
            If IsNumeric(c(0)) Then 执行函数 = Tan(c(0))
        Case "atn"
            If IsNumeric(c(0)) Then 执行函数 = Atn(c(0))
        Case "sgn"
            If IsNumeric(c(0)) Then 执行函数 = Sgn(c(0))
        Case "exp"
            If IsNumeric(c(0)) Then 执行函数 = Exp(c(0))
        Case "log"
            If IsNumeric(c(0)) Then 执行函数 = Log(c(0))
        Case "sqr"
            If IsNumeric(c(0)) Then 执行函数 = Sqr(c(0))
        Case "randomize", "随机数种子生成器"
            If c(0) <> "" Then
                Randomize (c(0))
            Else
                Randomize
            End If
        Case "rnd", "随机数"
            执行函数 = Rnd
        Case "asc"
            执行函数 = Asc(c(0))
        Case "chr"
            If IsNumeric(c(0)) Then 执行函数 = Chr(c(0))
        Case "replace", "td", "th", "替换", "替代"
            执行函数 = Replace(c(0), c(1), c(2))
        Case "strreverse", "反转", "fz"
            执行函数 = StrReverse(c(0))
        Case "ucase", "dx"
            执行函数 = UCase(c(0))
        Case "lcase", "xx"
            执行函数 = LCase(c(0))
        Case "instr", "cz"
            执行函数 = InStr(c(0), c(1), c(2))
        Case "instrrev", "fcz"
            执行函数 = InStrRev(c(0), c(1), c(2))
        Case "now", "现在时间", "xianzaishijian", "xzsj"
            执行函数 = Now
        Case "date", "日期", "rq", "today"
            执行函数 = Date
        Case "time", "时间", "sj"
            执行函数 = Time
        Case "year", "年"
            If c(0) = "" Then c(0) = Date
            执行函数 = Year(c(0))
        Case "month", "月"
            If c(0) = "" Then c(0) = Date
            执行函数 = Month(c(0))
        Case "day", "日", "r"
            If c(0) = "" Then c(0) = Date
            执行函数 = Day(c(0))
        Case "hour", "时"
            If c(0) = "" Then c(0) = Time
            执行函数 = Hour(c(0))
        Case "minute", "分"
            If c(0) = "" Then c(0) = Time
            执行函数 = Minute(c(0))
        Case "second", "秒"
            If c(0) = "" Then c(0) = Time
            执行函数 = Second(c(0))
        Case "format", "格式化文本"
            执行函数 = Format(c(0), c(1))
        'replace(strreverse(ucase(lcase(instr(now(year(month(day(hour(minute(second(time(
        
        '''''''
        Case "lenb"
            执行函数 = LenB(c(0))
        Case "base64"
            执行函数 = "没来得及，哈哈"
        Case "dir"
            执行函数 = Dir(c(0))
        Case "strlen" '从这里起为PHP内置函数
            执行函数 = Len(c(0))
        Case "substr_count"
            执行函数 = Howmuch(c(0), c(1))
        Case "substr"
            If IsNumeric(c(2)) And c(2) <> "" Then
                If c(2) > 0 Then
                    执行函数 = Mid(c(0), c(1), c(2))
                Else
                    执行函数 = Mid(c(0), Int(c(1)) + Int(c(2)) + 1, -Int(c(2)))
                End If
                Exit Function
            Else
                执行函数 = Mid(c(0), c(1) + 1, Len(c(0)) - c(1))
                Exit Function
            End If
        Case "strchr"
            If IsNumeric(c(1)) And c(1) <> "" Then
                c(1) = Chr(c(1))
            End If
            If c(2) = "" Or c(2) = False Then
                执行函数 = Mid(c(0), InStr(1, c(0), c(1)), Len(c(0)) - InStr(1, c(0), c(1)) + 1)
            End If
            If c(2) = True Then
                执行函数 = Mid(c(0), 1, InStr(1, c(0), c(1)) - 1)
            End If
        Case "strrchr"
            If IsNumeric(c(1)) And c(1) <> "" Then
                c(1) = Chr(c(1))
                执行函数 = Mid(c(0), InStr(1, c(0), c(1)), Len(c(0)) - InStr(1, c(0), c(1)) + 1)
            Else
                执行函数 = Mid(c(0), InStr(1, c(0), c(1)), Len(c(0)) - InStr(1, c(0), c(1)) + 1)
            End If
        Case "strtolower"
            执行函数 = LCase(c(0))
        Case "strtoupper"
            执行函数 = UCase(c(0))
        Case "strrev"
            执行函数 = StrReverse(c(0))
        Case "strpos"
            执行函数 = InStr(1, c(0), c(1))
        Case "strrpos"
            执行函数 = 0
            Do
            执行函数 = InStr(执行函数 + 1, c(0), c(1))
            Loop Until InStr(执行函数 + 1, c(0), c(1)) = 0
        Case "str_repeat"
            If c(1) <> "" And IsNumeric(c(1)) Then
                执行函数 = ""
                Dim 循环blbl As Long
                For 循环blbl = 1 To Int(c(1))
                    执行函数 = 执行函数 & c(0)
                Next
            Else
                SendError "编译器：内置函数参数必选且为整数！"
                Exit Function
            End If
        Case "str_replace"
            执行函数 = Replace(c(2), c(0), c(1))
        Case "ucfirst"
            If Len(c(0)) <> 0 Then 执行函数 = UCase(Left(c(0), 1)) & Right(c(0), Len(c(0)) - 1)
        Case "floor"
            执行函数 = CInt(Format(c(0), "0"))
        Case "ceil"
            执行函数 = CInt(Format(c(0), "0")) + 1
        Case "rand"
            If c(1) = "" Then
                c(1) = 32768
            End If
            If c(0) = "" Then
                c(0) = 0
            End If
            执行函数 = Round(Rnd * (c(0) - c(1)) + c(1))
        Case "error_reporting"
            Dim zzaasdn As String
            zzaasdn = c(0)
            SendError zzaasdn
        '''''''''''''''''''''''''''''''win函数'''''''''''''''''''''
        Case "get"
            If c(0) = "" Then SendError "GET地址不能为空！": Exit Function
            If Not Much(c(0), "//") Then c(0) = "http://" & c(0)
            Dim xmlgethttp, chaoshitime
            Set xmlgethttp = CreateObject("msxml2.xmlhttp")
            With xmlgethttp
                .open "GET", c(0), True
                .setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
                chaoshitime = Timer
                .send
                If num < 1 Then
                    While .ReadyState <> 4 And Timer < chaoshitime + 10
                        DoEvents
                    Wend
                ElseIf IsNumeric(c(1)) Then
                    While .ReadyState <> 4 And Timer < chaoshitime + c(1)
                        DoEvents
                    Wend
                Else
                    While .ReadyState <> 4 And Timer < chaoshitime + 10
                        DoEvents
                    Wend
                End If
                
                执行函数 = .responseText '显示POST之后网页返回的结果
            End With
            Set xmlgethttp = Nothing
        Case "getx"
            If c(0) <> "" Then
                Dim getURL As String
                Dim getarrjilu(10) As String
                Dim getHost As String
                getURL = c(0)
                If Not Much(getURL, "//") Then getURL = "http://" & getURL
                If Much(getURL, "//") Then getHost = Split(Split(getURL, "//")(1), "/")(0)
                Dim getarrjilutemp As Long
                For getarrjilutemp = 1 To 10
                    Dim retread As String
                    retread = 简单计算(读变量(c(1) & getarrjilutemp))
                    If retread <> "" Then getarrjilu(getarrjilutemp) = retread Else getarrjilu(getarrjilutemp) = ""
                Next
                If getarrjilu(2) = "" Then getarrjilu(2) = "utf-8"
                If getarrjilu(3) = "" Then getarrjilu(3) = getHost
                If getarrjilu(4) = "" Then getarrjilu(4) = "CH"
                If getarrjilu(5) = "" Then getarrjilu(5) = "application/x-www-form-urlencoded"
                If getarrjilu(6) = "" Then getarrjilu(6) = getURL
                If getarrjilu(7) = "" Then getarrjilu(7) = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                If getarrjilu(8) = "" Then getarrjilu(8) = getURL
                If getarrjilu(9) = "" Then getarrjilu(9) = "Mozilla/5.0 (Windows NT 11.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36 LBBROWSER"
                If getarrjilu(10) = "" Then getarrjilu(10) = "keep-alive"
                Dim WinHttp As Object
                Set WinHttp = CreateObject("WinHttp.WinHttpRequest.5.1")
                '设置参数
                WinHttp.SetTimeouts 60000, 60000, 60000, 5000 '设置操作超时时间
                WinHttp.Option(4) = 13056 '忽略错误标志
                WinHttp.Option(6) = True '为 True 时，当请求页面重定向跳转时自动跳转，False 不自动跳转，截取服务端返回的302状态。
                WinHttp.open "Get", getURL, True 'GET 或 POST, Url, False 同步方式；True 异步方式
                WinHttp.setRequestHeader "Host", getarrjilu(3)
                WinHttp.setRequestHeader "Connection", getarrjilu(10)
                'WinHttp.SetRequestHeader "DNT", "1"
                WinHttp.setRequestHeader "Content-Length", Len(getarrjilu(1))
                'WinHttp.SetRequestHeader "Cache-Control", "max-age=0"
                WinHttp.setRequestHeader "Accept", getarrjilu(7)
                WinHttp.setRequestHeader "Origin", getarrjilu(8) '接受数据类型
                WinHttp.setRequestHeader "User-Agent", getarrjilu(9) '用户浏览器信息
                WinHttp.setRequestHeader "Content-Type", getarrjilu(5) '编码方式
                WinHttp.setRequestHeader "Referer", getarrjilu(6)
                'WinHttp.SetRequestHeader "Accept-Encoding", "gzip, deflate, sdch"
                'WinHttp.SetRequestHeader "Accept-Language", "zh-CN,zh;q=0.8"
                WinHttp.setRequestHeader "Cookie", getarrjilu(4)
                'WinHttp.SetRequestHeader "Upgrade-Insecure-Requests", "1"
                WinHttp.send getarrjilu(1)
                WinHttp.WaitForResponse
                执行函数 = BytesToBstr(WinHttp.responsebody, getarrjilu(2))
            End If
        
        
        Case "post"
            
            Dim xmlposthttp
            Set xmlposthttp = CreateObject("msxml2.xmlhttp")
            If Not Much(c(0), "//") Then c(0) = "http://" & c(0)

            With xmlposthttp
                .open "POST", c(0), False
                .setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
                If num >= 1 Then
                    .send c(1)
                Else
                    .send ""
                End If

                
                执行函数 = .responseText '显示POST之后网页返回的结果
            End With
            Set xmlposthttp = Nothing
        Case "postx"
            If c(0) <> "" Then
                Dim postURL As String, postData, postEncode, postHost As String, postCookie, postType, postRef, postAccept, postOrigin, postAgent, postConnect
                Dim postarrjilu(10) As String
                postURL = c(0)
                If Not Much(postURL, "//") Then postURL = "http://" & postURL
                If Much(postURL, "//") Then postHost = Split(Split(postURL, "//")(1), "/")(0)
                Dim postarrjilutemp As Long
                For postarrjilutemp = 1 To 10
                    Dim retreadpost As String
                    retreadpost = 简单计算(读变量(c(1) & postarrjilutemp))
                    If retreadpost <> "" Then postarrjilu(postarrjilutemp) = retreadpost Else postarrjilu(postarrjilutemp) = ""
                Next
                If postarrjilu(2) = "" Then postarrjilu(2) = "utf-8"
                If postarrjilu(3) = "" Then postarrjilu(3) = postHost
                If postarrjilu(4) = "" Then postarrjilu(4) = "CH"
                If postarrjilu(5) = "" Then postarrjilu(5) = "application/x-www-form-urlencoded"
                If postarrjilu(6) = "" Then postarrjilu(6) = postURL
                If postarrjilu(7) = "" Then postarrjilu(7) = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                If postarrjilu(8) = "" Then postarrjilu(8) = postURL
                If postarrjilu(9) = "" Then postarrjilu(9) = "Mozilla/5.0 (Windows NT 11.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36 LBBROWSER"
                If postarrjilu(10) = "" Then postarrjilu(10) = "keep-alive"
                Dim WinPostHTTP As Object
                Set WinPostHTTP = CreateObject("WinHTTP.WinHTTPRequest.5.1")
                WinPostHTTP.SetTimeouts 60000, 60000, 60000, 5000
                WinPostHTTP.Option(4) = 13056
                WinPostHTTP.Option(6) = True
                WinPostHTTP.open "post", postURL, False
                WinPostHTTP.setRequestHeader "Host", postarrjilu(3)
                WinPostHTTP.setRequestHeader "Connection", postarrjilu(10)
                WinPostHTTP.setRequestHeader "Content-Length", Len(postData)
                WinPostHTTP.setRequestHeader "Accept", postarrjilu(7)
                WinPostHTTP.setRequestHeader "Origin", postarrjilu(8)
                WinPostHTTP.setRequestHeader "User-Agent", postarrjilu(9)
                WinPostHTTP.setRequestHeader "Content-Type", postarrjilu(5)
                WinPostHTTP.setRequestHeader "Referer", postarrjilu(6)
                WinPostHTTP.setRequestHeader "Cookie", postarrjilu(4)
                WinPostHTTP.send postarrjilu(1)
                WinPostHTTP.WaitForResponse
                执行函数 = BytesToBstr(WinPostHTTP.responsebody, postarrjilu(2))
            End If
        Case "screenwidth", "sw", "屏幕宽"
            执行函数 = Screen.Width
        Case "screenheight", "sh", "屏幕高"
            执行函数 = Screen.Height
        Case "shell"
            If num = 0 Then
                执行函数 = Shell(c(0))
            ElseIf num = 1 Then
                执行函数 = Shell(c(0), c(1))
            End If
        Case "pathtofile"
            If InStrRev(c(0), "/") <> 0 Then
                执行函数 = Mid(c(0), 1, InStrRev(c(0), "/"))
            ElseIf InStrRev(c(0), "\") <> 0 Then
                执行函数 = Mid(c(0), 1, InStrRev(c(0), "\"))
            End If
        Case "getfilefrompath"
            If InStrRev(c(0), "/") <> 0 Then
                执行函数 = Mid(c(0), InStrRev(c(0), "/") + 1)
            ElseIf InStrRev(c(0), "\") <> 0 Then
                执行函数 = Mid(c(0), InStrRev(c(0), "\") + 1)
            End If
        Case "isdebug"
            执行函数 = CHDebug
        Case "apppath", "path"
            If CHDebug And CHDebugPath = "" Then
                执行函数 = AppPath
                SendError "Warn:apppath函数未被保存且未输出exe，将输出编辑器所在路径!"
            ElseIf CHDebug And CHDebugPath <> "" Then
                执行函数 = Mid(CHDebugPath, 1, InStrRev(CHDebugPath, "\"))
                
            Else
                执行函数 = AppPath
            End If 'IIf(Right(App.Path, 1) = "\", App.Path, App.Path & "\")
        Case "openfile", "readfile", "fileopen", "打开文件", "open", "read", "rf"
            Dim FSO As Object
            Set FSO = CreateObject("Scripting.FileSystemObject")
            执行函数 = FSO.opentextfile(c(0), 1).ReadAll
            Set FSO = Nothing
        Case "writefile", "write", "wf"
            Dim FSOwrite As Object
            Set FSOwrite = CreateObject("Scripting.FileSystemObject")
            FSOwrite.opentextfile(c(0), 2, True).Write (c(1))
            执行函数 = True
            Set FSOwrite = Nothing
        Case "appendfile", "append", "add"
            Dim FSOappend As Object
            Set FSOappend = CreateObject("Scripting.FileSystemObject")
            FSOappend.opentextfile(c(0), 8, True).Write (c(1))
            执行函数 = True
            Set FSOappend = Nothing
        Case "existfile", "文件是否存在", "ef", "exist"
            If Dir(c(0), vbNormal) = "" Then 执行函数 = False Else 执行函数 = True
        Case "existdir", "文件夹是否存在"
            If Dir(c(0), vbDirectory) = "" Then 执行函数 = False Else 执行函数 = True
        Case "test", "测试"
            执行函数 = ""
        Case Else
            SendError "无此函数：" & 函数名
            执行函数 = ""
    End Select
'If Not IsNumeric(执行函数) Then 执行函数 = 转字符串(执行函数)
Exit Function
errsh:
SendError "抱歉执行函数程序出错，请反馈以下信息：" & Err.Number & "，" & Err.Description & "" & vbCrLf & "请确保您的代码正确哦！", Err.Number, Err.Description
End Function
Function 转字符串(表达式 As String)
If IsNumeric(表达式) Then
    转字符串 = 表达式
Else
    转字符串 = "'" & Replace(表达式, "'", "''") & "'"
    End If
End Function
Function 转添字符串(表达式 As String) As String
转添字符串 = "$_" & Format(变量数, "000000")
加变量 转添字符串, 转字符串(表达式), 0
End Function


Function 简单计算(表达式 As String)
    If IsNumeric(表达式) Then 简单计算 = 表达式: Exit Function
    If Len(表达式) >= 2 Then
        If Left(表达式, 1) = """" Then
            If Right(表达式, 1) = """" Then
                'If Not much(Mid(表达式, 2, Len(表达式) - 2), """") Then
                    
                    简单计算 = Mid(表达式, 2, Len(表达式) - 2)
                    简单计算 = Replace(简单计算, "\n", Chr(10))
                    简单计算 = Replace(简单计算, "\r", Chr(13))
                    '简单计算 = Replace(简单计算, "\\", "\")
                    简单计算 = Replace(简单计算, "\t", Chr(9))
                    简单计算 = Replace(简单计算, "\$", "$")
                    简单计算 = Replace(简单计算, "\'", "'")
                    简单计算 = Replace(简单计算, "\""", """")
                    简单计算 = Replace(简单计算, "\n", Chr(13))
                    
                    Exit Function
                'End If
            End If
        End If
        If Left(表达式, 1) = "'" Then
            If Right(表达式, 1) = "'" Then
                'If Not much(Mid(表达式, 2, Len(表达式) - 2), "'") Then
                    简单计算 = Mid(表达式, 2, Len(表达式) - 2)
                    简单计算 = Replace(简单计算, "''", "'")
                    Exit Function
                'End If
            End If
        End If
    End If
    简单计算 = 表达式
End Function
Private Function 检测变量合法性(变量名字) As Boolean
    If Not 变量NoMoney Then
        Dim 变量名 As String, 循环每个字符 As Long
        变量名 = 变量名字
        
        If Left(变量名, 1) <> "$" Then Exit Function
        变量名 = Right(变量名, Len(变量名) - 1)
        If IsNumeric(Left(变量名, 1)) Then Exit Function
        For 循环每个字符 = 1 To Len(变量名)
            If Much("$./?<>{}|\+-*&^%#@!~`:;""', ", Mid(变量名, 循环每个字符, 1)) Then
                Exit Function
            End If
        Next
    End If
    检测变量合法性 = True
End Function
Function 计算表达式(ByVal 表达式 As String)
If StopProgram Then Exit Function
If RealRun Then On Error GoTo jsbds:
    Dim str As String, str2 As String
    Dim n As Long, n2 As Long
    Dim p As Long
    Dim pos As Long, result As String
    Dim 最最初表达式 As String, 最初表达式 As String
    表达式 = Trim(表达式)
    最最初表达式 = 表达式
    If LCase(表达式) = "true" Then 计算表达式 = "True": Exit Function
    If LCase(表达式) = "frue" Then 计算表达式 = "False": Exit Function
    If 表达式 = "" Then Exit Function
    表达式 = 简单计算(表达式)
    
    If IsNumeric(表达式) Then 计算表达式 = 表达式: Exit Function
    If LCase(表达式) = "true" Then 计算表达式 = "True": Exit Function
    If LCase(表达式) = "false" Then 计算表达式 = "False": Exit Function
    
    If 最最初表达式 <> 表达式 Then 计算表达式 = 表达式: Exit Function
    

    表达式 = 第一运算优先(表达式)
    最初表达式 = 表达式: 表达式 = 简单计算(表达式): If 最初表达式 <> 表达式 Then 计算表达式 = 表达式: Exit Function
    If 表达式 = "" Then Exit Function
    If IsNumeric(表达式) Then 计算表达式 = 表达式: Exit Function
    


    
    表达式 = 双目运算逻辑(表达式) '''
    If 表达式 = "True" Or 表达式 = "False" Then 计算表达式 = 表达式: Exit Function
    表达式 = 单目运算优先(表达式): If IsNumeric(表达式) Then 计算表达式 = 表达式: Exit Function
    表达式 = 双目运算优先(表达式)
    表达式 = 双目运算乘除(表达式) '''3
    表达式 = 双目运算加减(表达式) '''4
    If IsNumeric(表达式) Then 计算表达式 = 表达式: Exit Function
    表达式 = 双目运算合并(表达式) '''4
    表达式 = 双目运算判断(表达式) '''6
    If 表达式 = "True" Or 表达式 = "False" Then 计算表达式 = 表达式: Exit Function
    表达式 = 双目运算等于(表达式)
    If 表达式 = "True" Or 表达式 = "False" Then 计算表达式 = 表达式: Exit Function
    
    表达式 = 双目运算赋值(表达式) '''
    
    
    n = InStr(1, 表达式, "$")
    If n <> 0 Then
        While n <> 0
            'DoEvents
            For pos = n + 1 To Len(表达式) '后面的
                If Much("+-*/\()%&.^", Mid(表达式, pos, 1)) Then pos = pos - 1: Exit For
                If pos = Len(表达式) Then Exit For
            Next
            str = Trim(Mid(表达式, n, pos - n + 1))
            n2 = Len(str)
            str = 读变量(str)
            If str = """""" Then str = ""
            If str = "''" Then str = ""
            If Len(str) >= 1 Then
                If Left(str, 1) = """" Then str = Replace(str, """""", """")
                If Left(str, 1) = "'" Then str = Replace(str, "''", "'")
            End If
            表达式 = Left(表达式, n - 1) & str & Right(表达式, Len(表达式) - pos)
            '表达式 = Mid(表达式, 1, 1)
            p = n + Len(str)
            n = InStr(p, 表达式, "$")
        Wend
    End If
    表达式 = 简单计算(表达式)
    If 表达式 = "" Then Exit Function
    '读变量 (Code)
    If 最初表达式 = 表达式 Then
    Dim TempDimFor As Long
        For TempDimFor = 0 To 变量数 - 1
            If 变量(TempDimFor).name = 表达式 Then
                计算表达式 = 变量(TempDimFor).text
                Exit Function
            End If
        Next
    
        表达式 = 执行函数(表达式, "")
    End If
    
    'MsgbBox "计算表达式出错，无法理解！": Exit Function
    'If 最最初表达式 = 表达式 Then 表达式 = ""
    计算表达式 = 表达式
    'DoEvents
Exit Function
jsbds:
SendError "计算表达式时有误：错误号：" & Err.Number & "详情：" & Err.Description
End Function
Private Sub 重置(Optional gc As Long = 0)
Select Case gc
Case 0
    Erase 变量
    变量数 = 0
    Erase 对象
    对象数 = 0
    Erase 代码块
    代码块数 = 0
    ErrorIgnore = False
    变量NoMoney = False
    ExitFunction = False
    StopProgram = False
Case 1
    Erase 对象
    对象数 = 0
    Erase 代码块
    代码块数 = 0
Case 2
    Dim ClearDimFor As Long
    For ClearDimFor = 0 To 变量数 - 1
        If Len(变量(ClearDimFor).name) >= 2 Then
            If Left(变量(ClearDimFor).name, 2) <> "$_" Then
                变量(ClearDimFor).name = ""
                变量(ClearDimFor).text = ""
                变量数 = 变量数 - 1
            End If
        Else
            变量(ClearDimFor).name = ""
            变量(ClearDimFor).text = ""
            变量数 = 变量数 - 1
        End If
    Next
End Select
End Sub
Public Sub 结束运行()
StopProgram = True
End Sub

Private Function 转储字符串(Code As String)
    Dim posn As Long
    posn = 1
    Dim n1 As Long, n2 As Long
    Dim n3 As Long, n4 As Long
    Dim nn As Long
    Dim dimn As Long
    Dim str As String
    dimn = 变量数
    Do
        'DoEvents
        n1 = InStr(posn, Code, """")
        n2 = InStr(posn, Code, "'")
        If (n1 < n2 And n1 <> 0) Or (n1 <> 0 And n2 = 0) Then '  "在前
            'Do
            '    n3 = InStr(n1 + 1, Code, """")
            '    If Len(Code) = n3 Then Exit Do
            'Loop Until Mid(Code, n3 + 1, 1) <> """"
            nn = 1
            Do
                Do
                    n3 = InStr(n1 + nn, Code, """")
                    If Mid(Code, n3 + 1, 1) = """" Then nn = n3 + 1 - n1 + 1
                Loop Until Mid(Code, n3 + 1, 1) <> """"
                nn = n3 + 1 - n1
                
                If n3 = 0 Then SendError "未结束的""字符串": Exit Function
            Loop Until Mid(Code, n3 - 1, 1) <> "\"
            str = Mid(Code, n1, n3 - n1 + 1)
            'str = Replace(str, """""", """")
            加变量 "$_" & Format(dimn, "000000"), str, 0
            Code = Replace(Code, str, "$_" & Format(dimn, "000000"))
            dimn = dimn + 1
        ElseIf (n1 > n2 And n2 <> 0) Or (n1 = 0 And n2 <> 0) Then 'n1>n2  '   '先出
        
            nn = 1
            Do
                Do
                    n3 = InStr(n2 + nn, Code, "'")
                    If n3 = 0 Then Exit Do
                    If Mid(Code, n3 + 1, 1) = "'" Then nn = n3 + 1 - n2 + 1
                Loop Until Mid(Code, n3 + 1, 1) <> "'"
                nn = n3 + 1 - n2
                
                If n3 = 0 Then SendError "未结束的'字符串": Exit Function
            Loop Until Mid(Code, n3 - 1, 1) <> "\"
            str = Mid(Code, n2, n3 - n2 + 1)
            'str = Replace(str, """""", """")
            加变量 "$_" & Format(dimn, "000000"), str, 0
            Code = Replace(Code, str, "$_" & Format(dimn, "000000"))
            dimn = dimn + 1
            'nn = 0
            'Do
            '
            '    nn = nn + 1
            '    Do
            '        DoEvents
            '        n3 = InStr(n2 + 1, Code, "'")
            '        If Mid(Code, n3 + 1, 1) = "'" Then n2 = n3 + 1
            '    Loop Until Mid(Code, n3 + 1, 1) <> "'"
            '
            '
            '
            '    If Len(Code) = n3 Then Exit Do
            'Loop Until Mid(Code, n3 + nn, 1) <> "'"
            'If n3 - n2 + 1 < 0 Then n3 = n2 - 1
            'str = Mid(Code, n2, n3 - nn + 1)
            'nn = n3 + 1
            '加变量 "$_" & Format(dimn, "000000"), str, 1
            'Code = Replace(Code, str, "$_" & Format(dimn, "000000"))
            'dimn = dimn + 1
        ElseIf IsNumeric(Code) And Not Much(Code, "(") And Not Much(Code, ")") Then
            str = Code
            加变量 "$_" & Format(dimn, "000000"), str, 1
            Code = Replace(Code, str, "$_" & Format(dimn, "000000"))
            dimn = dimn + 1
        End If
        
        posn = n3 - Len(str) + 9
    Loop Until n1 = 0 And n2 = 0
    转储字符串 = Code ' & Mid(Code, posn, Len(Code) - posn)
End Function
