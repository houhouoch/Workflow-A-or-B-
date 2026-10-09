# Evidence, Logs, and Troubleshooting

[简体中文](../zh-CN/05-evidence-and-troubleshooting.md) | [English](05-evidence-and-troubleshooting.md) | [Home](../../README.en.md)

## Three evidence layers

| Layer | What it proves | Typical markers |
|---|---|---|
| Build evidence | Current source produces an image | `0 Error(s)` |
| Download evidence | Current image was written and verified | `Programming Done.`, `Verify OK.` |
| Runtime evidence | The target executed the expected path | Breakpoint hit, backtrace, registers, serial marker |

The layers are not interchangeable. A normal serial log does not prove the breakpoint, and a breakpoint hit does not prove that the newest image was downloaded.

## Serial logs

Use [`templates/serial-watch.ps1`](../../templates/serial-watch.ps1) to follow appended output:

```powershell
.\templates\serial-watch.ps1 -Path $env:SERIAL_LOG_PATH -Tail 30
```

Configure the serial tool for append mode and timestamps. Record the log length before download and inspect only appended data afterward, so old startup text is not mistaken for new runtime evidence.

## Common failures

### Probe busy or cannot connect

- Close active Keil Debug and VS Code Debug sessions.
- Check `UV4`, `pyocd`, and `arm-none-eabi-gdb` processes.
- Verify target power, SWDIO, SWCLK, GND, reference voltage, and RESET.

### Download takes a long time

Do not impose a short timeout. Use `Flash Load finished` as the completion marker instead of judging temporary UI inactivity.

### Startup breakpoint never hits

- Reset before continuing into a one-shot startup function.
- Confirm the symbol exists in the current AXF and was not optimized away.
- Use a recurring function for an attach smoke test.

### QSPI or external execution warning

pyOCD may not describe external execution memory in its default map. Treat a map warning as acceptable only when the hardware breakpoint, source location, actual hit, and `#0` frame all match.

### AXF section warning

Warnings such as `outside of ELF segments` usually do not invalidate code-symbol debugging. If a RAM object cannot be read, inspect the scatter file, GDB memory map, and public getters.

### Source and target image diverge

Never skip build after source changes, and never skip download after the AXF changes. Otherwise source lines and target instructions diverge.

## End-of-session check

```powershell
$p = Get-Process UV4,pyocd,arm-none-eabi-gdb -ErrorAction SilentlyContinue
if ($null -eq $p) { 'NO_DEBUG_PROCESSES' } else { $p }
```

Generated `.log` files and temporary `.gdb` scripts are diagnostic evidence and should not be committed.

## Workflow C evidence and troubleshooting

Workflow C uses ELF, pyOCD and full SHA-256 readback comparison rather than Keil download markers. See [Workflow C](07-workflow-c-macos-jlink.md) for VCOM, baud rates, COMTool thread races, external QSPI bases, reset warnings and cleanup.

On 2026-10-09 the loader reported identical contents and skipped programming. Independent serial capture passed after USB replug, with DSP 9/9 and UI ready. Report programming activity, image equality and runtime evidence separately. See the [validation summary](08-workflow-c-validation-2026-10-09.md).
