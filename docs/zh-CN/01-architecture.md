# 架构与流程选择

[简体中文](01-architecture.md) | [English](../en/01-architecture.md) | [返回首页](../../README.md)

## 流程 A / B 的工具链

从用户操作界面看，这是 **MDK/uVision 流程** 和 **VS Code 流程**。从底层工具链看，它们不是两套编译器，而是共用 MDK 构建、使用不同调试后端。

| 阶段 | 使用的工具 |
|---|---|
| 流程 A 用户入口 | Keil MDK / uVision |
| 流程 B 用户入口 | VS Code |
| 编译、链接、生成 AXF | Keil MDK `UV4.exe -b` 或 `-r` |
| 下载、校验 | Keil MDK `UV4.exe -f` |
| 流程 A 调试后端 | `UVSC64.dll` 控制独立 uVision 会话 |
| 流程 B 调试后端 | CMSIS-DAP + pyOCD + `arm-none-eabi-gdb` |
| 运行证据 | 串口日志，可选但强烈建议 |

流程 B 中的 GDB 只读取 MDK 生成的 AXF 符号并控制目标板，不负责重新编译固件，也不应该再次下载 QSPI 固件。

## 如何选择

| 需求 | 推荐流程 |
|---|---|
| 完全复用 Keil 工程、器件和调试配置 | A：MDK/uVision |
| 使用 uVision 原生表达式和调试命令 | A：MDK/uVision |
| 以文本方式获取调用栈、参数、局部变量、PC/LR/SP | B：VS Code/GDB |
| 在 VS Code 中浏览源码和变量 | B：VS Code/GDB |
| 排查 Keil 独有的初始化问题 | A：MDK/uVision |
| 快速做命令行硬件断点冒烟测试 | B：VS Code/GDB |

## 流程 A / B 的完成条件

不能因为进程返回码为零就宣布成功，至少需要：

1. 编译日志为 `0 Error(s)`。
2. 下载日志同时出现 `Programming Done.`、`Verify OK.`、`Flash Load finished`。
3. 调试日志证明断点是由执行命中，而不是手动暂停、复位或异常停止。
4. AXF 中的源位置、目标板实际 PC 和请求的断点符号一致。
5. 调试结束后释放探针。

## 流程 C：macOS 与 GCC

[流程 C](07-workflow-c-macos-jlink.md)使用 CMake/Ninja/GCC 构建 ELF，pyOCD 经 SEGGER 库操作 J-Link 编程，随后回读校验和 VCOM 串口采集。它不依赖 Keil 编译，下载算法与 QSPI 布局由目标工程提供。

| 需求 | 选择 |
|---|---|
| Apple Silicon macOS 编译、下载与运行证据 | C：已在 UDP3900 验证 |
| J-Link 原生 GDB 源码调试 | C 的下一阶段，尚未验证 |
| RTT / FreeRTOS / SystemView / SWO | C 的路线图，分别验收 |

C 的基础验收为构建与主机检查通过、完整镜像回读匹配、CPU/Tick 正常、新串口日志及资源释放。源码调试阶段另需真实断点命中和匹配 ELF 的源行/调用栈，不能套用 Keil 的下载日志标志。详情见[能力矩阵](07-workflow-c-macos-jlink.md)与[实测记录](08-workflow-c-validation-2026-10-09.md)。
