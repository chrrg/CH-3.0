@echo 开始注册 --必须要右键以管理员方法打开哦！且必须与CASMUI.DLL文件放一起
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(Echo 检测到您未用管理员身份，请使用右键管理员身份运行！否正无法正常注册组件。&&Pause >nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
%~d0
cd %~dp0 
if exist %windir%\SysWOW64 (
copy CASMUI.DLL %windir%\syswow64\ 
%windir%\syswow64\regsvr32 %windir%\syswow64\CASMUI.DLL
)else (
%windir%\system32\regsvr32 %windir%\system32\CASMUI.DLL
)
@echo 注册完成——CH
@pause 