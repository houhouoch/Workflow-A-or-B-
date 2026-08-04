# Workflow A: Keil MDK + UVSC

[简体中文](../zh-CN/03-workflow-a-keil-uvsc.md) | [English](03-workflow-a-keil-uvsc.md) | [Home](../../README.en.md)

## When to use it

Use this workflow when the exact Keil device, Flash algorithm, initialization script, and expression semantics must be preserved while breakpoints and inspection are automated from commands.

## Standard chain

```text
preflight -> MDK build -> MDK download -> create a safe temporary project copy ->
start a private uVision session through UVSC -> hardware breakpoint -> reset/run ->
read expressions -> save protocol evidence -> close private uVision
```

## MDK build and download

```powershell
& $env:KEIL_UV4_PATH -b $env:FIRMWARE_PROJECT -j0 -o build.log
& $env:KEIL_UV4_PATH -f $env:FIRMWARE_PROJECT -o download.log
```

Download may take a long time. Do not terminate it merely because output pauses. Wait for all three markers:

```text
Programming Done.
Verify OK.
Flash Load finished
```

## UVSC control rules

- Use the official Keil UVSC API, not mouse or keyboard automation.
- Use a private uVision process so the user's open project remains untouched.
- Disable unsafe startup `LOAD` commands only in a temporary project copy.
- Use an execution hardware breakpoint for code in external execution memory.
- Reset before a one-shot startup function; use a recurring function for a fast attach test.

## Success evidence

In addition to build and download markers, capture:

```text
breakpoint created
target stopped by breakpoint or target event
inspect completed
stop reason = execution
```

“Debug entered,” “target stopped,” or a zero exit code alone does not prove a breakpoint hit.

## Suitable inspection targets

- Native Keil expressions.
- Registers.
- Globals and public getter return values.
- Current source file and line.

If the automation wrapper is missing, rebuild a thin layer over `UVSC64.dll`; do not depend on GUI coordinates.

