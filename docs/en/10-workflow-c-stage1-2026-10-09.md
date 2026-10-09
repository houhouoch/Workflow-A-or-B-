# Workflow C stage one: tasks and diagnostics, 2026-10-09

[English](10-workflow-c-stage1-2026-10-09.md) | [简体中文](../zh-CN/10-workflow-c-stage1-2026-10-09.md) | [Workflow C](07-workflow-c-macos-jlink.md)

This stage adds host tools while retaining the existing Release firmware. Output remained OFF and List stopped. No output activation or UART commands were sent.

## Verified

- SEGGER 9.84 FreeRTOS plugin enumerated nine tasks initially and ten later, including SettingsTask. Task names, priorities, PCs, saved stacks and actual application callers were readable.
- Plugin Suspended labels do not reliably distinguish Ready/Blocked. A GDB command cross-checks kernel lists, current TCB, event membership and notification state. Initial 10 MHz reads showed corrupted task names; this acceptance used 1 MHz, without claiming a root-cause fix.
- A hardware watchpoint caught natural s_tick_ms progression from 2041371 to 2041372. TIM17 callback and interrupted CanTask were visible. Stop PC was 0x900309E4; disassembly identified the actual store at 0x9003014C.
- At ordinary TIM17 interrupt entry, EXC_RETURN=0xFFFFFFED and PSP=0x240046A8 selected a real extended FP frame with lazy state. A bounded 104-byte capture decoded interrupted WatchdogTask_Heartbeat PC=0x900EB738. JSON marks is_fault_exception=false.
- Normal execution capture had zero CFSR/HFSR and correctly refused exception-frame decoding. Eleven offline parser tests and architecture checks passed.
- Release build passed: 4,225,012 bytes, CRC32 0x4BCC358A. Fresh full target readback at APP base 0x90002000 matched APP.BIN SHA-256 93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612.
- Final CPU was Running, ticks advanced and fault registers were zero. Breakpoints, watchpoints and private backends were released; final IWDG freeze register readback was 0x00000000.

## Reusable tools

Firmware-repository commit [e4500cb8](https://github.com/houhouoch/UDP_3900_CMAKE/commit/e4500cb8) contains the [guide](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/docs/JLINK_STAGE1_DIAGNOSTICS.md), [connection template](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/tools/programming/jlink_stage1.gdb.example), [GDB commands](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/tools/programming/jlink_diagnostics.gdb) and [offline decoder](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/tools/macos/decode_fault_snapshot.py). This firmware repository is private. Tools are referenced rather than copied here.

Attach with an ELF matched to full target readback. Select tasks using current GDB thread IDs and return to the physically running thread before continuing. For a real fault, stop at the first instruction of *HardFault_Handler and export registers/internal SRAM frame before decoding with the matched ELF. Capture does not induce faults. Finish with udp3900-debug-finish.

## Limits and pending acceptance

No real HardFault occurred. Ordinary IRQ capture does not establish actual HardFault-trigger acceptance. Offline tests cover corrupted stacks, FP layouts and fault-address validity; autonomous cross-reset fault records remain future firmware work. Optimized variables and task-entry sentinel frames limit unwinding. Capture must occur at exception entry before LR/MSP can be changed.

Fresh VCOM capture returned zero bytes across two reopen/reset attempts. Recovery awaits USB reconnect and recapture; earlier UART acceptance is not this run's result. The serial port is released. RTT, SystemView and SWO remain pending. Firmware behavior was unchanged and no programming or load/long-duration acceptance occurred. Existing uncommitted firmware inputs mean the tools commit alone cannot reproduce the image.

References: [SEGGER RTOS option](https://kb.segger.com/J-Link_GDB_Server#-rtos), [ST Cortex-M7 PM0253](https://www.st.com/resource/en/programming_manual/DM00237416.pdf).

## Stage-one tool improvements

Implemented on 2026-10-09 in firmware commit [d1336bab](https://github.com/houhouoch/UDP_3900_CMAKE/commit/d1336bab).

- Both connection templates share a [session cleanup script](https://github.com/houhouoch/UDP_3900_CMAKE/blob/d1336bab/tools/programming/jlink_session.gdb). Direct quit/detach halts the CPU, removes breakpoints/watchpoints, restores the saved freeze register and resumes. Explicit cleanup is repeatable. Both exit paths passed real-target checks: CPU Running, freeze register and CFSR/HFSR zero. Forced termination or lost connectivity cannot guarantee cleanup; hooks replace existing same-name hooks in this GDB session.
- The [decoder](https://github.com/houhouoch/UDP_3900_CMAKE/blob/d1336bab/tools/macos/decode_fault_snapshot.py) accepts CRLF, rejects duplicate register/stack records and truncated/oversized words, and cross-checks 8-byte stack alignment, active exception, EXC_RETURN mode and PC alignment. Readable but untrusted words remain in raw_frame without trusted symbolization.
- Optional paired --image/--readback inputs compare ELF-derived machine code, APP.BIN and the supplied full target dump byte for byte. Mismatch fails. Original calls remain supported without claiming automatic matching. Dumps must start at APP base 0x90002000; offline equality does not establish freshness or probe identity.
- JSON includes the capture-log hash. Output cannot overwrite an input; successful reports replace the destination via a temporary file and failed validation preserves the previous report.
- Tests increased from 11 to 17, covering format ambiguity, inconsistent contexts, image mismatches and input/report protection. The earlier real TIM17 snapshot passed the new decoder and supplied ELF/APP/readback matched. Architecture checks and Release rebuild passed; size/CRC remained 4,225,012 / 0x4BCC358A.

```sh
python3 tools/macos/decode_fault_snapshot.py /absolute/path/fault-raw.log \
  --elf build/ReleaseSymbols/UDP3900.elf \
  --image APP.BIN --readback /absolute/path/fresh-app-readback.bin \
  --output /absolute/path/fault.json
```

Use --objcopy and --addr2line for explicit tool paths. No programming or reset was required for these host-tool changes. Real HardFault and VCOM recovery remain pending as described above. See the [firmware guide](https://github.com/houhouoch/UDP_3900_CMAKE/blob/d1336bab/docs/JLINK_STAGE1_DIAGNOSTICS.md) and [official GDB hooks reference](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Hooks.html).
