# 架构与流程选择

[简体中文](01-architecture.md) | [English](../en/01-architecture.md) | [返回首页](../../README.md)

## 关键结论

这不是“两套编译器”，而是“两套调试后端”。

| 阶段 | 两套流程共同使用的工具 |
|---|---|
| 编译、链接、生成 AXF | Keil MDK `UV4.exe -b` 或 `-r` |
| 下载、校验 | Keil MDK `UV4.exe -f` |
| 流程 A 调试 | `UVSC64.dll` 控制独立 uVision 会话 |
| 流程 B 调试 | CMSIS-DAP + pyOCD + `arm-none-eabi-gdb` |
| 运行证据 | 串口日志，可选但强烈建议 |

流程 B 中的 GDB 只读取 MDK 生成的 AXF 符号并控制目标板，不负责重新编译固件，也不应该再次下载 QSPI 固件。

## 如何选择

| 需求 | 推荐流程 |
|---|---|
| 完全复用 Keil 工程、器件和调试配置 | A：UVSC |
| 使用 uVision 原生表达式和调试命令 | A：UVSC |
| 以文本方式获取调用栈、参数、局部变量、PC/LR/SP | B：GDB |
| 与 VS Code 调试界面兼容 | B：GDB |
| 排查 Keil 独有的初始化问题 | A：UVSC |
| 快速做命令行硬件断点冒烟测试 | B：GDB |

## 共同完成条件

不能因为进程返回码为零就宣布成功，至少需要：

1. 编译日志为 `0 Error(s)`。
2. 下载日志同时出现 `Programming Done.`、`Verify OK.`、`Flash Load finished`。
3. 调试日志证明断点是由执行命中，而不是手动暂停、复位或异常停止。
4. AXF 中的源位置、目标板实际 PC 和请求的断点符号一致。
5. 调试结束后释放探针。

