@echo off
echo =========================================
echo Windows 11 24H2 RPC with fixed port v.1.3
echo by TWT | 2025-08-19
echo =========================================
echo.
echo Disabling warning/elevation prompt when installing
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v NoWarningNoElevationOnInstall /t REG_DWORD /d 1 /f
echo.
echo Configure update prompt settings
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v UpdatePromptSettings /t REG_DWORD /d 2 /f
echo.
echo Disable RpcAuthnLevelPrivacyEnabled
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f
echo.
echo Setting RpcTcpPort to 601
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcTcpPort /t REG_DWORD /d 601 /f
echo.
echo Registry entry: RpcUseNamedPipeProtocol = 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
echo.
echo Registry entry: RpcProtocols = 0x7
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcProtocols /t REG_DWORD /d 0x7 /f
echo.
echo Registry entry: ForceKerberosForRpc = 0
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v ForceKerberosForRpc /t REG_DWORD /d 0 /f
echo.
:: Add firewall rule for port 601 if it does not already exist
netsh advfirewall firewall show rule name="Print-RPC 601" >nul 2>&1
if errorlevel 1 (
echo Adding firewall rule: Print-RPC 601
netsh advfirewall firewall add rule name="Print-RPC 601" dir=in action=allow protocol=TCP localport=601 profile=private
) else (
echo Firewall rule "Print-RPC 601" already exists
)
:: Add firewall rule for endpoint mapper (135) if it does not already exist
netsh advfirewall firewall show rule name="Print-RPC Endpoint Mapper" >nul 2>&1
if errorlevel 1 (
echo Adding firewall rule: Print-RPC Endpoint Mapper
netsh advfirewall firewall add rule name="Print-RPC Endpoint Mapper" dir=in action=allow protocol=TCP localport=135 profile=private
) else (
echo Firewall rule "Print-RPC Endpoint Mapper" already exists
)
:: Restart the Print Spooler service
echo.
echo Restarting Print Spooler...
net stop spooler >nul 2>&1
net start spooler
echo.
echo Done! Printer RPC settings have been configured.
pause
