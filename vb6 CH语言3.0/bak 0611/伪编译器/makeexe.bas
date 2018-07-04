Attribute VB_Name = "makeexe"
Option Explicit

Sub main()
comtext = Command
If comtext <> "" Then
    If Len(comtext) > 5 Then
        If Left(comtext, 4) = "make" Then
            makechcode = Mid(comtext, 5)
            codemakedata = Split(MakeCode, " ")
            objpath = codemakedata(0)
            targetpath = codemakedata(1)
        End If
    End If
End If



End Sub
