# Workflow B: VS Code Debugging

[简体中文](../zh-CN/04-workflow-b-cmsis-gdb.md) | [English](04-workflow-b-cmsis-gdb.md) | [Home](../../README.en.md)

## When to use it

Use this workflow for command-line backtraces, arguments, locals, and register evidence, or for a modern VS Code debugging interface.

## Standard chain

```text
preflight -> MDK build -> verified MDK download ->
start pyOCD GDB Server -> wait for the GDB-ready log ->
GDB loads AXF symbols -> monitor reset halt -> hbreak -> continue ->
bt / args / locals / registers -> detach -> process cleanup
```

## Start pyOCD

Adjust the target name and probe selection for the hardware:

```powershell
pyocd gdbserver --target <target-name> --uid $env:CMSIS_DAP_UID --port 3333
```

Wait for `GDB server listening` in the pyOCD log. Do not probe port 3333 with a generic TCP client. pyOCD commonly allows one GDB client, and a readiness probe can consume the only connection.

## GDB commands

Copy [`templates/debug.gdb.template`](../../templates/debug.gdb.template) and replace the AXF and breakpoint symbol:

```gdb
file <firmware.axf>
target extended-remote localhost:3333
set breakpoint auto-hw on
monitor reset halt
hbreak <breakpoint_symbol>
continue
bt
info args
info locals
info registers
detach
quit
```

Run it with:

```powershell
arm-none-eabi-gdb --batch -x debug.gdb
```

## VS Code

The VS Code Cortex/CMSIS launch configuration should reuse the same AXF, pyOCD target name, and probe UID. VS Code is ideal for interactive source, variable, and call-stack inspection; keep batch GDB logs for automated evidence.

## Success evidence

```text
Hardware assisted breakpoint
Breakpoint <n>, <requested-symbol>
#0  <requested-symbol>
```

Also capture `PC/LR/SP`, source file, and source line. A zero GDB exit code or a connected pyOCD server is not sufficient by itself.

> [!WARNING]
> Do not execute `load` in the GDB script. Keil MDK has already downloaded and verified the image; a second pyOCD/GDB download may bypass the external-Flash algorithm.
