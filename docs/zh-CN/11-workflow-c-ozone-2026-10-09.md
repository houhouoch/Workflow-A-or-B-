# 流程 C：Ozone 图形调试实例

2026-10-09 在 macOS Apple Silicon 安装 Ozone V3.50b，连接现有 J-Link 与 STM32H750XB，以 1 MHz SWD 附加板上 Release 固件。配置与操作记录已提交到工程仓库 [9df805b2](https://github.com/houhouoch/UDP_3900_CMAKE/commit/9df805b2)。

使用工程仓库的 [Ozone 工程](https://github.com/houhouoch/UDP_3900_CMAKE/blob/9df805b2/tools/programming/udp3900_ozone.jdebug)和[完整步骤](https://github.com/houhouoch/UDP_3900_CMAKE/blob/9df805b2/docs/OZONE_QUICKSTART.md)。本机 Finder 可双击 `tools/macos/打开Ozone.command`，然后按 F5 附加。连接前确认输出 OFF、List 停止，并关闭其他 SWD 后端。工程使用 ReleaseSymbols ELF、Cortex-M7F 与 STM32H750x SVD、当前维护的 FreeRTOS Cortex-M 插件；限定硬件断点，跳过复位与下载。更换探针或电脑需更新项目中的序列号和 SVD 路径。

## 真实实例：心跳来自哪个任务

在 Console 中执行 `Debug.Halt();`，等待暂停完成，再执行 `Script.Exec("DemoHeartbeat");`。实机命中 `WatchdogTask_Heartbeat` 第 175 行；Local Data 的 `client=0` 对应 CAN 任务。Call Stack 显示 `CanTask_Run` 调用心跳；PC 为 `0x900EB738`，SP 为 `0x24004710`。F12 单步后 PC 为 `0x900EB74A`。本次 FreeRTOS 视图显示 9 个任务，深层入口栈与 Suspended 状态仍需结合阶段一的诊断边界解释；Run Count 为零不是未执行的证据。

Registers 视图可展开 CPU 的 PC/SP/LR 与 Peripherals 下的 UART7、GPIO、定时器字段。实读 UART7 BRR=`0x412`，CR1=`0x1D`；CFSR/HFSR 均为零。BRR 单独不能证明实际波特率，仍需核对 UART 时钟及过采样。Watch 预置心跳计数、RTOS tick、任务数量及故障寄存器。Release 优化、变量作用域或尚未赋值会使部分局部变量显示 `<outofscope>`。

`Script.Exec("DemoResume");` 清除本实例断点并继续运行。完整收尾先暂停并等待停止，再执行 `Script.Exec("DemoFinish");`，恢复会话保存的 IWDG 冻结值并继续，之后 Shift+F5 关闭会话。强制退出或断线不保证恢复；本次原值为 `0x00040000`，收尾恢复原值，CPU Running，心跳计数继续增加。

## 证据与边界

本次完整回读 APP 起始地址 `0x90002000` 的 4,225,012 字节，与 ELF 机器码及 APP.BIN 一致，SHA-256=`93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612`。实测附加、断点、局部变量、寄存器、调用栈、任务列表、单步、解除断点与恢复运行；没有改固件、烧录、开启物理输出、触发 HardFault 或接入 RTT。串口与 DSP/物理输出验收不因图形调试通过而升级。

Ozone 官方 `127.0.0.1:19200` 自动化接口可以执行 Console 命令并返回结果。本次通过该接口操作，再在图形窗口核对结果。这样 AI 可以帮助设置停点、采集现场、分析变量与寄存器，用户同时在 Ozone 查看。每次新固件仍需重新核对 ELF，不能沿用旧文件名作为匹配证明。

官方参考：[Ozone 手册](https://www.segger.com/downloads/jlink/UM08025_Ozone.pdf)、[Bootloader 调试](https://kb.segger.com/Debug_on_a_Target_with_Bootloader)。
