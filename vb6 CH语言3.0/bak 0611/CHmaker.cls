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
Dim MakeCode As String

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
'Private Type CHxunhuanData
'    level As Long
'    LineNum As Long
'    type As Long
'    level2 As Long
'End Type
'Private Type CHpanduanData
'    level As Long
'     LineNum As Long
'    'type As Long
'    xunhuanlevel As Long
'End Type
'Private Type CHguochengData
'    name As String
'    LineNum As Long
'    Parents As String
'    canshu As String
'    type As Long
'End Type

'Private Type ChObjects
'    p As Object
'    NA As String
'    type As String
'    parent As String
'    hwnd As Long
'End Type

'Private 过程数 As Long
'Public 线程数 As Long
Private 变量数 As Long
Private 代码块数 As Long
Private Const 最大变量数 As Long = 200

Private 代码块(1000) As codeblockdata
'Private 线程(100) As CHprocessData
Private 变量(最大变量数) As CHbianliangData
'Private 循环(500) As CHxunhuanData
'Private 判断(500) As CHpanduanData
'Private 过程(500) As CHguochengData
Sub Init()

End Sub

Function GetCode()
    GetCode = MakeCode
End Function
Public Sub Delay(Msec As Long)
    Dim EndTime As Long
    EndTime = GetTickCount + Msec
    Do
        Sleep 1
        DoEvents
    Loop While GetTickCount < EndTime
End Sub
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
                If posdn2 = 0 Then MsgBox "}丢失！"
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
Function AddCodeBlock(Code As String) As String
    代码块(代码块数).Code = Code
    代码块(代码块数).names = "ch_" & Format(代码块数, "00000000")
    AddCodeBlock = "ch_" & Format(代码块数, "00000000")
    代码块数 = 代码块数 + 1
End Function
Function AddCusFunc(FuncName As String, Code As String, canshu() As String) As String
    代码块(代码块数).Code = Code
    代码块(代码块数).names = FuncName
    'MsgBox (canshu(0))
    'MsgBox UBound(canshu)
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
    Code = 转储字符串(Code)
    Code = 不区分大小写(Code)
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
        'If n = 0 Then MsgBox "注释//未关闭": Exit Function
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
        If n = 0 Then MsgBox "注释/**/未关闭": Exit Function
        Code = Mid(Code, nn, n2 - nn) & Mid(Code, n + 2)
    Wend
    
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
If Not 检测变量合法性(names) Then MsgBox "变量名不正确！": Exit Sub
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
    取变量地址 = 转字符串(names)
End Function
Private Function 判断变量类型(names As String)
    Dim bianliangn As Long
    For bianliangn = 0 To 变量数
        If 变量(bianliangn).name = names Then 判断变量类型 = 变量(bianliangn).type: Exit Function
    Next
End Function
Function 第一运算优先(表达式)
    Dim tempbiaodashi As String
    Dim pos1 As Long, pos2 As Long
    Dim c1 As String, c2 As String, c3 As String
    Dim n As Long, n1 As Long, n2 As Long, n3 As Long, posn As Long
    Dim result As String, str As String, strs As String
    Dim 符号 As String
    Dim dengyu As Boolean
    Dim noact As Boolean
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
                c2 = Trim(Mid(表达式, n + 1, pos1 - n - 1))
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
                result = 执行函数(c1, c2, c3)
            Case ";"
                result = ""
                If c1 = "" And c2 = "" Then
                Else
                    If c1 <> "die" And c1 <> "" Then
                        result = 计算表达式(c1)
                        
                    End If
                    If c2 <> "die" And c2 <> "" Then
                        
                        result = 计算表达式(c2)
                    End If
                End If
        End Select
        'result = 转添字符串(result)
        'If result = """""" Then result = ""
        'If result = "''" Then result = ""
        If result <> "" Then result = 转添字符串(result)
        If pos2 = 0 Then pos2 = 1
        'result = 转字符串(result)
        'result = ""
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
                MsgBox "错了？"
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
                result = 转字符串(计算表达式(c1) & 计算表达式(c2))
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
                        MsgBox "字符串怎么减你告诉我！"
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
            MsgBox "应该要数字！"
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
            MsgBox "应该要数字！"
            noact = True
        End If
        If Not noact Then
            Select Case 符号
            Case "*"
                result = c1 * c2
            Case "/"
                If c2 = 0 Then MsgBox "除数为0！": Exit Function
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
                c2 = 转字符串(c2)
            'End If
            Select Case 符号
            Case "="
                'MsgBox Trim(Mid(表达式, n + 1, pos1 - n))
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
Sub SendError(错误信息)
    MsgBox "报错：" & 错误信息
