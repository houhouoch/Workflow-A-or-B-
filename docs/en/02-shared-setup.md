# Shared Environment Setup

[简体中文](../zh-CN/02-shared-setup.md) | [English](02-shared-setup.md) | [Home](../../README.en.md)

## Hardware

- A stably powered Cortex-M target.
- A CMSIS-DAP/DAPLink-compatible probe.
- SWDIO, SWCLK, GND, and target reference voltage; RESET is recommended.
- A USB data cable.
- A UART adapter for runtime evidence.

## Software

- Windows 10/11.
- PowerShell 5.1 or later; PowerShell 7 is recommended.
- Keil MDK 5, the target Device Pack, and the compiler used by the project.
- Python 3.
- Workflow B additionally requires the Arm CMSIS Debugger VS Code extension, or standalone pyOCD and Arm GDB.

## Generic environment variables

Copy [`templates/environment.ps1.example`](../../templates/environment.ps1.example) and set real paths in the current PowerShell session:

```powershell
$env:KEIL_UV4_PATH = 'C:\Keil_v5\UV4\UV4.exe'
$env:KEIL_UV4_DIR = 'C:\Keil_v5\UV4'
$env:FIRMWARE_PROJECT = 'D:\firmware\MDK-ARM\firmware.uvprojx'
$env:FIRMWARE_AXF = 'D:\firmware\MDK-ARM\Objects\firmware.axf'
$env:SERIAL_LOG_PATH = 'D:\logs\serial.log'
$env:CMSIS_DAP_UID = '<optional-probe-uid>'
```

Do not commit workstation-specific absolute paths to a public repository.

## Validation ladder

1. Verify Keil, Python, UVSC64.dll, the AXF, and the project file.
2. Verify target power, SWD wiring, and probe UID.
3. Check for another debugger owning the probe:

```powershell
Get-Process UV4,pyocd,arm-none-eabi-gdb -ErrorAction SilentlyContinue
```

4. Validate build only.
5. Validate download only.
6. Enter breakpoint debugging last.

This ladder separates environment, build, download, and debug failures.

