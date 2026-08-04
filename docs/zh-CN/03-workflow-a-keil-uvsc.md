# 流程 A：MDK / uVision 调试

[简体中文](03-workflow-a-keil-uvsc.md) | [English](../en/03-workflow-a-keil-uvsc.md) | [返回首页](../../README.md)

## 适用场景

需要完全沿用 Keil 工程的器件、Flash 算法、初始化脚本和表达式语义，同时又希望由命令行自动设置断点、运行和读取值。

## 标准链路

```text
检查环境 -> MDK 编译 -> MDK 下载 -> 创建临时安全工程副本 ->
UVSC 启动独立 uVision 会话 -> 硬件断点 -> 复位并运行 ->
读取表达式 -> 保存协议日志 -> 退出私有 uVision
```

## MDK 编译和下载

```powershell
& $env:KEIL_UV4_PATH -b $env:FIRMWARE_PROJECT -j0 -o build.log
& $env:KEIL_UV4_PATH -f $env:FIRMWARE_PROJECT -o download.log
```

下载可能持续较长时间。不要因为短时间没有输出就强制终止。必须等待三个标志：

```text
Programming Done.
Verify OK.
Flash Load finished
```

## UVSC 控制原则

- 使用 Keil 官方 UVSC API，而不是鼠标和键盘自动化。
- 使用独立的私有 uVision 进程，避免干扰用户当前打开的工程。
- 在临时工程副本中禁用危险的启动 `LOAD` 命令；不要改写用户原工程配置。
- 对外部执行区代码使用硬件执行断点。
- 启动函数只运行一次，必须先复位；快速附加测试应选择周期性函数。

## 成功证据

除编译和下载标志外，还应记录：

```text
breakpoint created
target stopped by breakpoint or target event
inspect completed
stop reason = execution
```

“进入 Debug”“目标已停止”或返回码为零都不能单独证明断点命中。

## 适合读取的内容

- Keil 原生表达式。
- 寄存器。
- 全局变量和公开 getter 返回值。
- 当前源文件和行号。

如果自动化脚本缺失，优先重建一个薄封装层调用 `UVSC64.dll`，不要依赖 GUI 坐标。
