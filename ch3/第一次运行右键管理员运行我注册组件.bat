@echo ��ʼע�� --����Ҫ�Ҽ��Թ���Ա������Ŷ���ұ�����CASMUI.DLL�ļ���һ��
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo ��⵽��δ�ù���Ա��ݣ���ʹ���Ҽ�����Ա������У������޷�����ע�������&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
%~d0
cd %~dp0 
if exist %windir%\SysWOW64 (
copy CASMUI.DLL %windir%\syswow64\ 
%windir%\syswow64\regsvr32 %windir%\syswow64\CASMUI.DLL
)else (
%windir%\system32\regsvr32 %windir%\system32\CASMUI.DLL
)
@echo ע����ɡ���CH
@pause 