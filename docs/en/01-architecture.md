# Architecture and Backend Selection

[简体中文](../zh-CN/01-architecture.md) | [English](01-architecture.md) | [Home](../../README.en.md)

## Core conclusion

From the operator's perspective, these are the **MDK/uVision workflow** and the **VS Code workflow**. Underneath, they share the MDK build toolchain and use different debug backends.

| Phase | Tool |
|---|---|
| Workflow A user interface | Keil MDK / uVision |
| Workflow B user interface | VS Code |
| Build, link, and AXF generation | Keil MDK `UV4.exe -b` or `-r` |
| Download and verification | Keil MDK `UV4.exe -f` |
| Workflow A debug backend | `UVSC64.dll` controlling a private uVision session |
| Workflow B debug backend | CMSIS-DAP + pyOCD + `arm-none-eabi-gdb` |
| Runtime evidence | Serial log, optional but strongly recommended |

In Workflow B, GDB reads symbols from the MDK-generated AXF and controls the target. It does not rebuild the firmware and should not program the QSPI image again.

## Backend selection

| Need | Recommended workflow |
|---|---|
| Reuse the exact Keil project, device, and debug configuration | A: MDK/uVision |
| Use native uVision expressions and debug commands | A: MDK/uVision |
| Capture backtraces, arguments, locals, and PC/LR/SP as text | B: VS Code/GDB |
| Browse source and variables in VS Code | B: VS Code/GDB |
| Diagnose Keil-specific startup behavior | A: MDK/uVision |
| Run a lightweight command-line breakpoint smoke test | B: VS Code/GDB |

## Shared completion criteria

A zero process exit code is not enough. Require at least:

1. `0 Error(s)` in the build log.
2. `Programming Done.`, `Verify OK.`, and `Flash Load finished` in the download log.
3. Proof that execution hit the requested breakpoint, not a manual halt, reset, or fault.
4. A source location and target PC matching the requested AXF symbol.
5. Probe ownership released after the session.
