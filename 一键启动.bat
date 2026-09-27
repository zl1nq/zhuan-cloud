@echo off
chcp 65001 >nul
title 筑安云
cd /d "%~dp0backend"

set "UV=uv"
where uv >nul 2>&1
if errorlevel 1 (
    where python >nul 2>&1
    if errorlevel 1 (
        echo.
        echo  未检测到 uv 或 Python，请先安装 Python 3.11+（勾选 Add to PATH）：
        echo    https://www.python.org/downloads/
        echo  或直接安装 uv： https://docs.astral.sh/uv/getting-started/installation/
        echo.
        pause & exit /b 1
    )
    echo 未检测到 uv，正在通过 pip 安装 uv（仅需一次）...
    python -m pip install -q -U uv -i https://mirrors.aliyun.com/pypi/simple/
    if errorlevel 1 (echo uv 安装失败，请检查网络 & pause & exit /b 1)
    set "UV=python -m uv"
)

echo.
echo  正在同步依赖环境（首次约1-2分钟，之后秒过）...
%UV% sync
if errorlevel 1 (echo. & echo 依赖同步失败，请检查网络后重试 & pause & exit /b 1)

echo.
echo  ================================================
echo   筑安云启动中...  浏览器将自动打开
echo   本机访问： http://127.0.0.1:8000
echo   局域网访问： http://本机IP:8000  （供队友访问）
echo   演示账号： zhangmin / liqiang / zeren01 等
echo              密码均为 zhuan@123
echo  ================================================
echo.
start "" cmd /c "timeout /t 6 /nobreak >nul & start http://127.0.0.1:8000"
%UV% run python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
pause
