VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "CH������ʽ"
   ClientHeight    =   7350
   ClientLeft      =   60
   ClientTop       =   405
   ClientWidth     =   14385
   LinkTopic       =   "Form1"
   ScaleHeight     =   7350
   ScaleWidth      =   14385
   StartUpPosition =   3  '����ȱʡ
   Begin VB.Frame Frame1 
      Caption         =   "����"
      Height          =   1935
      Left            =   240
      TabIndex        =   6
      Top             =   5160
      Width           =   5535
      Begin VB.CommandButton Command10 
         Caption         =   "��������"
         Height          =   375
         Left            =   4200
         TabIndex        =   16
         Top             =   1440
         Width           =   1215
      End
      Begin VB.CommandButton Command9 
         Caption         =   "����1"
         Height          =   375
         Left            =   4200
         TabIndex        =   15
         Top             =   840
         Width           =   1215
      End
      Begin VB.CommandButton Command8 
         Caption         =   "�ټ���"
         Height          =   375
         Left            =   4200
         TabIndex        =   14
         Top             =   240
         Width           =   1215
      End
      Begin VB.CommandButton Command7 
         Caption         =   "����"
         Height          =   375
         Left            =   240
         TabIndex        =   12
         Top             =   1440
         Width           =   1695
      End
      Begin VB.CommandButton Command6 
         Caption         =   "���ֵ"
         Height          =   375
         Left            =   240
         TabIndex        =   11
         Top             =   840
         Width           =   1695
      End
      Begin VB.CommandButton Command5 
         Caption         =   "whileѭ��"
         Height          =   375
         Left            =   2160
         TabIndex        =   10
         Top             =   1440
         Width           =   1815
      End
      Begin VB.CommandButton Command4 
         Caption         =   "doѭ��"
         Height          =   375
         Left            =   2160
         TabIndex        =   9
         Top             =   840
         Width           =   1815
      End
      Begin VB.CommandButton Command3 
         Caption         =   "forѭ��"
         Height          =   375
         Left            =   2160
         TabIndex        =   8
         Top             =   240
         Width           =   1815
      End
      Begin VB.CommandButton Command2 
         Caption         =   "�ж�"
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
      Caption         =   "����"
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
      Caption         =   "BUG������QQ��877562884"
      Height          =   735
      Left            =   8040
      TabIndex        =   13
      Top             =   6480
      Width           =   5415
   End
   Begin VB.Label Label3 
      Caption         =   "�����"
      Height          =   375
      Left            =   7320
      TabIndex        =   5
      Top             =   120
      Width           =   1935
   End
   Begin VB.Label Label2 
      Caption         =   "��ʽ��"
      Height          =   375
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   2895
   End
   Begin VB.Label Label1 
      Caption         =   "״̬��okΪ�ɹ���noΪʧ�ܣ�waitΪ���ڼ��㡣��"
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
Text2.text = "wait������"
ret = make.Run(Text1.text)
If ret Then Label1.Caption = "ok" Else Label1.Caption = "no"
Text2.text = make.GetCode
End Sub


