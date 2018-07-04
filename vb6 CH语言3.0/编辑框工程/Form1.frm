VERSION 5.00
Object = "{BCA00000-0F85-414C-A938-5526E9F1E56A}#4.0#0"; "CASMUI.DLL"
Begin VB.Form Form1 
   Caption         =   "CH语言3.0 编辑框"
   ClientHeight    =   7035
   ClientLeft      =   165
   ClientTop       =   810
   ClientWidth     =   10590
   LinkTopic       =   "Form1"
   ScaleHeight     =   7035
   ScaleWidth      =   10590
   StartUpPosition =   3  '窗口缺省
   Begin VB.TextBox Text2 
      Height          =   1455
      Left            =   0
      MultiLine       =   -1  'True
      OLEDropMode     =   1  'Manual
      TabIndex        =   2
      Top             =   5520
      Width           =   10575
   End
   Begin CodeMax4Ctl.CodeMax Text1 
      Height          =   1095
      Left            =   240
      OleObjectBlob   =   "Form1.frx":0000
      TabIndex        =   1
      Top             =   840
      Width           =   2175
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "编辑框："
      BeginProperty Font 
         Name            =   "宋体"
         Size            =   12
         Charset         =   134
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   240
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   960
   End
   Begin VB.Menu menu_file 
      Caption         =   "文件"
      Begin VB.Menu menu_file_open 
         Caption         =   "打开"
      End
      Begin VB.Menu menu_file_save 
         Caption         =   "保存"
      End
      Begin VB.Menu menu_file_savenew 
         Caption         =   "另存为"
      End
      Begin VB.Menu menu_file_new 
         Caption         =   "新建"
      End
      Begin VB.Menu menu_file_close 
         Caption         =   "关闭文件"
      End
   End
   Begin VB.Menu menu_run 
      Caption         =   "运行"
      Begin VB.Menu menu_run_f5 
         Caption         =   "运行"
         Shortcut        =   {F5}
      End
      Begin VB.Menu menu_run_end 
         Caption         =   "结束运行"
         Shortcut        =   %{BKSP}
      End
      Begin VB.Menu menu_run_output 
         Caption         =   "保存并输出"
      End
      Begin VB.Menu menu_run_fastout 
         Caption         =   "快速输出"
         Enabled         =   0   'False
         Shortcut        =   ^{F5}
      End
   End
   Begin VB.Menu about 
      Caption         =   "CH语言"
      Begin VB.Menu about_about 
         Caption         =   "关于"
      End
      Begin VB.Menu about_1 
         Caption         =   "-"
      End
      Begin VB.Menu about_close 
         Caption         =   "关闭软件"
      End
   End
   Begin VB.Menu RunningBar 
      Caption         =   "运行中。。。"
      Enabled         =   0   'False
      Visible         =   0   'False
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim FSO As Object

Dim ExeProgram
Dim FilePath As String
Dim CaptionHeight
Dim changed As Boolean
Dim saveFilePath As String

Private WithEvents make As CHmaker
Attribute make.VB_VarHelpID = -1

Public Function Howmuch(ByVal text As String, ByVal zi As String)
    Howmuch = (Len(text) - Len(Replace(text, zi, ""))) / Len(zi)
End Function

Private Sub about_about_Click()
    MsgBox "CH语言 V_3.0" & vbCrLf & "欢迎使用！并提出建议！当前编辑器运行版本:" & make.getVersion, 0, "CH语言"
End Sub

Private Sub about_close_Click()
    If changed Then
        Dim msg
        msg = MsgBox("是否确定放弃您刚才的修改，退出程序？", vbOKCancel)
        If msg = vbCancel Then Exit Sub
    End If
    End
End Sub


Private Sub Form_Resize()
    On Error Resume Next
    Text2.Move 0, Me.Height - Text2.Height - CaptionHeight - 100, Me.Width, Text2.Height
    Text1.Move 0, Label2.Height, Me.Width - 100, Me.Height - Label2.Height - Text2.Height - CaptionHeight - 100
    Command1.Left = Me.Width - Command1.Width - 200
End Sub

