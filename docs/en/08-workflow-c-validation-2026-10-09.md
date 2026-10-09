# Workflow C Validation: 2026-10-09

[简体中文](../zh-CN/08-workflow-c-validation-2026-10-09.md) | [English](08-workflow-c-validation-2026-10-09.md) | [Workflow C](07-workflow-c-macos-jlink.md) | [Home](../../README.en.md)

## Scope

Apple Silicon macOS, UDP3900 / STM32H750, J-Link (enumerated as PLUS, hardware V12.00), 10 MHz SWD and UART7 at 115200. SEGGER 9.84, pyOCD 0.45.1, GNU Arm 15.2.1 and STM32H7 DFP 2.7.0. Measured VTref: 3.257 V. The user confirmed output OFF and List stopped before board work.

Baseline commit: `75f831a4c13a450245cbffcee422353150ac1515`. The tested checkout also contained uncommitted UI and tool changes. This was not a clean build of that commit, and reproducibility from that commit alone is not claimed.

## Results

| Stage | Observed result |
|---|---|
| Architecture check | Passed |
| Host tests | `Host tests passed: 99 executable(s).` |
| Release build | 4225012 bytes; CRC32 0x4BCC358A |
| Download | 0 bytes erased, 0 bytes programmed; 4227072 bytes / 1032 pages identical, skipped |
| Before backup | 8376320-byte application area preserved locally |
| Full readback | 4225012 bytes; length and SHA-256 matched APP.BIN |
| CPU and vectors | Running CPU, VTOR 0x90002000 and advancing ticks |
| UART configuration | Runtime handle showed 115200 |
| Serial capture | Logs received after USB replug; one boot in a 45-second window |
| DSP | Startup sync 9/9, failed-action=0 |
| UI | Startup gate ready, ready route=1 |
| Cleanup | Capture exited with no remaining serial owner |

The loader's page range of 4227072 bytes differs from the actual 4225012-byte image. Hash comparison used the actual image size.

APP.BIN and READBACK.BIN SHA-256:

```text
93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612
```

Selected serial evidence, excluding workstation paths and port identity:

```text
[CAN] startup sync request=1 state=2 completed=9/9 failed-action=0
[WATCHDOG] critical task monitoring active
[UI] startup gate ready; DSP synchronized and protection clear
[UI] ready route=1 heap=1024 KiB backlight=100%
[HOST] capture completed
```

## Limitations

- RESET pin 15 and CPU halt warnings occurred. One reset call also reported a core identification warning. Later explicit reset/go, Cortex-M7 Running, readback and serial evidence passed; the warnings' causes remain unresolved.
- Initial 50-second capture and a 25-second raw-byte capture received no data. The user verified wiring and power-cycled J-Link USB, after which capture worked. A serial node had already existed, so enumeration alone did not prove the UART path worked.
- The application is 115200, while Bootloader remains 460800. Initial garbled bytes occurred; Bootloader was not updated.
- One boot in 45 seconds is not a long-duration stability test.
- Source breakpoints, stepping, variables/backtraces, RTT, FreeRTOS plugin, SystemView, SWO and native SEGGER external-QSPI loaders remain unvalidated.
- COMTool close/reopen races were reproduced using simulated serial, but not fixed. Final serial acceptance used an independent read-only script.
- Firmware, full backups and raw logs remain local.
