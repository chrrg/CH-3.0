VERSION 5.00
Object = "{BCA00000-0F85-414C-A938-5526E9F1E56A}#4.0#0"; "CASMUI.DLL"
Begin VB.Form Form1 
   Caption         =   "CH语言编辑框"
   ClientHeight    =   7095
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   6855
   LinkTopic       =   "Form1"
   ScaleHeight     =   7095
   ScaleWidth      =   6855
   StartUpPosition =   3  '窗口缺省
   Begin VB.CheckBox Check1 
      Caption         =   "自动保存"
      Height          =   255
      Left            =   0
      TabIndex        =   3
      Top             =   360
      Value           =   1  'Checked
      Width           =   1935
   End
   Begin VB.CommandButton Command1 
      Caption         =   "保存"
      Height          =   615
      Left            =   3000
      TabIndex        =   2
      Top             =   0
      Width           =   735
   End
   Begin CodeMax4Ctl.CodeMax Text1 
      Height          =   1695
      Left            =   0
      OleObjectBlob   =   "Form1.frx":0000
      TabIndex        =   1
      Top             =   600
      Width           =   2175
   End
   Begin VB.Label Label2 
      Caption         =   "编辑框："
      Height          =   615
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   6135
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim ExeProgram

Public Function Howmuch(ByVal Text As String, ByVal zi As String)
    Howmuch = (Len(Text) - Len(Replace(Text, zi, ""))) / Len(zi)
End Function

Private Sub Command1_Click()

Dim costa, mystring
        Open ExeProgram For Input As #1
     Do While Not EOF(1)
     mystring = ""
         Line Input #1, mystring
         If mystring = "new program" Then
            Exit Do
         End If
        If costa = "" Then
         If Howmuch(mystring, "|||") <> 0 Then
            sgbjn = Split(mystring, "|||")(0)
            If sgbjn = "check1" Then
            ccsj1 = Split(mystring, "|||")(1)
            End If
            If sgbjn = "check2" Then
            ccsj2 = Split(mystring, "|||")(1)
            End If
            If sgbjn = "text2" Then
            ccsj3 = Split(mystring, "|||")(1)
            End If
            If sgbjn = "text3" Then
            ccsj4 = Split(mystring, "|||")(1)
            End If
            If sgbjn = "text4" Then
            ccsj5 = Split(mystring, "|||")(1)
            End If
         'Else
         '   MsgBox "文件不是标准工程文件"
            'Exit Sub
         End If
        End If
         If costa = 1 Then
         '      loacode = loacode & mystring & vbCrLf
         Exit Do
         End If
         'If mystring = "-" Then
         '   costa = 1
         'End If
     Loop
'If loacode <> "" Then Text1 = Left(loacode, Len(loacode) - 2)
  Close #1

Open ExeProgram For Output As #1
Print #1, "CH语言|||" & App.Major & "." & App.Minor & "." & App.Revision
Print #1, "check1|||" & ccsj1
Print #1, "check2|||" & ccsj2
Print #1, "text2|||" & ccsj3
Print #1, "text3|||" & ccsj4 'Text3.Text
Print #1, "text4|||" & ccsj5
Print #1, "-"
Print #1, Text1.Text
Close #1
End Sub

Private Sub Form_Resize()
On Error Resume Next
Text1.Move 0, Label2.Height, Me.Width, Me.Height - Label2.Height
Command1.Left = Me.Width - Command1.Width - 200
End Sub

Private Sub Text1_KeyUp(ByVal KeyCode As Long, ByVal Modifiers As CodeMax4Ctl.cmKeyMod)
If Check1.Value = 0 Then Exit Sub
Command1_Click
End Sub

Private Sub Text1_SelChange()
If Len(Text1.Text) = 0 Then nm = 0 Else nm = Howmuch(Text1.Text, vbCrLf) + 1
'qima = Left(Text1.Text, Text1.SelStart)
'nm3 = Howmuch(qima, vbCrLf)
    Dim r As New CodeMax4Ctl.Range
    Set r = Text1.GetSel(False)
If nm = 0 Then
    Label2.Caption = "编辑框：这里会显示您的光标信息！"
Else
    Label2.Caption = "编辑框：共" & nm & "行，选中：" & r.EndLineNo + 1 & "行，第" & r.EndColNo + 1 & "个字符"
End If
End Sub
Private Sub Text1_KeyDown(ByVal KeyCode As Long, ByVal Modifiers As CodeMax4Ctl.cmKeyMod)


