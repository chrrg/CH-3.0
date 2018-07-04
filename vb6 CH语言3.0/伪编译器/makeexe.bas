Attribute VB_Name = "makeexe"
Option Explicit
Private Declare Function BeginUpdateResource Lib "kernel32" Alias "BeginUpdateResourceA" (ByVal pFileName As String, ByVal bDeleteExistingResources As Long) As Long
Private Declare Function UpdateResource Lib "kernel32" Alias "UpdateResourceA" (ByVal hUpdate As Long, ByVal lpType As String, ByVal lpName As String, ByVal wLanguage As Long, lpData As Any, ByVal cbData As Long) As Long
Private Declare Function EndUpdateResource Lib "kernel32" Alias "EndUpdateResourceA" (ByVal hUpdate As Long, ByVal fDiscard As Long) As Long
Private Sub makeall(ComText As String)
On Error GoTo errs:
'MsgBox ComText
    Dim FSO As Object
    Set FSO = CreateObject("Scripting.FileSystemObject")
    FSO.opentextfile(App.Path & "\link.log", 8, True).Write (vbCrLf & Now & "����" & vbCrLf)
    Dim makechcode As String, codemakedata, objpath As String, targetpath As String, version As String
    makechcode = Trim(Mid(ComText, 8))
    codemakedata = Split(makechcode, "|")
    version = codemakedata(0)
    objpath = codemakedata(1)
    targetpath = codemakedata(2)
    If Left(version, 1) = """" Then
        version = Mid(version, 2)
        version = Left(version, Len(version) - 1)
    End If
    Dim make As New CHmaker
    If version <> make.getVersion Then
        FSO.opentextfile(App.Path & "\link.log", 8, True).Write (Now & "�汾��һ�£�ִ�а汾��" & version & "��ǰlink�ļ��汾��" & make.getVersion & "��������������У�" & objpath & String(10, "-") & vbCrLf)
        End
    End If
    If Left(objpath, 1) = """" Then
        objpath = Mid(objpath, 2)
        objpath = Left(objpath, Len(objpath) - 1)
    End If
    If Left(targetpath, 1) = """" Then
        targetpath = Mid(targetpath, 2)
        targetpath = Left(targetpath, Len(targetpath) - 1)
    End If
    
    If Dir(objpath, vbNormal) = "" Then
        FSO.opentextfile(App.Path & "\link.log", 8, True).Write (Now & "����ֹͣ���޷��ҵ���" & objpath & String(10, "-") & vbCrLf)
        End
    End If
    FSO.opentextfile(App.Path & "\link.log", 8, True).Write (String(30, "-") & vbCrLf & Now & "��ʼ" & String(10, "-") & vbCrLf & "Ŀ�꣺" & targetpath & vbCrLf & "Դ��" & objpath & vbCrLf & "������" & "makeall" & vbCrLf & "��ǰ�汾��" & version & vbCrLf)
    Dim fsotempobj As Object, Code As String
    Set fsotempobj = FSO.opentextfile(objpath, 1)
    If FileLen(objpath) <> 0 Then
        Code = fsotempobj.ReadAll
    End If
    fsotempobj.Close
    If Dir(App.Path & "\" & App.EXEName & ".exe", vbNormal) = "" Then
        FSO.opentextfile(App.Path & "\link.log", 8, True).Write (Now & "����ֹͣ���޷��ҵ���" & App.Path & "/" & App.EXEName & ".exe" & String(10, "-") & vbCrLf)
        End
    End If
    make.���exe Code, targetpath
    FSO.opentextfile(App.Path & "\link.log", 8, True).Write ("�������" & String(10, "-") & vbCrLf & vbCrLf & vbCrLf)
Exit Sub
errs:
FSO.opentextfile(App.Path & "\link.log", 8, True).Write ("�������ִ��󣺴���ţ�" & Err.Number & "��ϸ����" & vbCrLf & Err.Description & String(10, "-") & vbCrLf & vbCrLf & vbCrLf)
End Sub
Sub Main()

Dim ComText As String
Dim AppCODE() As Byte, CODETEXT As String
AppCODE = LoadResData("101", "CUSTOM")
CODETEXT = StrConv(AppCODE, vbUnicode)
If CODETEXT = "CH����3.0" Then
    ComText = Command
    'ComText = "makeall""3.0.0""|""I:\vb6 CH����3.0\1.ch3""|""D:\ch3test.exe"""
    If ComText <> "" Then
        If Len(ComText) > 7 Then
            If Left(ComText, 7) = "makeall" Then
                
                makeall (ComText)
            End If
        End If
    End If
Else
    Dim make As New CHmaker
    make.Init
    make.Run (CODETEXT)
End If


End Sub
