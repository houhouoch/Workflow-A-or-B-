# 流程 B：CMSIS-DAP + pyOCD + GDB/VS Code

[简体中文](04-workflow-b-cmsis-gdb.md) | [English](../en/04-workflow-b-cmsis-gdb.md) | [返回首页](../../README.md)

## 适用场景

需要命令行调用栈、参数、局部变量和寄存器证据，或者希望在 VS Code 中获得现代化调试界面。

## 标准链路

```text
检查环境 -> MDK 编译 -> MDK 下载并校验 ->
启动 pyOCD GDB Server -> 等待 GDB-ready 日志 ->
GDB 加载 AXF 符号 -> monitor reset halt -> hbreak -> continue ->
bt / args / locals / registers -> detach -> 清理进程
```

## 启动 pyOCD

以下参数需要按目标芯片和探针调整：

```powershell
pyocd gdbserver --target <target-name> --uid $env:CMSIS_DAP_UID --port 3333
```

等待 pyOCD 日志出现 `GDB server listening`，不要用普通 TCP 客户端探测 3333 端口。pyOCD 通常只允许一个 GDB 客户端，TCP 探测可能抢走唯一连接。

## GDB 命令

复制 [`templates/debug.gdb.template`](../../templates/debug.gdb.template)，替换 AXF 和断点符号：

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

运行：

```powershell
arm-none-eabi-gdb --batch -x debug.gdb
```

## VS Code

VS Code 的 Cortex/CMSIS 调试配置应复用同一 AXF、pyOCD 目标名和探针 UID。它适合人工查看源码、变量和调用栈；自动化验证仍建议保留批处理 GDB 日志。

## 成功证据

```text
Hardware assisted breakpoint
Breakpoint <n>, <requested-symbol>
#0  <requested-symbol>
```

同时保存 `PC/LR/SP`、源文件和行号。GDB 退出码为零或 pyOCD 已连接都不能单独作为成功证据。

> [!WARNING]
> 不要在 GDB 脚本中执行 `load`。固件已经由 Keil MDK 下载和校验，再由 pyOCD/GDB 下载可能绕过外部 Flash 算法。

