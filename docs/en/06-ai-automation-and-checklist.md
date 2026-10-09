# AI Automation Contract and New-Machine Checklist

[简体中文](../zh-CN/06-ai-automation-and-checklist.md) | [English](06-ai-automation-and-checklist.md) | [Home](../../README.en.md)

## AI execution contract

When an AI is asked to run any workflow, it should:

1. Read this knowledge base and the target repository's local guidance.
2. Inspect Git state and preserve unrelated user changes.
3. Resolve the real project file, AXF/ELF, target name, probe UID, and serial-log path.
4. Run preflight, build, download, and debug in that order.
5. Prefer commands and official APIs over mouse-coordinate automation.
6. Allow download to finish without a short timeout.
7. Extract breakpoint, source line, backtrace, or expression evidence from logs.
8. Never report “connected” or a zero exit code as complete success.
9. Release every private debug process.
10. Report only actions and results that were actually verified.

## Workflow A / B: minimum new-machine checklist

- [ ] Keil MDK can open and build the target `.uvprojx` manually.
- [ ] `UV4.exe`, `UVSC64.dll`, and the required compiler are installed.
- [ ] Python 3 runs from PowerShell.
- [ ] pyOCD and `arm-none-eabi-gdb` are available for Workflow B.
- [ ] CMSIS-DAP discovers the powered target.
- [ ] Only one process owns the probe.
- [ ] Build completes with zero errors.
- [ ] Download emits all three verification markers.
- [ ] Workflow A hits one execution hardware breakpoint.
- [ ] Workflow B prints a matching `#0` frame.
- [ ] A fresh serial startup marker appears after the target resumes.
- [ ] No private debug process remains after cleanup.

## Recommended validation ladder

```text
environment check
  -> build only
  -> download only
  -> recurring-function breakpoint
  -> startup-function breakpoint
  -> expression/backtrace inspection
  -> end-to-end serial validation
```

Do not start with the full chain on a new machine. Layered validation isolates failures and makes reproduction faster.

## Workflow C: minimum new-machine checklist

- [ ] CMake, Ninja, full GNU Arm tools, Python and pyserial run.
- [ ] SEGGER library loads and pyOCD enumerates the current J-Link UID.
- [ ] Device Pack, run description, QSPI FLM and watchdog hook match the target repository.
- [ ] Output OFF and List stopped; halt/reset conditions confirmed by the user.
- [ ] Architecture checks, host tests, Release build and image preflight pass.
- [ ] Before backup preserved; APP/ELF protected from concurrent builds.
- [ ] Full readback length/hash match; CPU/ticks and vectors validated.
- [ ] Current probe VCOM enabled, correct port selected; 115200/8N1/no flow control.
- [ ] Capture starts before reset, is read-only with DTR/RTS off, and receives fresh completion markers.
- [ ] Serial ownership and private debug processes released afterwards.
- [ ] Source debugging requires real breakpoint, step, parameter and caller evidence; accept RTT, RTOS and tracing separately.

See [Workflow C](07-workflow-c-macos-jlink.md). This checklist does not authorize enabling power output or changing firmware behavior.