End Sub
Function 执行函数(函数名 As String, 参数 As String, Optional 附加代码块 As String) As String
    On Error GoTo errsh:
    If 函数名 = "" Then 执行函数 = 计算表达式(参数): Exit Function
    Dim c(100) As String
    'ReDim c(100) As String
    Dim s As String
    'c = Split(参数, ",")
    
    Dim nn As Long, n As Long, nnn As Long, num As Long
    If Much(参数, ",") Then
        nn = 1
        nnn = 1
        Do
            Do
                n = InStr(nn, 参数, ",")
                'DoEvents
                If n <> 0 Then
                    s = Mid(参数, nnn, n - nnn)
                    nn = n + 1
                Else
                    's = ""
                    s = Mid(参数, nnn)
                    'c(num) = s
                    'num = num + 1
                    's = ""
                    nn = Len(参数) + 1
                    Exit Do
                End If
            
            Loop Until Howmuch(s, "(") = Howmuch(s, ")")
            nnn = nn
            c(num) = s
            num = num + 1
            n = InStr(nn, 参数, ",")
            
        Loop Until n = 0
        s = Mid(参数, nn)
        If s = "" Then
            num = num - 1
        Else
            c(num) = s
        End If
        
        
    Else
        c(0) = 参数
    End If
    
    'MsgBox num
    Dim canshun As Long
    Dim canshu As Variant
    Dim temp As String
    Dim ret As Boolean
    For Each canshu In c
        If c(canshun) <> "" Then
            Select Case 函数名
                Case "def", "function", "ch", "if", "iif", "for", "while", "do"
                Case Else
                    c(canshun) = 计算表达式(Trim(c(canshun)))
            End Select
        End If
        canshun = canshun + 1
    Next
    
    
    Dim customblockn As Long
    For customblockn = 0 To 代码块数 - 1
        If 代码块(customblockn).names = 函数名 Then
            Dim CanShuShuZuN As Long, CanShuShuZuN1, customblockn2 As Long
            'MsgBox 代码块(customblockn).canshu(2)
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
                    Exit Function
                End If
            Next
            执行函数 = 计算表达式(代码块(customblockn).Code & "()")
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

        Case "if", "iif", "如果"
            If c(0) <> "" Then
            
                ret = 计算表达式(c(0)) = "True"
                If ret Then
                    执行函数 = 计算表达式(c(1))
                Else
                    执行函数 = 计算表达式(c(2))
                End If
            Else
                执行函数 = 计算表达式(c(2))
            End If
        Case "def", "function"
            Dim FuncCan() As String
            'ReDim FuncCan(num) As Integer
            'num=2 没有
            'FuncCan = 1
            If num > 1 Then '2
                ReDim FuncCan(num - 2) As String
                Dim FuncN As Long
                For FuncN = 0 To num - 2
                    FuncCan(FuncN) = c(FuncN + 1)
                Next
                'num=2 没有
                'FuncCan = 1
            End If
            If num >= 1 Then
                'MsgBox FuncCan(2)
                AddCusFunc c(0), c(num), FuncCan
                执行函数 = True
            Else
                执行函数 = False
            End If
            
            'FuncName
            'MsgBox c(0)
            'MsgBox c(1)
        Case "ch"
        Case "for", "循环"
            计算表达式 (c(0))
            temp = c(1)
            While 计算表达式(temp)
                计算表达式 (c(3))
                计算表达式 (c(2))
                'DoEvents
                temp = c(1)
            Wend
            执行函数 = 0
        Case "doevents"
            DoEvents
        Case "while"
            temp = c(0)
            
            While 计算表达式(temp) = "True"
                计算表达式 (c(1))
                temp = c(0)
            Wend
            执行函数 = 0
        Case "do"
            temp = c(1)
            Do
                temp = c(1)
                计算表达式 (c(0))
            Loop Until 计算表达式(temp) = True
            执行函数 = 0
        Case "msgbox", "print", "tc", "sc", "弹出消息"
            If num = 0 Then
                执行函数 = MsgBox(c(0), , "")
            ElseIf num = 1 Then
                执行函数 = MsgBox(c(0), c(1))
            ElseIf num = 2 Then
                执行函数 = MsgBox(c(0), c(1), c(2))
            End If
            
            '执行函数 = MsgBox(c(0), , "msgbox弹窗")
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
        Case "true"
            执行函数 = True
        Case "false"
            执行函数 = False
        Case "eval" '再执行字符串
            c(0) = TrimCode(c(0))
            If Right(c(0), 1) <> ";" Then c(0) = c(0) & ";"
            c(0) = c(0) & "die;"
            If Not CheckCode(c(0)) Then
                MsgBox "错误！"
                执行函数 = False
            Else
                执行函数 = 计算表达式(c(0))
            End If
        Case "void"
            执行函数 = ""
        Case "address"
            执行函数 = 取变量地址(c(0))
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
        Case "string"
            执行函数 = 转储字符串(c(0))
        Case "inputbox", "输出框", "srk" '从这里为VB内置函数
            If num = 0 Then
                执行函数 = InputBox(c(0), "", "")
            ElseIf num <= 2 Then
                执行函数 = InputBox(c(0), c(1), c(2))
            Else
                执行函数 = InputBox(c(0), c(1), c(2), c(3), c(4))
            End If
            
        Case "round"
            If num = 1 Then
                执行函数 = Round(c(0), c(1))
            Else
                执行函数 = Round(c(0))
            End If
        Case "left"
            执行函数 = Left(c(0), c(1))
        Case "right"
            执行函数 = Right(c(0), c(1))
        Case "mid"
            If num = 2 Then
                执行函数 = Mid(c(0), c(1), c(2))
            ElseIf num = 1 Then
                执行函数 = Mid(c(0), c(1))
            End If
        Case "fix"
            执行函数 = Fix(c(0))
        Case "len"
            执行函数 = Len(c(0))
        Case "lenfile", "filelen", "文件长度", "文件大小", "wjcd", "wjdx"
            执行函数 = FileLen(c(0))
        Case "abs"
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
            Randomize
        Case "rnd", "随机数"
            执行函数 = Rnd
        Case "asc"
            执行函数 = Asc(c(0))
        Case "chr"
            If IsNumeric(c(0)) Then 执行函数 = Chr(c(0))
        Case "replace", "td", "th", "替换"
            执行函数 = Replace(c(0), c(1), c(2))
        Case "strreverse", "反转", "fz"
            执行函数 = StrReverse(c(0))
        Case "ucase", "dx"
            执行函数 = UCase(c(0))
        Case "lcase", "xx"
            执行函数 = LCase(c(0))
        Case "instr"
            执行函数 = InStr(c(0), c(1), c(2))
        Case "instrrev"
            执行函数 = InStrRev(c(0), c(1), c(2))
        Case "now", "现在时间", "xianzaishijian", "xzsj"
            执行函数 = Now
        Case "date", "日期", "rq"
            执行函数 = Date
        Case "time", "时间", "sj"
            执行函数 = Time
        Case "year", "年", "n"
            执行函数 = Year(c(0))
        Case "month", "月", "y"
            执行函数 = Month(c(0))
        Case "day", "日", "r"
            执行函数 = Day(c(0))
        Case "hour", "时", "s"
            执行函数 = Hour(c(0))
        Case "minute", "分", "f"
            执行函数 = Minute(c(0))
        Case "second", "秒", "m"
            执行函数 = Second(c(0))
        Case "format"
            执行函数 = Format(c(0), c(1))
        'replace(strreverse(ucase(lcase(instr(now(year(month(day(hour(minute(second(time(
        
        '''''''
        Case "base64"
        
        Case "dir"
        
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
        Case "openfile", "readfile", "flieopen", "打开文件"
            Dim FSO As Object
            Set FSO = CreateObject("Scripting.FileSystemObject")
            执行函数 = FSO.opentextfile(c(0), 1).ReadAll
            Set FSO = Nothing
        Case "writefile"
            Dim FSOwrite As Object
            Set FSOwrite = CreateObject("Scripting.FileSystemObject")
            FSOwrite.opentextfile(c(0), 2, True).Write (c(1))
            执行函数 = True
            Set FSOwrite = Nothing
        Case "appendfile"
            Dim FSOappend As Object
            Set FSOappend = CreateObject("Scripting.FileSystemObject")
            FSOappend.opentextfile(c(0), 8, True).Write (c(1))
            执行函数 = True
            Set FSOappend = Nothing
        Case "existfile"
            If Dir(c(0), vbNormal) = "" Then 执行函数 = False Else 执行函数 = True
        Case "existdir"
            If Dir(c(0), vbDirectory) = "" Then 执行函数 = False Else 执行函数 = True
        Case "test"
            执行函数 = ""
        Case Else
            SendError "无此函数：" & 函数名
            执行函数 = ""
    End Select