Private Sub Form_Unload(Cancel As Integer)
    If changed Then
        Dim msg
        msg = MsgBox("是否确定放弃您刚才的修改，退出程序？", vbOKCancel)
        If msg = vbCancel Then Cancel = -1: Exit Sub
    End If
    End
End Sub

Private Sub menu_file_close_Click()
If changed Then
    Dim msg
    msg = MsgBox("是否保存当前代码？", vbYesNoCancel, "CH语言3.0")
    If msg = vbCancel Then Exit Sub
    If msg = vbOK Then menu_file_save_Click
End If
menu_run_fastout.Enabled = False
FilePath = ""
Text1.text = ""
changed = False
Me.Caption = "CH语言3.0 编辑框：" & FilePath
End Sub

Private Sub menu_file_new_Click()
If Text1.text <> "" And changed Then
Dim msg
msg = MsgBox("真的要放弃你做的修改吗？", vbOKCancel, "CH语言3.0")
If msg = vbCancel Then Exit Sub
End If
menu_run_fastout.Enabled = False
FilePath = ""
Text1.text = ""
changed = False
Me.Caption = "CH语言3.0 编辑框：" & FilePath
End Sub

Private Sub menu_file_open_Click()
If Text1.text <> "" And changed Then
    Dim msg
    msg = MsgBox("真的要放弃你做的修改吗？", vbOKCancel, "CH语言3.0")
    If msg = vbCancel Then Exit Sub
End If
Dim res As String
res = GetDialog("open", "打开ch3代码文件", "")
If res <> "" Then
    FilePath = res
    Text1.text = ""
    Dim openfileobj As Object
    'Set FSO = Nothing
    'Set FSO = CreateObject("Scripting.FileSystemObject")
    If FileLen(res) <> 0 Then
        Set openfileobj = FSO.opentextfile(res, 1)
        make.CHDebugPath = res
        Text1.text = openfileobj.ReadAll
        openfileobj.Close
        Set openfileobj = Nothing
    End If
    changed = False
    Me.Caption = "CH语言3.0 编辑框：" & FilePath
End If
End Sub

Private Sub menu_file_save_Click()
On Error GoTo errs:

    If FilePath = "" Then
        FilePath = GetDialog("save", "保存代码文件", "")
        If FilePath = "" Then Exit Sub
    End If
    Me.Caption = "CH语言3.0 编辑框：" & FilePath
    Dim FsoFile As Object
    'MsgBox FSO Is Nothing
    Set FSO = CreateObject("Scripting.FileSystemObject")
    Set FsoFile = FSO.opentextfile(FilePath, 2, True)
    FsoFile.Write (Text1.text)
    FsoFile.Close
    Set FsoFile = Nothing
    changed = False
Exit Sub
errs:
MsgBox "保存失败！请重新保存！" & FilePath & vbCrLf & "原因：" & Err.Number & "," & Err.Description
End Sub

Private Sub menu_file_savenew_Click()
    Dim tempFilePath As String
    Me.Caption = "CH语言3.0 编辑框："
    tempFilePath = GetDialog("save", "保存代码文件", "")
    If tempFilePath = "" Then Me.Caption = "CH语言3.0 编辑框：" & FilePath: Exit Sub
    FilePath = tempFilePath
    Me.Caption = "CH语言3.0 编辑框：" & FilePath
    Dim FsoFile As Object
    'MsgBox FSO Is Nothing
    Set FSO = CreateObject("Scripting.FileSystemObject")
    Set FsoFile = FSO.opentextfile(FilePath, 2, True)
    FsoFile.Write (Text1.text)
    FsoFile.Close
    Set FsoFile = Nothing
    changed = False

End Sub

Private Sub menu_run_end_Click()
    make.结束运行
End Sub

Private Sub menu_run_f5_Click()
    menu_run_f5.Enabled = False
    RunningBar.Visible = True
    DoEvents
    Dim ret As Boolean
    ret = make.Run(Text1.text)
    If ret Then
        
        Text2.text = Text2.text & make.GetCode & vbCrLf
        Text2.SelStart = Len(Text2.text)
        menu_run_f5.Enabled = True
        RunningBar.Visible = False
    End If
End Sub

