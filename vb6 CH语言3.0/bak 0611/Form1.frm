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
      Begin VB.CommandButton Command10 
         Caption         =   "基本函数"
         Height          =   375
         Left            =   4200
         TabIndex        =   16
         Top             =   1440
         Width           =   1215
      End
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


Private Sub Command10_Click()
wenben = "function(打开,$path,{" & vbCrLf & _
"if(existfile($path)," & vbCrLf & _
"readfile($path);" & vbCrLf & _
",msgbox('没有这个文件'.$path));" & vbCrLf & _
"});" & vbCrLf & _
"" & vbCrLf & _
"//定义一个自定义函数，函数名为 打开" & vbCrLf & _
"//返回值为代码块中最后的结果，即if返回的readfile的结果。" & vbCrLf & _
"" & vbCrLf & _
"/*(这是注释块)" & vbCrLf & _
"" & vbCrLf & _
"CH语言内置强大的函数" & vbCrLf & _
"拥有超强的处理能力" & vbCrLf & _
"" & vbCrLf & _
"其中D:\123.txt为你的文件路径" & vbCrLf & _
"文件处理函数：" & vbCrLf & _
"" & vbCrLf & _
"读取文件:readfile(""D:\123.txt"")//一次性读取文件内容" & vbCrLf & _
"写入文件:writefile(""D:\123.txt"",""数据"")//覆盖写入文件" & vbCrLf & _
"追加文件:appendfile(""D:\123.txt"",""数据"")//从末尾追加数据" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "" & vbCrLf & _
"msgbox 弹出提示框 如：msgbox('hello world')" & vbCrLf & _
"弹出带按钮的提示框：msgbox('hello world',1,""标题"") 返回值根据点击的按钮不同来返回" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"sleep 程序休眠多少ms 程序假死" & vbCrLf & _
"delay 程序延时多少ms 程序不假死" & vbCrLf & _
"" & vbCrLf & _
"true恒返回true" & vbCrLf & _
"false恒返回false" & vbCrLf & _
"doevents 程序响应一次，用于大循环程序不假死" & vbCrLf & _
"void 空函数" & vbCrLf & _
"val 简单计算 val(""1234abcd"") 返回 1234" & vbCrLf & _
"eval 再计算函数（在当前程序内再计算字符串程序代码）*" & vbCrLf & _
"其他函数：" & vbCrLf & _
"" & vbCrLf & _
"数学函数：" & vbCrLf & _
"inputbox 要求输入值 如：inputbox(""请输入正方形的长"")" & vbCrLf & _
"如：inputbox(""提示内容:"",""标题内容"",""默认值"",0,0)最后两个参数为显示框的坐标" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "int 取整" & vbCrLf & _
"abs 取绝对值" & vbCrLf & _
"pi 返回pi值" & vbCrLf & _
"sin 正弦" & vbCrLf & _
"cos 余弦" & vbCrLf & _
"tan 正切" & vbCrLf & _
"atn 反正切" & vbCrLf & _
"sgn" & vbCrLf & _
"exp" & vbCrLf & _
"log" & vbCrLf & _
"sqr" & vbCrLf & _
"randomize 初始化随机数种子" & vbCrLf & _
"rnd 返回 [0,1) 的随机小数" & vbCrLf & _
"round 四舍五入保留小数 round(123.5) 返回 124   round(123.555,2) 返回 123.56" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"时间函数：" & vbCrLf & _
"now() 返回当前时间 如：2018-06-10 21:11:51  返回格式由系统确定" & vbCrLf & _
"" & vbCrLf & _
"date() 返回2018-06-10" & vbCrLf & _
""
wenben = wenben & "time() 返回21:11:51" & vbCrLf & _
"" & vbCrLf & _
"year(now()) 返回年 如：2018" & vbCrLf & _
"month(now()) 返回月 如：6" & vbCrLf & _
"day(now()) 返回日 如：10" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"hour(now()) 返回时 如：21" & vbCrLf & _
"minute(now()) 返回分 如：11" & vbCrLf & _
"second(now()) 返回秒 如：51" & vbCrLf & _
"" & vbCrLf & _
"字符串处理函数" & vbCrLf & _
"" & vbCrLf & _
"format(now(),""yyyy/mm/dd hh:mm:ss"") 返回 2018/06/10 21:11:51  （格式化字符串）" & vbCrLf & _
"replace(""abcdefg"",""cd"",""efg"") 返回 abefgefg" & vbCrLf & _
"" & vbCrLf & _
"lcase(""ABC"") 返回 ""abc""(转小写)" & vbCrLf & _
"ucase(""abc"") 返回 ""ABC""(转大写)" & vbCrLf & _
"" & vbCrLf & _
"strreverse(""1234"") 返回4321(字符串反转)" & vbCrLf & _
""
wenben = wenben & "" & vbCrLf & _
"mid(""abcd1234"",3,3) 返回 ""cd1""" & vbCrLf & _
"表示从abcd1234的第三位向后取3位，若无第三个参数，则取到底" & vbCrLf & _
"len(""abcdefg"") 返回7 等同于函数 strlen" & vbCrLf & _
"" & vbCrLf & _
"left(""abcdefg"",3) 返回 ""abc""" & vbCrLf & _
"right(""abcdefg"",3) 返回 ""efg""" & vbCrLf & _
"" & vbCrLf & _
"instr(1,""abcdefg"",""d"") 返回 4 " & vbCrLf & _
"instr是一个非常好用的字符串处理函数，几乎所有的字符串分隔都用到此函数。instr函数在Oracle/PLSQL中是返回要截取的字符串在源字符串中的位置。若找不到返回0" & vbCrLf & _
"instr(5,""abcabcdabcdefg"",""d"") 返回 7" & vbCrLf & _
"instrrev instrrev(""abdba"",""b"",-1) 返回4  instrrev(""abdba"",""b"",5) 返回4" & vbCrLf & _
"可返回一个字符串在另一个字符串中首次出现的位置。搜索从字符串的末端开始，但是返回的位置是从字符串的起点开始计数的。" & vbCrLf & _
"" & vbCrLf & _
"asc  ascii函数 如 asc(""A"") 返回65  asc(""a"") 返回97" & vbCrLf & _
"chr  反解ascii 如 chr(65) 返回 ""A"" chr(97)  返回""a""" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"php 函数：" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "substr_count(""abcdefgabcd"",""a"") 返回2  从第一个字符串里找有多少个子字符串" & vbCrLf & _
"php更多函数:" & vbCrLf & _
"" & vbCrLf & _
"substr" & vbCrLf & _
"strchr" & vbCrLf & _
"strrchr" & vbCrLf & _
"strtolower与lcase等同" & vbCrLf & _
"strtoupper与ucase等同" & vbCrLf & _
"strrev与strreverse等同" & vbCrLf & _
"strpos" & vbCrLf & _
"strrpos" & vbCrLf & _
"str_repeat" & vbCrLf & _
"str_replace" & vbCrLf & _
"ucfirst" & vbCrLf & _
"floor" & vbCrLf & _
"ceil" & vbCrLf & _
"rand" & vbCrLf & _
"error_reporting" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "以上大部分函数百度有详解" & vbCrLf & _
"*/" & vbCrLf & _
"" & vbCrLf & _
"打开(""D:\vbtest.txt"");" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
""
Text1.text = wenben
End Sub

