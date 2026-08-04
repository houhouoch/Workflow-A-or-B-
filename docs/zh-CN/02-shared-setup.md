# 公共环境准备

[简体中文](02-shared-setup.md) | [English](../en/02-shared-setup.md) | [返回首页](../../README.md)

## 硬件

- 可稳定供电的 Cortex-M 目标板。
- 支持 CMSIS-DAP/DAPLink 的调试器。
- SWDIO、SWCLK、GND、目标参考电压；建议同时连接 RESET。
- USB 数据线。
- 串口适配器，用于运行日志验证。

## 软件

- Windows 10/11。
- PowerShell 5.1 或更高版本，推荐 PowerShell 7。
- Keil MDK 5、目标芯片 Device Pack 和工程使用的编译器。
- Python 3。
- 流程 B 额外需要 VS Code 的 Arm CMSIS Debugger 扩展，或独立安装的 pyOCD 与 Arm GDB。

## 通用环境变量

复制 [`templates/environment.ps1.example`](../../templates/environment.ps1.example) 并在当前 PowerShell 会话中设置真实路径：

```powershell
$env:KEIL_UV4_PATH = 'C:\Keil_v5\UV4\UV4.exe'
$env:KEIL_UV4_DIR = 'C:\Keil_v5\UV4'
$env:FIRMWARE_PROJECT = 'D:\firmware\MDK-ARM\firmware.uvprojx'
$env:FIRMWARE_AXF = 'D:\firmware\MDK-ARM\Objects\firmware.axf'
$env:SERIAL_LOG_PATH = 'D:\logs\serial.log'
$env:CMSIS_DAP_UID = '<optional-probe-uid>'
```

不要把个人电脑绝对路径提交到公共仓库。

## 预检顺序

1. 检查 Keil、Python、UVSC64.dll、AXF 和工程文件是否存在。
2. 检查目标板供电、SWD 连线和探针 UID。
3. 检查是否有其他调试器占用探针：

```powershell
Get-Process UV4,pyocd,arm-none-eabi-gdb -ErrorAction SilentlyContinue
```

4. 只做编译验证。
5. 只做下载验证。
6. 最后再进入断点调试。

这种分层验证能把“环境问题、编译问题、下载问题、调试问题”分开。