Private Sub menu_run_output_Click()
    If Dir(App.Path & "\link.exe") = "" Then MsgBox "丢失组件:link.exe": Exit Sub
    
    menu_file_save_Click
    
    If FilePath <> "" Then
        saveFilePath = GetDialog("save", "保存可执行文件", "", "exe")
        If saveFilePath = "" Then menu_run_fastout.Enabled = False: Exit Sub
        menu_run_fastout.Enabled = True
        shelloutput
    End If
End Sub
Sub shelloutput()
    Text2.text = Text2.text & "输出开始时间：" & Now & "---" & vbCrLf
    Text2.SelStart = Len(Text2.text)
    make.输出exe Text1.text, saveFilePath
    'Shell App.Path & "\link.exe makeall""" & make.getVersion & """|""" & FilePath & """|""" & saveFilePath & """"
End Sub
Private Sub menu_run_fastout_Click()
    If Dir(App.Path & "\link.exe") = "" Then MsgBox "丢失组件:link.exe": Exit Sub
    menu_file_save_Click
    If FilePath <> "" Then
        shelloutput
    End If
End Sub

Private Sub Text1_KeyDown(ByVal KeyCode As Long, ByVal Modifiers As CodeMax4Ctl.cmKeyMod)
changed = True
Me.Caption = "CH语言3.0 编辑框：" & FilePath & " *"
End Sub

Private Sub Text1_KeyPress(ByVal KeyAscii As Long, ByVal Modifiers As CodeMax4Ctl.cmKeyMod)
    If KeyAscii = 19 And Modifiers = 2 Then
        
        menu_file_save_Click
        
    End If
End Sub

Private Sub Text1_SelChange()
If Len(Text1.text) = 0 Then nm = 0 Else nm = Howmuch(Text1.text, vbCrLf) + 1
    Dim r As New CodeMax4Ctl.Range
    Set r = Text1.GetSel(False)
If nm = 0 Then
    Label2.Caption = "编辑框：这里会显示您的光标信息！"
Else
    Label2.Caption = "编辑框：共" & nm & "行，选中：" & r.EndLineNo + 1 & "行，第" & r.EndColNo & "个字符"
End If
End Sub
Private Sub make_GetERRORLog(inf As String)
    Text2.text = vbCrLf & Text2.text & "错误：" & Now & " " & inf & vbCrLf
    Text2.SelStart = Len(Text2.text)
End Sub
Private Sub make_GetLog(inf As String)
    Text2.text = Text2.text & inf
    Text2.SelStart = Len(Text2.text)
End Sub
Private Sub make_DebugEvent(inf As String)
    Text2.text = ""
End Sub

