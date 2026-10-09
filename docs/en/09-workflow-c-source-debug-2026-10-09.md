# Workflow C Source-Debug Acceptance: 2026-10-09

[简体中文](../zh-CN/09-workflow-c-source-debug-2026-10-09.md) | [English](09-workflow-c-source-debug-2026-10-09.md) | [Workflow C](07-workflow-c-macos-jlink.md) | [Home](../../README.en.md)

## Result and scope

Basic source debugging passed on the same UDP3900 / STM32H750, Apple Silicon macOS and J-Link, using native SEGGER 9.84 GDB Server and GNU Arm GDB 16.3. The user's existing output OFF/List stopped confirmation was retained. No power output was enabled or UART command sent.

The separate `ReleaseSymbols` configuration uses `-Os -g3`. Its 4225012-byte machine code matched Release and full pyOCD target readback, SHA-256 `93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612`; no programming was needed. The tested checkout still contains uncommitted UI/tool edits, so the commit alone cannot reproduce this image.

| Acceptance | Actual evidence |
|---|---|
| Periodic hardware breakpoint | WatchdogTask_Run line 115, PC=0x900eb63e; hit after continue |
| Parameter and caller | WatchdogTask_Heartbeat line 175, client=WATCHDOG_TASK_CLIENT_CAN; CanTask_Run line 3473 |
| Locals | observed_mask=15, monitoring_started=1, health_window_ticks=3000 |
| Function backtrace | PlatformWatchdog_Refresh line 33 called by WatchdogTask_Run line 115 |
| Instruction step | Entered PlatformWatchdog_Refresh, PC=0x900eb790 |
| Source step | Heartbeat line 175 advanced to line 180, PC=0x900eb74a |
| Resume | Breakpoints removed, freeze register restored, go/detach; Running CPU and advancing ticks |
| Serial recheck | Capture before software reset; 115200, one boot in 45 seconds, DSP 9/9 and UI ready; no heartbeat missing/reset pending |
| Cleanup | Server/capture exited; no listener on 2331 or serial owner |
| Final build | Ordinary Release rebuilt with unchanged binary hash; architecture/memory checks passed |

## Reusable entry points

Board-owned files are the [ReleaseSymbols preset](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/CMakePresets.json), [macOS build script](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/tools/macos/build_cmake.sh), [GDB template](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/tools/programming/jlink_source_debug.gdb.example) and [full instructions](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/docs/CMAKE_GCC_WORKFLOW.md). The firmware repository is private and requires access. Tooling commit: `a021d4ce`. These implementations remain in that repository.

Preserve Release artifacts, build ReleaseSymbols and compare complete target readback before attaching. With matching machine code, start the native backend and load only ELF symbols:

```bash
tools/macos/build_cmake.sh --build-type ReleaseSymbols
"$SEGGER_RUNTIME_DIR/JLinkGDBServerCLExe"   -select "USB=$JLINK_UID" -device STM32H750XB -if SWD -speed 10000   -endian little -port 2331 -swoport 2332 -telnetport 2333   -localhostonly 1 -noreset -noir -nohalt -nogui -singlerun
```

From the firmware root in another terminal:

```bash
arm-none-eabi-gdb -q build/ReleaseSymbols/UDP3900.elf   -x tools/programming/jlink_source_debug.gdb.example
```

The template uses `hbreak`, disables Flash Breakpoints, saves the IWDG freeze register and enables freezing during halt. At the execution hit, inspect `info args`, `info locals`, `bt 5`, `step` or `stepi`. Execute `udp3900-debug-finish` before quitting to remove breakpoints, restore the saved register and resume/detach. Explicit cleanup is also required after failures. Do not run competing pyOCD and native debug backends.

## Limits and next work

- Optimization makes some locals, including now_ticks and flags, `<optimized out>`.
- Real functions and callers unwind; above the FreeRTOS task entry, sentinel/repeated frames stop the backtrace. This is neither proof of application stack damage nor acceptance of RTOS/all-task stacks.
- Native bulk QSPI reads failed, still at 0x90002800 after reducing packet size. Full verification used pyOCD; the native bulk path remains unresolved.
- GDB `load`, native SEGGER QSPI loaders, watchpoints, HardFault capture, FreeRTOS plugin, RTT, SystemView and SWO were not validated.
- Application UART is 115200 and unchanged Bootloader is 460800, so early garbled bytes remain possible. The 45-second window is not long-term acceptance.
- No product logic changed. The same day's 99 host tests were not repeated; new configuration verification covered ReleaseSymbols/Release builds, architecture checks and actual board debugging.

Next validate the FreeRTOS plugin and task-stack boundary, then watchpoints and fault context. [Official GDB Server reference](https://kb.segger.com/J-Link_GDB_Server).