Private Sub Command2_Click()
Text1.text = "if(" & vbCrLf & "true," & vbCrLf & "msgbox(11)," & vbCrLf & "MsgBox (21)" & vbCrLf & ");" & vbCrLf & "" & vbCrLf & "if(" & vbCrLf & "false," & vbCrLf & "msgbox(12)," & vbCrLf & "MsgBox (22)" & vbCrLf & ");" & vbCrLf & ""
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
Text1.text = "$aa=((true && false)||('7'!='9' || '4'=='6'));msgbox($aa);//这里最外层需要加大括号，提升运算优先级" & vbCrLf & "iif(++$a>0,true,false)&&$b++;$b"
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
Text1.text = "" '"$a=openfile('D:\vbtest.txt');" '"def(abc,$a,$b,$c,{msgbox(123);});abc();" '"'第'.'2'.'个'" '"for($i=0,$i<5,$i++,$c=rnd();randomize();msgbox($c))" '"for($i=0    ,$i<5    ,$i++    ,randomize();msgbox(rnd()))" '"'a2/b3'" '"for($a=1,$a<100,$a++,msgbox($a))" '"$b=6;$c=iif($b>5,tc('>');,tc('<');)" '"1 + (  40 + 4 )  + 1" '"$a=3" '"$a++;$a++;++$a" '"cos(30*(pi()/180))+sqr(2)/2" '"-3+4-3+4" '"SIN(30 * (3.1415926/180))" '"year(now())" '"1+3*4+4*a(3/2)" '"1110-333+(333-(333-133))+3*4+4*(3/2)" '"333+(333+444)-(222+111)+(333-(333-133))" '"  ""hello"" + ""haha""    +  3-5 + (3+(2      *  ""4""  + 3* 3 /4*3  -7 ) )  "


End Sub

Private Sub Text1_KeyDown(KeyCode As Integer, Shift As Integer)
If KeyCode = 116 Then
Command1_Click
End If
End Sub
