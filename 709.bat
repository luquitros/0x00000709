@echo off
echo =========================================
echo Windows 11 24H2 RPC with fixed port v.2.0
echo by TWT | 2025-08-19 (refined)
echo =========================================
echo.

net session >nul 2>&1
if errorlevel 1 (
    echo [ERRO] Execute este script como Administrador!
    pause
    exit /b 1
)

set CHANGED=0

:: -----------------------------------------------
:: 1. NoWarningNoElevationOnInstall
:: -----------------------------------------------
set KEY="HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint"
for /f "tokens=3" %%a in ('reg query %KEY% /v NoWarningNoElevationOnInstall 2^>nul') do set VAL1=%%a
if "%VAL1%"=="0x1" (
    echo [OK]     NoWarningNoElevationOnInstall ja esta configurado ^(1^)
) else (
    echo [APLICANDO] NoWarningNoElevationOnInstall...
    reg add %KEY% /v NoWarningNoElevationOnInstall /t REG_DWORD /d 1 /f >nul
    set CHANGED=1
)

:: -----------------------------------------------
:: 2. UpdatePromptSettings
:: -----------------------------------------------
for /f "tokens=3" %%a in ('reg query %KEY% /v UpdatePromptSettings 2^>nul') do set VAL2=%%a
if "%VAL2%"=="0x2" (
    echo [OK]     UpdatePromptSettings ja esta configurado ^(2^)
) else (
    echo [APLICANDO] UpdatePromptSettings...
    reg add %KEY% /v UpdatePromptSettings /t REG_DWORD /d 2 /f >nul
    set CHANGED=1
)

:: -----------------------------------------------
:: 3. RpcAuthnLevelPrivacyEnabled
:: -----------------------------------------------
set KEY2="HKLM\SYSTEM\CurrentControlSet\Control\Print"
for /f "tokens=3" %%a in ('reg query %KEY2% /v RpcAuthnLevelPrivacyEnabled 2^>nul') do set VAL3=%%a
if "%VAL3%"=="0x0" (
    echo [OK]     RpcAuthnLevelPrivacyEnabled ja esta desabilitado ^(0^)
) else (
    echo [APLICANDO] Desabilitando RpcAuthnLevelPrivacyEnabled...
    reg add %KEY2% /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul
    set CHANGED=1
)

:: -----------------------------------------------
:: 4. RpcTcpPort
:: -----------------------------------------------
set KEY3="HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"
for /f "tokens=3" %%a in ('reg query %KEY3% /v RpcTcpPort 2^>nul') do set VAL4=%%a
if "%VAL4%"=="0x259" (
    echo [OK]     RpcTcpPort ja esta configurado ^(601^)
) else (
    echo [APLICANDO] Configurando RpcTcpPort para 601...
    reg add %KEY3% /v RpcTcpPort /t REG_DWORD /d 601 /f >nul
    set CHANGED=1
)

:: -----------------------------------------------
:: 5. RpcUseNamedPipeProtocol
:: -----------------------------------------------
for /f "tokens=3" %%a in ('reg query %KEY3% /v RpcUseNamedPipeProtocol 2^>nul') do set VAL5=%%a
if "%VAL5%"=="0x1" (
    echo [OK]     RpcUseNamedPipeProtocol ja esta configurado ^(1^)
) else (
    echo [APLICANDO] Configurando RpcUseNamedPipeProtocol...
    reg add %KEY3% /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f >nul
    set CHANGED=1
)

:: -----------------------------------------------
:: 6. RpcProtocols
:: -----------------------------------------------
for /f "tokens=3" %%a in ('reg query %KEY3% /v RpcProtocols 2^>nul') do set VAL6=%%a
if "%VAL6%"=="0x7" (
    echo [OK]     RpcProtocols ja esta configurado ^(0x7^)
) else (
    echo [APLICANDO] Configurando RpcProtocols...
    reg add %KEY3% /v RpcProtocols /t REG_DWORD /d 0x7 /f >nul
    set CHANGED=1
)

:: -----------------------------------------------
:: 7. ForceKerberosForRpc
:: -----------------------------------------------
for /f "tokens=3" %%a in ('reg query %KEY3% /v ForceKerberosForRpc 2^>nul') do set VAL7=%%a
if "%VAL7%"=="0x0" (
    echo [OK]     ForceKerberosForRpc ja esta configurado ^(0^)
) else (
    echo [APLICANDO] Configurando ForceKerberosForRpc...
    reg add %KEY3% /v ForceKerberosForRpc /t REG_DWORD /d 0 /f >nul
    set CHANGED=1
)

echo.

:: -----------------------------------------------
:: 8. Regra de Firewall porta 601
:: -----------------------------------------------
netsh advfirewall firewall show rule name="Print-RPC 601" >nul 2>&1
if errorlevel 1 (
    echo [APLICANDO] Adicionando regra de firewall: Print-RPC 601...
    netsh advfirewall firewall add rule name="Print-RPC 601" dir=in action=allow protocol=TCP localport=601 profile=private >nul
    set CHANGED=1
) else (
    echo [OK]     Regra de firewall "Print-RPC 601" ja existe
)


netsh advfirewall firewall show rule name="Print-RPC Endpoint Mapper" >nul 2>&1
if errorlevel 1 (
    echo [APLICANDO] Adicionando regra de firewall: Print-RPC Endpoint Mapper...
    netsh advfirewall firewall add rule name="Print-RPC Endpoint Mapper" dir=in action=allow protocol=TCP localport=135 profile=private >nul
    set CHANGED=1
) else (
    echo [OK]     Regra de firewall "Print-RPC Endpoint Mapper" ja existe
)

echo.


if "%CHANGED%"=="1" (
    echo [INFO] Alteracoes detectadas. Reiniciando Spooler...
    net stop spooler >nul 2>&1
    net start spooler >nul 2>&1
    echo [OK]   Spooler reiniciado.
) else (
    echo [INFO] Nenhuma alteracao necessaria. Spooler nao foi reiniciado.
)

echo.
echo =========================================
echo Concluido! Configuracoes RPC verificadas.
echo =========================================
pause