Private Sub Form_Load()
    Set make = New CHmaker
    make.CHDebug = True
    
    Set FSO = CreateObject("Scripting.FileSystemObject")
    CaptionHeight = (Me.Height - Me.ScaleHeight - (Me.Width - Me.ScaleWidth)) / Screen.TwipsPerPixelX * 15
    commtext = Command
    If commtext <> "" Then
        If Left(commtext, 1) = """" And Right(commtext, 1) = """" Then
            commtext = Mid(commtext, 2)
            commtext = Left(commtext, Len(commtext) - 1)
            
        End If
        If Dir(commtext, vbNormal) = "" Then
            MsgBox "没有找到此文件：" & commtext
        Else
            Dim fsotempobj As Object
            Set fsotempobj = FSO.opentextfile(commtext, 1)
            make.CHDebugPath = commtext
            Text1.text = fsotempobj.ReadAll
            fsotempobj.Close
            Set fsotempobj = Nothing
            FilePath = commtext
        End If
    End If
    Dim costa, mystring
    Me.Caption = "CH语言3.0 编辑框：" & commtext

    Text1.SetColor cmClrLeftMargin, &H808080
    Text1.SetColor cmClrLineNumberBk, &H808080

    CurrLine = -1
    Dim l As New CodeMax4Ctl.Language
    l.name = "CH语言3.0"
    Dim ScopeKeywords As New CodeMax4Ctl.TokenSet
    'ScopeKeywords.type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    'ScopeKeywords.name = "括号"
    'Dim ts As CodeMax4Ctl.ITokenSets
    'Call ScopeKeywords.ValidScopes.Add(ScopeKeywords)
    'Call ScopeKeywords.ValidScopes.Add(Nothing)
    'ScopeKeywords.ForeColor = RGB(0, 0, 0) 'RGB(183, 0, 68) ' red
    'ScopeKeywords.AutoIndent = True
    'ScopeKeywords.Tokens.Add ("(")
    'scopeKeywords.Tokens2.Add (")")

    'Call l.TokenSets.Add(ScopeKeywords)
    Dim Comments As New CodeMax4Ctl.TokenSet
    Comments.type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    Comments.name = "注释1"
    Call Comments.ValidScopes.Add(ScopeKeywords)
    'all Comments.ValidScopes.Add(Nothing)
    Comments.ForeColor = RGB(151, 150, 200) 'RGB(51, 131, 0) ' green
    Comments.Tokens.Add ("//")
    Call l.TokenSets.Add(Comments)
    
    Dim Strings2 As New CodeMax4Ctl.TokenSet
    Strings2.type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    Strings2.name = "注释2"
    Call Strings2.ValidScopes.Add(ScopeKeywords)
    Call Strings2.ValidScopes.Add(Nothing)
    Strings2.ForeColor = RGB(151, 150, 200)
    Call Strings2.Tokens.Add("/*")
    Call Strings2.Tokens2.Add("*/")
    Call l.TokenSets.Add(Strings2)
    
    Dim Strings As New CodeMax4Ctl.TokenSet
    Strings.type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    Strings.name = "字符串"
    Call Strings.ValidScopes.Add(ScopeKeywords)
    Call Strings.ValidScopes.Add(Nothing)
    
    Strings.ForeColor = RGB(0, 153, 204) ' green
    Call Strings.Tokens.Add("""")
    Call Strings.Tokens2.Add("""")
    Call Strings.Tokens.Add("'")
    Call Strings.Tokens2.Add("'")
    Call l.TokenSets.Add(Strings)
    
    
    Dim Keywords0 As New CodeMax4Ctl.TokenSet
    Keywords0.name = "函数"
    Call Keywords0.ValidScopes.Add(ScopeKeywords)
    Call Keywords0.ValidScopes.Add(Nothing)
    Keywords0.ForeColor = RGB(0, 100, 255)    ' blue
    Call Keywords0.Tokens.Add("if")
    Call Keywords0.Tokens.Add("iif")
    Call Keywords0.Tokens.Add("while")
    Call Keywords0.Tokens.Add("do")
    Call Keywords0.Tokens.Add("for")
    Call Keywords0.Tokens.Add("function")
    Call Keywords0.Tokens.Add("def")
    Call Keywords0.Tokens.Add("switch")
    Call Keywords0.Tokens.Add("case")
    Call Keywords0.Tokens.Add("choose")
    Call Keywords0.Tokens.Add("i")
    Call Keywords0.Tokens.Add("f")
    Call Keywords0.Tokens.Add("w")
    Call Keywords0.Tokens.Add("d")
    Call Keywords0.Tokens.Add("func")
    Call Keywords0.Tokens.Add("ch")
    Call Keywords0.Tokens.Add("void")
    Call Keywords0.Tokens.Add("print")
    Call Keywords0.Tokens.Add("printl")
    Call Keywords0.Tokens.Add("lprint")
    Call Keywords0.Tokens.Add("line")
    Call Keywords0.Tokens.Add("re")
    Call Keywords0.Tokens.Add("compile")
    Call Keywords0.Tokens.Add("try")
    Call Keywords0.Tokens.Add("error")
    Call Keywords0.Tokens.Add("errnum")
    Call Keywords0.Tokens.Add("errdes")
    Call Keywords0.Tokens.Add("deflim")
    Call Keywords0.Tokens.Add("exit")
    Call Keywords0.Tokens.Add("end")
    Call Keywords0.Tokens.Add("gc")
    Call Keywords0.Tokens.Add("xyz")
    
    Call l.TokenSets.Add(Keywords0)
    
    
    Dim Keywords As New CodeMax4Ctl.TokenSet
    Keywords.name = "函数"
    Call Keywords.ValidScopes.Add(ScopeKeywords)
    Call Keywords.ValidScopes.Add(Nothing)
    Keywords.ForeColor = RGB(0, 0, 255)    ' blue
    'Keywords.FontStyle = CodeMax4Ctl.cmFontStyle.cmFontBold
    Call Keywords.Tokens.Add("msgbox")
    Call Keywords.Tokens.Add("api")
    Call Keywords.Tokens.Add("creapi")
    Call Keywords.Tokens.Add("defapi")
    Call Keywords.Tokens.Add("callapi")
    Call Keywords.Tokens.Add("getapi")
    Call Keywords.Tokens.Add("freeapi")
    Call Keywords.Tokens.Add("command")
    Call Keywords.Tokens.Add("address")
    Call Keywords.Tokens.Add("howmuch")
    Call Keywords.Tokens.Add("much")
    Call Keywords.Tokens.Add("jiafa")
    Call Keywords.Tokens.Add("jianfa")
    Call Keywords.Tokens.Add("chengfa")
    Call Keywords.Tokens.Add("chufa")
    Call Keywords.Tokens.Add("quyu")
    Call Keywords.Tokens.Add("yu")
    Call Keywords.Tokens.Add("qy")
    Call Keywords.Tokens.Add("cr")
    Call Keywords.Tokens.Add("lf")
    Call Keywords.Tokens.Add("crlf")
    Call Keywords.Tokens.Add("split")
    Call Keywords.Tokens.Add("not")
    Call Keywords.Tokens.Add("now")
    Call Keywords.Tokens.Add("time")
    Call Keywords.Tokens.Add("date")
    Call Keywords.Tokens.Add("ucase")
    Call Keywords.Tokens.Add("lcase")
    Call Keywords.Tokens.Add("read")
    Call Keywords.Tokens.Add("write")
    Call Keywords.Tokens.Add("append")
    Call Keywords.Tokens.Add("writefile")
    Call Keywords.Tokens.Add("readfile")
    Call Keywords.Tokens.Add("msg")
    Call Keywords.Tokens.Add("appendfile")
    Call Keywords.Tokens.Add("existfile")
    Call Keywords.Tokens.Add("existdir")
    Call Keywords.Tokens.Add("format")
    Call Keywords.Tokens.Add("int")
    Call Keywords.Tokens.Add("dir")
    Call Keywords.Tokens.Add("round")
    Call Keywords.Tokens.Add("rnd")
    Call Keywords.Tokens.Add("rand")
    Call Keywords.Tokens.Add("tc")
    Call Keywords.Tokens.Add("sleep")
    Call Keywords.Tokens.Add("delay")
    Call Keywords.Tokens.Add("true")
    Call Keywords.Tokens.Add("false")
    Call Keywords.Tokens.Add("doevents")
    Call Keywords.Tokens.Add("void")
    Call Keywords.Tokens.Add("val")
    Call Keywords.Tokens.Add("string")
    Call Keywords.Tokens.Add("eval")
    Call Keywords.Tokens.Add("inputbox")
    Call Keywords.Tokens.Add("abs")
    Call Keywords.Tokens.Add("pi")
    Call Keywords.Tokens.Add("sin")
    Call Keywords.Tokens.Add("cos")
    Call Keywords.Tokens.Add("tan")
    Call Keywords.Tokens.Add("atn")
    Call Keywords.Tokens.Add("sgn")
    Call Keywords.Tokens.Add("exp")
    Call Keywords.Tokens.Add("log")
    Call Keywords.Tokens.Add("sqr")
    Call Keywords.Tokens.Add("randomize")
    Call Keywords.Tokens.Add("year")
    Call Keywords.Tokens.Add("month")
    Call Keywords.Tokens.Add("day")
    Call Keywords.Tokens.Add("hour")
    Call Keywords.Tokens.Add("minute")
    Call Keywords.Tokens.Add("second")
    Call Keywords.Tokens.Add("replace")
    Call Keywords.Tokens.Add("strreverse")
    Call Keywords.Tokens.Add("mid")
    Call Keywords.Tokens.Add("len")
    Call Keywords.Tokens.Add("lenfile")
    Call Keywords.Tokens.Add("fix")
    Call Keywords.Tokens.Add("left")
    Call Keywords.Tokens.Add("right")
    Call Keywords.Tokens.Add("instr")
    Call Keywords.Tokens.Add("instrrev")
    Call Keywords.Tokens.Add("asc")
    Call Keywords.Tokens.Add("chr")
    Call Keywords.Tokens.Add("substr_count")
    Call Keywords.Tokens.Add("substr")
    Call Keywords.Tokens.Add("strchr")
    Call Keywords.Tokens.Add("strrchr")
    Call Keywords.Tokens.Add("strtolower")
    Call Keywords.Tokens.Add("strtoupper")
    Call Keywords.Tokens.Add("strrev")
    Call Keywords.Tokens.Add("strpos")
    Call Keywords.Tokens.Add("strrpos")
    Call Keywords.Tokens.Add("str_repeat")
    Call Keywords.Tokens.Add("str_replace")
    Call Keywords.Tokens.Add("ucfirst")
    Call Keywords.Tokens.Add("floor")
    Call Keywords.Tokens.Add("ceil")
    Call Keywords.Tokens.Add("error_reporting")
    Call Keywords.Tokens.Add("get")
    Call Keywords.Tokens.Add("getx")
    Call Keywords.Tokens.Add("post")
    Call Keywords.Tokens.Add("postx")
    Call Keywords.Tokens.Add("screenwidth")
    Call Keywords.Tokens.Add("sw")
    Call Keywords.Tokens.Add("screenheight")
    Call Keywords.Tokens.Add("sh")
    Call Keywords.Tokens.Add("shell")
    Call Keywords.Tokens.Add("apppath")
    Call Keywords.Tokens.Add("openfile")
    Call Keywords.Tokens.Add("rf")
    Call Keywords.Tokens.Add("wf")
    Call Keywords.Tokens.Add("af")
    Call Keywords.Tokens.Add("gettickcount")
    Call Keywords.Tokens.Add("space")
    Call Keywords.Tokens.Add("vb")
    Call Keywords.Tokens.Add("js")
    Call Keywords.Tokens.Add("cls")
    Call Keywords.Tokens.Add("timer")

    Call l.TokenSets.Add(Keywords)
    
    Dim Keywords2 As New CodeMax4Ctl.TokenSet
    Keywords2.name = "符号"
    Call Keywords2.ValidScopes.Add(ScopeKeywords)
    Call Keywords2.ValidScopes.Add(Nothing)
    Keywords2.ForeColor = RGB(255, 25, 225)

    Call Keywords2.Tokens.Add("|")
    Call Keywords2.Tokens.Add("'")
    Call Keywords2.Tokens.Add(";")
    Call Keywords2.Tokens.Add("$")
    Call Keywords2.Tokens.Add("+")
    Call Keywords2.Tokens.Add("-")
    Call Keywords2.Tokens.Add("<")
    Call Keywords2.Tokens.Add(">")
    Call Keywords2.Tokens.Add("%")
    Call Keywords2.Tokens.Add("*")
    Call Keywords2.Tokens.Add("/")
    Call Keywords2.Tokens.Add("\")
    Call Keywords2.Tokens.Add("=")
    Call Keywords2.Tokens.Add("{")
    Call Keywords2.Tokens.Add("}")
    Call Keywords2.Tokens.Add(".")
    Call Keywords2.Tokens.Add("!")
    Call Keywords2.Tokens.Add("^")
    Call l.TokenSets.Add(Keywords2)
    
    
    
    Dim Keywords3 As New CodeMax4Ctl.TokenSet
    Keywords3.name = "逗号"
    Call Keywords3.ValidScopes.Add(ScopeKeywords)
    Call Keywords3.ValidScopes.Add(Nothing)
    Keywords3.ForeColor = RGB(15, 105, 25)
    Keywords3.FontStyle = CodeMax4Ctl.cmFontStyle.cmFontBold
    Call Keywords3.Tokens.Add(",")
    Call Keywords3.Tokens.Add("(")
    Call Keywords3.Tokens.Add(")")

    Call l.TokenSets.Add(Keywords3)
    
    'Dim Text As New CodeMax4Ctl.TokenSet
    'Text.Name = "Text"
    'Call Text.ValidScopes.Add(ScopeKeywords)
    'Call Text.ValidScopes.Add(Nothing)
    'Call l.TokenSets.Add(Text)
    Call l.Register
    Text1.Language = l
    

End Sub



