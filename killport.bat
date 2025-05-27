@echo off
chcp 65001 >nul

set /p PORT=请输入要释放的端口号：

echo 正在查找占用端口 %PORT% 的进程...

setlocal enabledelayedexpansion
set "FOUND=0"

for /f "tokens=2,5" %%a in ('netstat -ano ^| findstr :%PORT% ^| findstr LISTENING') do (
    set "FOUND=1"
    set "PID=%%b"
    echo.
    echo 监听地址：%%a
    echo 找到进程ID：!PID!
    
    rem 查询进程名（可选）
    for /f "tokens=*" %%p in ('tasklist /FI "PID eq !PID!" ^| findstr /i "!PID!"') do (
        echo 进程信息：%%p
    )

    choice /C YN /N /M "是否终止该进程 (Y/N)? "
    if errorlevel 2 (
        echo 已跳过 PID !PID!。
    ) else (
        if "!PID!"=="4" (
            echo PID 4 是系统进程，已跳过！
        ) else (
            taskkill /F /PID !PID! >nul 2>&1
            if errorlevel 1 (
                echo 终止失败，可能权限不足或进程不存在。
            ) else (
                echo 成功终止 PID !PID!。
            )
        )
    )
)

if "%FOUND%"=="0" (
    echo 未找到任何占用端口 %PORT% 且处于 LISTENING 状态的进程。
)

endlocal
echo.
echo 操作完成。
pause
