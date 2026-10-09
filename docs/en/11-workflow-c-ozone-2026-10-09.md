# Workflow C: Ozone graphical debug example

Ozone V3.50b was installed on Apple Silicon macOS on 2026-10-09. The existing J-Link attached to STM32H750XB over 1 MHz SWD. The validated project, launcher and detailed instructions are in firmware commit [9df805b2](https://github.com/houhouoch/UDP_3900_CMAKE/commit/9df805b2): [project](https://github.com/houhouoch/UDP_3900_CMAKE/blob/9df805b2/tools/programming/udp3900_ozone.jdebug), [guide](https://github.com/houhouoch/UDP_3900_CMAKE/blob/9df805b2/docs/OZONE_QUICKSTART.md).

Confirm output OFF and List stopped before attaching. Close other SWD backends. The project loads a matching ReleaseSymbols ELF, Cortex-M7F and STM32H750x SVD descriptions, and the maintained FreeRTOS Cortex-M plugin. Breakpoints are hardware-only; reset and download are skipped. Update the probe serial and SVD path when moving to another host or probe.

Run `Debug.Halt();`, wait for the stop, then `Script.Exec("DemoHeartbeat");`. Hardware validation stopped at `WatchdogTask_Heartbeat`, line 175, with `client=0` (CAN task), PC=`0x900EB738`, SP=`0x24004710`; the call stack identified `CanTask_Run`. F12 advanced PC to `0x900EB74A`. The FreeRTOS view showed nine tasks. Deeper task-entry frames and Suspended labels retain the limitations documented in stage one. Zero Run Count does not prove a task never ran.

Registers exposes CPU and peripheral fields. UART7 BRR read `0x412`, CR1 read `0x1D`; CFSR/HFSR were zero. BRR alone does not establish baud rate without the UART clock and oversampling settings. Watches include the diagnostic tick, RTOS tick, task count and fault registers. Optimized or out-of-scope locals may be unavailable.

`Script.Exec("DemoResume");` removes the example breakpoint and resumes. For cleanup, halt and wait, then run `Script.Exec("DemoFinish");`, followed by Shift+F5. Cleanup restores the saved IWDG freeze value and resumes. Forced termination or connection loss cannot guarantee cleanup. The pre-existing freeze value was `0x00040000` and was restored; CPU Running and advancing ticks were verified.

Full readback of 4,225,012 bytes at APP address `0x90002000` matched ELF machine code and APP.BIN, SHA-256=`93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612`. Attach, hardware breakpoint, locals, CPU/peripheral reads, call stack, task view, step and resume passed. No firmware edits, flashing, physical output activation, induced HardFault or RTT integration occurred. Serial and DSP/physical-output acceptance remain separate.

Ozone's documented localhost automation socket at `127.0.0.1:19200` accepts Console commands. It was used to operate the debugger and read feedback, with graphical confirmation. Verify a fresh matching ELF whenever firmware changes. References: [Ozone manual](https://www.segger.com/downloads/jlink/UM08025_Ozone.pdf), [bootloader debugging](https://kb.segger.com/Debug_on_a_Target_with_Bootloader).
