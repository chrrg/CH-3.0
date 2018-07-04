VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "CH计算表达式"
   ClientHeight    =   7350
   ClientLeft      =   60
   ClientTop       =   405
   ClientWidth     =   14385
   LinkTopic       =   "Form1"
   ScaleHeight     =   7350
   ScaleWidth      =   14385
   StartUpPosition =   3  '窗口缺省
   Begin VB.Frame Frame1 
      Caption         =   "例子"
      Height          =   1935
      Left            =   240
      TabIndex        =   6
      Top             =   5160
      Width           =   5535
      Begin VB.CommandButton Command9 
         Caption         =   "基础1"
         Height          =   375
         Left            =   4200
         TabIndex        =   15
         Top             =   840
         Width           =   1215
      End
      Begin VB.CommandButton Command8 
         Caption         =   "再计算"
         Height          =   375
         Left            =   4200
         TabIndex        =   14
         Top             =   240
         Width           =   1215
      End
      Begin VB.CommandButton Command7 
         Caption         =   "其它"
         Height          =   375
         Left            =   240
         TabIndex        =   12
         Top             =   1440
         Width           =   1695
      End
      Begin VB.CommandButton Command6 
         Caption         =   "真假值"
         Height          =   375
         Left            =   240
         TabIndex        =   11
         Top             =   840
         Width           =   1695
      End
      Begin VB.CommandButton Command5 
         Caption         =   "while循环"
         Height          =   375
         Left            =   2160
         TabIndex        =   10
         Top             =   1440
         Width           =   1815
      End
      Begin VB.CommandButton Command4 
         Caption         =   "do循环"
         Height          =   375
         Left            =   2160
         TabIndex        =   9
         Top             =   840
         Width           =   1815
      End
      Begin VB.CommandButton Command3 
         Caption         =   "for循环"
         Height          =   375
         Left            =   2160
         TabIndex        =   8
         Top             =   240
         Width           =   1815
      End
      Begin VB.CommandButton Command2 
         Caption         =   "判断"
         Height          =   375
         Left            =   240
         TabIndex        =   7
         Top             =   240
         Width           =   1695
      End
   End
   Begin VB.TextBox Text2 
      Height          =   4215
      Left            =   7320
      MultiLine       =   -1  'True
      TabIndex        =   3
      Top             =   480
      Width           =   7095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "计算"
      Height          =   615
      Left            =   6000
      TabIndex        =   1
      Top             =   5760
      Width           =   4815
   End
   Begin VB.TextBox Text1 
      Height          =   4335
      Left            =   240
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   480
      Width           =   6975
   End
   Begin VB.Label Label4 
      Caption         =   "BUG反馈：QQ：877562884"
      Height          =   735
      Left            =   8040
      TabIndex        =   13
      Top             =   6480
      Width           =   5415
   End
   Begin VB.Label Label3 
      Caption         =   "结果："
      Height          =   375
      Left            =   7320
      TabIndex        =   5
      Top             =   120
      Width           =   1935
   End
   Begin VB.Label Label2 
      Caption         =   "公式："
      Height          =   375
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   2895
   End
   Begin VB.Label Label1 
      Caption         =   "状态：ok为成功，no为失败，wait为正在计算。。"
      Height          =   495
      Left            =   6240
      TabIndex        =   2
      Top             =   5040
      Width           =   7095
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim make As New CHmaker
Private Sub Command1_Click()
Dim ret
Text2.text = "wait。。。"
ret = make.Run(Text1.text)
If ret Then Label1.Caption = "ok" Else Label1.Caption = "no"
Text2.text = make.GetCode
End Sub


Private Sub Command2_Click()
Text1.text = "if(" & vbCrLf & "true," & vbCrLf & "msgbox(1)," & vbCrLf & "MsgBox (2)" & vbCrLf & ");" & vbCrLf & "" & vbCrLf & "if(" & vbCrLf & "false," & vbCrLf & "msgbox(1)," & vbCrLf & "MsgBox (2)" & vbCrLf & ");" & vbCrLf & ""
End Sub

Private Sub Command3_Click()
Text1.text = "for($i=0,$i<16,$i++," & vbCrLf & "msgbox(""支\r\n持\r\n转\r\n义\r\n换\r\n行"");msgbox('第'.$i.'次循环');$i=$i*2;" & vbCrLf & ")"
End Sub

Private Sub Command4_Click()
Text1.text = "do(" & vbCrLf & "$i++;" & vbCrLf & "msgbox('第'.$i);" & vbCrLf & ",$i>=3)"
End Sub

Private Sub Command5_Click()
Text1.text = "while($i<3," & vbCrLf & "$i++;" & vbCrLf & "msgbox('第'.$i);" & vbCrLf & ")"
End Sub

Private Sub Command6_Click()
Text1.text = "$aa= (true && false)||('7'!='9' || '4'=='6');msgbox($aa);" & vbCrLf & "iif(++$a>0,true,false)&&$b++;$b"
End Sub

Private Sub Command7_Click()
Text1.text = "/*这是注释*/$a='这里是例子——'.""CH"";//这也是注释" & vbCrLf & "msgbox($a);" & vbCrLf & "$a = ""仿php的双引号字符串可以转义\n\n\n看换行了" & vbCrLf & vbCrLf & "这也换行了 \t(制表符)"";" & vbCrLf & "msgbox($a);" & vbCrLf & "$b=sin(45*(pi()/180));" & vbCrLf & "msgbox($b);" & vbCrLf & "$c=sqr(2)/2;" & vbCrLf & "msgbox($c);" & vbCrLf & "MsgBox (str_replace('应该看不', '可能看得', '内置许多' . replace('PHP函数','PHP','VB').'，源码应该看不懂。'));"
End Sub

Private Sub Command8_Click()
Text1.text = "$c=eval('$b++;++$a;');msgbox($b);$a;"
End Sub

Private Sub Command9_Click()
Text1.text = "$c=1050-((2^10)+6);$c+10;"

End Sub

Private Sub Form_Load()

make.Init
Text1.text = "if (1==1){msgbox(""123a"");}elseif (1==1){msgbox(456);}else{msgbox(789)}" '"'第'.'2'.'个'" '"for($i=0,$i<5,$i++,$c=rnd();randomize();msgbox($c))" '"for($i=0    ,$i<5    ,$i++    ,randomize();msgbox(rnd()))" '"'a2/b3'" '"for($a=1,$a<100,$a++,msgbox($a))" '"$b=6;$c=iif($b>5,tc('>');,tc('<');)" '"1 + (  40 + 4 )  + 1" '"$a=3" '"$a++;$a++;++$a" '"cos(30*(pi()/180))+sqr(2)/2" '"-3+4-3+4" '"SIN(30 * (3.1415926/180))" '"year(now())" '"1+3*4+4*a(3/2)" '"1110-333+(333-(333-133))+3*4+4*(3/2)" '"333+(333+444)-(222+111)+(333-(333-133))" '"  ""hello"" + ""haha""    +  3-5 + (3+(2      *  ""4""  + 3* 3 /4*3  -7 ) )  "


End Sub