Private Sub Command10_Click()
wenben = "function(��,$path,{" & vbCrLf & _
"if(existfile($path)," & vbCrLf & _
"readfile($path);" & vbCrLf & _
",msgbox('û������ļ�'.$path));" & vbCrLf & _
"});" & vbCrLf & _
"" & vbCrLf & _
"//����һ���Զ��庯����������Ϊ ��" & vbCrLf & _
"//����ֵΪ����������Ľ������if���ص�readfile�Ľ����" & vbCrLf & _
"" & vbCrLf & _
"/*(����ע�Ϳ�)" & vbCrLf & _
"" & vbCrLf & _
"CH��������ǿ��ĺ���" & vbCrLf & _
"ӵ�г�ǿ�Ĵ�������" & vbCrLf & _
"" & vbCrLf & _
"����D:\123.txtΪ����ļ�·��" & vbCrLf & _
"�ļ���������" & vbCrLf & _
"" & vbCrLf & _
"��ȡ�ļ�:readfile(""D:\123.txt"")//һ���Զ�ȡ�ļ�����" & vbCrLf & _
"д���ļ�:writefile(""D:\123.txt"",""����"")//����д���ļ�" & vbCrLf & _
"׷���ļ�:appendfile(""D:\123.txt"",""����"")//��ĩβ׷������" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "" & vbCrLf & _
"msgbox ������ʾ�� �磺msgbox('hello world')" & vbCrLf & _
"��������ť����ʾ��msgbox('hello world',1,""����"") ����ֵ���ݵ���İ�ť��ͬ������" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"sleep �������߶���ms �������" & vbCrLf & _
"delay ������ʱ����ms ���򲻼���" & vbCrLf & _
"" & vbCrLf & _
"true�㷵��true" & vbCrLf & _
"false�㷵��false" & vbCrLf & _
"doevents ������Ӧһ�Σ����ڴ�ѭ�����򲻼���" & vbCrLf & _
"void �պ���" & vbCrLf & _
"val �򵥼��� val(""1234abcd"") ���� 1234" & vbCrLf & _
"eval �ټ��㺯�����ڵ�ǰ�������ټ����ַ���������룩*" & vbCrLf & _
"����������" & vbCrLf & _
"" & vbCrLf & _
"��ѧ������" & vbCrLf & _
"inputbox Ҫ������ֵ �磺inputbox(""�����������εĳ�"")" & vbCrLf & _
"�磺inputbox(""��ʾ����:"",""��������"",""Ĭ��ֵ"",0,0)�����������Ϊ��ʾ�������" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "int ȡ��" & vbCrLf & _
"abs ȡ����ֵ" & vbCrLf & _
"pi ����piֵ" & vbCrLf & _
"sin ����" & vbCrLf & _
"cos ����" & vbCrLf & _
"tan ����" & vbCrLf & _
"atn ������" & vbCrLf & _
"sgn" & vbCrLf & _
"exp" & vbCrLf & _
"log" & vbCrLf & _
"sqr" & vbCrLf & _
"randomize ��ʼ�����������" & vbCrLf & _
"rnd ���� [0,1) �����С��" & vbCrLf & _
"round �������뱣��С�� round(123.5) ���� 124   round(123.555,2) ���� 123.56" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"ʱ�亯����" & vbCrLf & _
"now() ���ص�ǰʱ�� �磺2018-06-10 21:11:51  ���ظ�ʽ��ϵͳȷ��" & vbCrLf & _
"" & vbCrLf & _
"date() ����2018-06-10" & vbCrLf & _
""
wenben = wenben & "time() ����21:11:51" & vbCrLf & _
"" & vbCrLf & _
"year(now()) ������ �磺2018" & vbCrLf & _
"month(now()) ������ �磺6" & vbCrLf & _
"day(now()) ������ �磺10" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"hour(now()) ����ʱ �磺21" & vbCrLf & _
"minute(now()) ���ط� �磺11" & vbCrLf & _
"second(now()) ������ �磺51" & vbCrLf & _
"" & vbCrLf & _
"�ַ���������" & vbCrLf & _
"" & vbCrLf & _
"format(now(),""yyyy/mm/dd hh:mm:ss"") ���� 2018/06/10 21:11:51  ����ʽ���ַ�����" & vbCrLf & _
"replace(""abcdefg"",""cd"",""efg"") ���� abefgefg" & vbCrLf & _
"" & vbCrLf & _
"lcase(""ABC"") ���� ""abc""(תСд)" & vbCrLf & _
"ucase(""abc"") ���� ""ABC""(ת��д)" & vbCrLf & _
"" & vbCrLf & _
"strreverse(""1234"") ����4321(�ַ�����ת)" & vbCrLf & _
""
wenben = wenben & "" & vbCrLf & _
"mid(""abcd1234"",3,3) ���� ""cd1""" & vbCrLf & _
"��ʾ��abcd1234�ĵ���λ���ȡ3λ�����޵�������������ȡ����" & vbCrLf & _
"len(""abcdefg"") ����7 ��ͬ�ں��� strlen" & vbCrLf & _
"" & vbCrLf & _
"left(""abcdefg"",3) ���� ""abc""" & vbCrLf & _
"right(""abcdefg"",3) ���� ""efg""" & vbCrLf & _
"" & vbCrLf & _
"instr(1,""abcdefg"",""d"") ���� 4 " & vbCrLf & _
"instr��һ���ǳ����õ��ַ������������������е��ַ����ָ����õ��˺�����instr������Oracle/PLSQL���Ƿ���Ҫ��ȡ���ַ�����Դ�ַ����е�λ�á����Ҳ�������0" & vbCrLf & _
"instr(5,""abcabcdabcdefg"",""d"") ���� 7" & vbCrLf & _
"instrrev instrrev(""abdba"",""b"",-1) ����4  instrrev(""abdba"",""b"",5) ����4" & vbCrLf & _
"�ɷ���һ���ַ�������һ���ַ������״γ��ֵ�λ�á��������ַ�����ĩ�˿�ʼ�����Ƿ��ص�λ���Ǵ��ַ�������㿪ʼ�����ġ�" & vbCrLf & _
"" & vbCrLf & _
"asc  ascii���� �� asc(""A"") ����65  asc(""a"") ����97" & vbCrLf & _
"chr  ����ascii �� chr(65) ���� ""A"" chr(97)  ����""a""" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
"php ������" & vbCrLf & _
"" & vbCrLf & _
""
wenben = wenben & "substr_count(""abcdefgabcd"",""a"") ����2  �ӵ�һ���ַ��������ж��ٸ����ַ���" & vbCrLf & _
"php���ຯ��:" & vbCrLf & _
"" & vbCrLf & _
"substr" & vbCrLf & _
"strchr" & vbCrLf & _
"strrchr" & vbCrLf & _
"strtolower��lcase��ͬ" & vbCrLf & _
"strtoupper��ucase��ͬ" & vbCrLf & _
"strrev��strreverse��ͬ" & vbCrLf & _
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
wenben = wenben & "���ϴ󲿷ֺ����ٶ������" & vbCrLf & _
"*/" & vbCrLf & _
"" & vbCrLf & _
"��(""D:\vbtest.txt"");" & vbCrLf & _
"" & vbCrLf & _
"" & vbCrLf & _
""
Text1.text = wenben
End Sub