'If Not IsNumeric(执行函数) Then 执行函数 = 转字符串(执行函数)
Exit Function
errsh:
MsgBox "抱歉执行函数程序出错，请反馈以下信息：" & Err.Number & "，" & Err.Description & "" & vbCrLf & "请确保您的代码正确哦！"
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
                    简单计算 = Replace(简单计算, "\\", "\")
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
    检测变量合法性 = True
End Function
Function 计算表达式(表达式 As String)
'MsgBox 表达式
    Dim str As String, str2 As String
    Dim n As Long, n2 As Long
    Dim p As Long
    Dim pos As Long, result As String
    Dim 最最初表达式 As String, 最初表达式 As String
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
    
    '读变量 (Code)
    'If 最初表达式 = 表达式 Then MsgBox "计算表达式出错，无法理解！": Exit Function
    If 最最初表达式 = 表达式 Then 表达式 = ""
    计算表达式 = 表达式
    'DoEvents
    
End Function
Private Sub 重置()
    Erase 变量
    变量数 = 0
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
                
                If n3 = 0 Then MsgBox "未结束的""字符串": Exit Function
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
                    If Mid(Code, n3 + 1, 1) = "'" Then nn = n3 + 1 - n1 + 1
                Loop Until Mid(Code, n3 + 1, 1) <> "'"
                nn = n3 + 1 - n2
                
                If n3 = 0 Then MsgBox "未结束的'字符串": Exit Function
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

