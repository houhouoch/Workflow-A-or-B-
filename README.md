# 嵌入式命令行调试流程 A / B / C

[简体中文](README.md) | [English](README.en.md)

这是一套可直接作为 **Obsidian Vault** 打开的嵌入式调试知识库，也完全兼容 GitHub Markdown。

它保留两条 Windows 调试链路，并新增 Apple Silicon macOS 工作流；各流程分别记录验收范围：

- **流程 A：MDK / uVision 调试流程**
- **流程 B：VS Code 调试流程**
- **流程 C：macOS + CMake/GCC + J-Link**，编译下载与串口已验证，源码调试建设中。

流程 C 通过 CMake/GCC 编译、pyOCD 经 SEGGER 库操作 J-Link 下载，再进行全量回读和 VCOM 串口验收。SEGGER 原生 GDB 调试、RTT 和实时跟踪仍待验证。

流程 A 在 Keil/uVision 体系内完成调试；流程 B 在 VS Code 中通过 CMSIS-DAP、pyOCD 和 GDB 调试。两套流程仍共用 Keil MDK 完成编译和下载，VS Code 流程不是 GCC 重新编译流程。

```mermaid
flowchart LR
    A[修改代码] --> B[Keil MDK 编译]
    B --> C[Keil MDK 下载与校验]
    C --> D{选择调试后端}
    D --> E[流程 A: MDK / uVision]
    D --> F[流程 B: VS Code]
    E --> G[断点与表达式证据]
    F --> H[调用栈与寄存器证据]
    G --> I[串口运行证据]
    H --> I
    A --> J[流程 C: macOS CMake/GCC]
    J --> K[pyOCD + J-Link 下载与回读]
    K --> L[VCOM 启动日志验收]
```

## 快速导航

1. [架构与选择](docs/zh-CN/01-architecture.md)
2. [公共环境准备](docs/zh-CN/02-shared-setup.md)
3. [流程 A：MDK / uVision 调试](docs/zh-CN/03-workflow-a-keil-uvsc.md)
4. [流程 B：VS Code 调试](docs/zh-CN/04-workflow-b-cmsis-gdb.md)
5. [证据、日志与故障排查](docs/zh-CN/05-evidence-and-troubleshooting.md)
6. [AI 自动化契约与新电脑清单](docs/zh-CN/06-ai-automation-and-checklist.md)
7. [流程 C：macOS + CMake/GCC + J-Link](docs/zh-CN/07-workflow-c-macos-jlink.md)
8. [流程 C 实测记录：2026-10-09](docs/zh-CN/08-workflow-c-validation-2026-10-09.md)

## 使用方式

### Obsidian

选择 **Open folder as vault**，打开本仓库根目录即可。

### GitHub

从本页按导航顺序阅读。所有链接均为标准相对链接，不依赖 Obsidian 插件。

> [!IMPORTANT]
> CMSIS-DAP 或 J-Link 的调试连接由一个后端进程管理，客户端通过该后端连接，避免多个后端争用探针。J-Link 的 SWD 与 VCOM 是独立接口，可以同时使用；同一串口只能有一个采集工具占用。