Private Sub Command2_Click()
Text1.text = "if(" & vbCrLf & "true," & vbCrLf & "msgbox(11)," & vbCrLf & "MsgBox (21)" & vbCrLf & ");" & vbCrLf & "" & vbCrLf & "if(" & vbCrLf & "false," & vbCrLf & "msgbox(12)," & vbCrLf & "MsgBox (22)" & vbCrLf & ");" & vbCrLf & ""
End Sub

Private Sub Command3_Click()
Text1.text = "for($i=0,$i<16,$i++," & vbCrLf & "msgbox(""֧\r\n��\r\nת\r\n��\r\n��\r\n��"");msgbox('��'.$i.'��ѭ��');$i=$i*2;" & vbCrLf & ")"
End Sub

Private Sub Command4_Click()
Text1.text = "do(" & vbCrLf & "$i++;" & vbCrLf & "msgbox('��'.$i);" & vbCrLf & ",$i>=3)"
End Sub

Private Sub Command5_Click()
Text1.text = "while($i<3," & vbCrLf & "$i++;" & vbCrLf & "msgbox('��'.$i);" & vbCrLf & ")"
End Sub

Private Sub Command6_Click()
Text1.text = "$aa=((true && false)||('7'!='9' || '4'=='6'));msgbox($aa);//�����������Ҫ�Ӵ����ţ������������ȼ�" & vbCrLf & "iif(++$a>0,true,false)&&$b++;$b"
End Sub

Private Sub Command7_Click()
Text1.text = "/*����ע��*/$a='���������ӡ���'.""CH"";//��Ҳ��ע��" & vbCrLf & "msgbox($a);" & vbCrLf & "$a = ""��php��˫�����ַ�������ת��\n\n\n��������" & vbCrLf & vbCrLf & "��Ҳ������ \t(�Ʊ��)"";" & vbCrLf & "msgbox($a);" & vbCrLf & "$b=sin(45*(pi()/180));" & vbCrLf & "msgbox($b);" & vbCrLf & "$c=sqr(2)/2;" & vbCrLf & "msgbox($c);" & vbCrLf & "MsgBox (str_replace('Ӧ�ÿ���', '���ܿ���', '�������' . replace('PHP����','PHP','VB').'��Դ��Ӧ�ÿ�������'));"
End Sub

Private Sub Command8_Click()
Text1.text = "$c=eval('$b++;++$a;');msgbox($b);$a;"
End Sub

Private Sub Command9_Click()
Text1.text = "$c=1050-((2^10)+6);$c+10;"

End Sub

Private Sub Form_Load()
make.Init
Text1.text = "" '"$a=openfile('D:\vbtest.txt');" '"def(abc,$a,$b,$c,{msgbox(123);});abc();" '"'��'.'2'.'��'" '"for($i=0,$i<5,$i++,$c=rnd();randomize();msgbox($c))" '"for($i=0    ,$i<5    ,$i++    ,randomize();msgbox(rnd()))" '"'a2/b3'" '"for($a=1,$a<100,$a++,msgbox($a))" '"$b=6;$c=iif($b>5,tc('>');,tc('<');)" '"1 + (  40 + 4 )  + 1" '"$a=3" '"$a++;$a++;++$a" '"cos(30*(pi()/180))+sqr(2)/2" '"-3+4-3+4" '"SIN(30 * (3.1415926/180))" '"year(now())" '"1+3*4+4*a(3/2)" '"1110-333+(333-(333-133))+3*4+4*(3/2)" '"333+(333+444)-(222+111)+(333-(333-133))" '"  ""hello"" + ""haha""    +  3-5 + (3+(2      *  ""4""  + 3* 3 /4*3  -7 ) )  "


End Sub

Private Sub Text1_KeyDown(KeyCode As Integer, Shift As Integer)
If KeyCode = 116 Then
Command1_Click
End If
End Sub