'MsgBox KeyCode & "|" & Modifiers
'If KeyCode = 83 And Modifiers = cmKeyCtrl Then 'save
'Command8_Click
'End If
'If KeyCode = 116 And Modifiers = 0 Then 'f5
'If Command3.Enabled Then
'Command3_Click
'Else
'If Command1.Enabled Then Command1_Click
'End If
'End If
'If KeyCode = 19 And Modifiers = 0 Then 'break
'Check1.Value = 1
'End If
End Sub
Private Sub Form_Load()
If App.PrevInstance Then
End
End If
'com1d = "C:\Users\Administrator\Desktop\工程1.chpro"
If com1d <> "" Then
ExeProgram = Replace(com1d, """", "")
ElseIf Command = "" Then
    MsgBox "请不要直接启动编辑框。因为我不知道你要编辑哪个。", vbCritical Or vbOKOnly, "怪我啰" 'ExeProgram
    End
Else
ExeProgram = Replace(Command, """", "")
End If
If Dir(ExeProgram, vbNormal) = "" Then
    MsgBox "参数有误！一次只能编辑一个，文件未找到：" & ExeProgram, vbCritical Or vbOKOnly, "怪CH啰" 'ExeProgram
    End
End If

Dim costa, mystring
        Open ExeProgram For Input As #1
     Do While Not EOF(1)
     mystring = ""
         Line Input #1, mystring
         If mystring = "new program" Then
            Exit Do
         End If
         If costa = 1 Then
               loacode = loacode & mystring & vbCrLf
         End If
         If mystring = "-" Then
            costa = 1
         End If
     Loop
        If loacode <> "" Then daima = Left(loacode, Len(loacode) - 2) Else loacode = ""
        Close #1

Me.Caption = "CH语言编辑框：" & ExeProgram
Text1.Text = loacode
'Text1.ImageList = ImageList1
    Text1.SetColor cmClrLeftMargin, &H808080
    Text1.SetColor cmClrLineNumberBk, &H808080
    'Call Text1.SetDivider(2, True)
    'Call Text1.ClearUndoBuffer
    'Dim hotkeys() As Byte
    'Call g.GetHotKeys(hotkeys)
    CurrLine = -1
    Dim l As New CodeMax4Ctl.Language
    l.Name = "CH语言"
    Dim ScopeKeywords As New CodeMax4Ctl.TokenSet
    ScopeKeywords.Type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    ScopeKeywords.Name = "Scope Keywords"
    Dim ts As CodeMax4Ctl.ITokenSets
    Call ScopeKeywords.ValidScopes.Add(ScopeKeywords)
    Call ScopeKeywords.ValidScopes.Add(Nothing)
    ScopeKeywords.ForeColor = RGB(153, 0, 38) ' red
    ScopeKeywords.AutoIndent = True
    ScopeKeywords.Tokens.Add ("(")
    ScopeKeywords.Tokens2.Add (")")
    ScopeKeywords.Tokens.Add ("#")
    'ScopeKeywords.Tokens2.Add ("]")
    Call l.TokenSets.Add(ScopeKeywords)
    Dim Comments As New CodeMax4Ctl.TokenSet
    Comments.Type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    Comments.Name = "Comments"
    Call Comments.ValidScopes.Add(ScopeKeywords)
    Call Comments.ValidScopes.Add(Nothing)
    Comments.ForeColor = RGB(51, 153, 0) 'RGB(0, 255, 0) ' green
    Comments.Tokens.Add ("'")
    Call l.TokenSets.Add(Comments)
    Dim Strings As New CodeMax4Ctl.TokenSet
    Strings.Type = CodeMax4Ctl.cmTokenSetType.cmTsTypeScope
    Strings.Name = "Strings"
    Call Strings.ValidScopes.Add(ScopeKeywords)
    Call Strings.ValidScopes.Add(Nothing)
    Strings.ForeColor = RGB(0, 153, 204) ' green
    Call Strings.Tokens.Add(Chr(34))   ' double quotes (")
    Call Strings.Tokens2.Add(Chr(34))   ' double quotes (")
    Call l.TokenSets.Add(Strings)
    Dim Keywords As New CodeMax4Ctl.TokenSet
    Keywords.Name = "Keywords"
    Call Keywords.ValidScopes.Add(ScopeKeywords)
    Call Keywords.ValidScopes.Add(Nothing)
    Keywords.ForeColor = RGB(0, 0, 255)    ' blue
    Keywords.FontStyle = CodeMax4Ctl.cmFontStyle.cmFontBold
    Call Keywords.Tokens.Add("if")
    Call Keywords.Tokens.Add("else")
    Call Keywords.Tokens.Add("end")
    Call Keywords.Tokens.Add("new")
    Call Keywords.Tokens.Add("form")
    Call Keywords.Tokens.Add("commandbutton")
    Call Keywords.Tokens.Add("textbox")
    Call Keywords.Tokens.Add("label")
    Call Keywords.Tokens.Add("show")
    Call Keywords.Tokens.Add("hide")
    Call Keywords.Tokens.Add("settext")
    Call Keywords.Tokens.Add("gettext")
    Call Keywords.Tokens.Add("caption")
    Call Keywords.Tokens.Add("text")
    Call Keywords.Tokens.Add("msgbox")
    Call Keywords.Tokens.Add("print")
    Call Keywords.Tokens.Add("goto")
    Call Keywords.Tokens.Add("++")
    Call Keywords.Tokens.Add("call")
    Call Keywords.Tokens.Add("sub")
    Call Keywords.Tokens.Add("dim")
    Call Keywords.Tokens.Add("move")
    Call Keywords.Tokens.Add("enabled")
    Call Keywords.Tokens.Add("true")
    Call Keywords.Tokens.Add("false")
    Call Keywords.Tokens.Add("then")
    Call Keywords.Tokens.Add("hwnd")
    Call Keywords.Tokens.Add("api")

    Call l.TokenSets.Add(Keywords)
    Dim Text As New CodeMax4Ctl.TokenSet
    Text.Name = "Text"
    Call Text.ValidScopes.Add(ScopeKeywords)
    Call Text.ValidScopes.Add(Nothing)
    Call l.TokenSets.Add(Text)
    Call l.Register
    Text1.Language = l

End Sub
