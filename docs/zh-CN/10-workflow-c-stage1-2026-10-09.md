# 流程 C 阶段一：任务与故障定位，2026-10-09

[简体中文](10-workflow-c-stage1-2026-10-09.md) | [English](../en/10-workflow-c-stage1-2026-10-09.md) | [流程 C](07-workflow-c-macos-jlink.md)

本阶段增加主机调试脚本，保留原 Release 固件，沿用输出 OFF、List 停止状态。没有开启输出，也没有发送 UART 控制命令。

## 已验证

- SEGGER 9.84 FreeRTOS 插件列出第一轮 9 个任务、后续 10 个任务（后续可见 SettingsTask）；任务名、优先级、PC、保存栈及应用调用者可读。
- 插件将部分 Ready/Blocked 任务显示为 Suspended。新增 GDB 命令读取内核链表、当前 TCB、事件及通知状态核对，不能直接采用插件标签。10 MHz 初测出现过任务名乱码；本次使用 1 MHz 验证，根因尚未确定。
- 硬件观察点捕获自然递增的 s_tick_ms：2041371 到 2041372；调用链包含 TIM17 回调和被中断的 CanTask。停止 PC 为 0x900309E4，真正写指令为 0x9003014C；观察点停止可能落在后续函数。
- 普通 TIM17 中断入口采集真实异常栈：EXC_RETURN=0xFFFFFFED、PSP=0x240046A8，FPU 扩展帧、惰性保存状态；104 字节快照正确还原 WatchdogTask_Heartbeat 的 PC=0x900EB738。JSON 明确标记 is_fault_exception=false。
- 正常任务现场采集 CFSR/HFSR 为零，解析器拒绝把普通任务栈当成异常栈。11 项离线解析测试及架构检查通过。
- 普通 Release 构建通过：4,225,012 字节、CRC32 0x4BCC358A；本轮板上全量回读从 0x90002000 开始，与 APP.BIN 的 SHA-256 相同：93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612。
- 最终 CPU Running、Tick 增长，CFSR/HFSR 为零；断点、观察点和后端已清理，IWDG 冻结寄存器最终读回 0x00000000。

## 可复用工具

工具留在工程仓库，不复制到本知识库。提交 [e4500cb8](https://github.com/houhouoch/UDP_3900_CMAKE/commit/e4500cb8) 包含 [阶段一说明](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/docs/JLINK_STAGE1_DIAGNOSTICS.md)、[连接模板](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/tools/programming/jlink_stage1.gdb.example)、[任务与快照命令](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/tools/programming/jlink_diagnostics.gdb)、[离线解析器](https://github.com/houhouoch/UDP_3900_CMAKE/blob/e4500cb8/tools/macos/decode_fault_snapshot.py)。工程仓库为私有，需要权限。

加载匹配 ELF 后执行模板。使用当前 GDB 线程编号切换任务；继续前切回真实运行线程。遇到真实 HardFault 时在 *HardFault_Handler 第一条指令捕获，导出寄存器与内部 SRAM 栈，再用匹配 ELF 离线解析。快照只读，不自动触发故障。退出执行 udp3900-debug-finish。

## 未完成与限制

- 本轮没有真实 HardFault，普通 IRQ 栈验证不代表 HardFault 实机触发验收。栈损坏、FPU 扩展布局及地址有效位已离线覆盖；未来真实故障仍需核对现场。跨复位故障记录属于后续固件工作。
- 部分变量被 -Os 优化；RTOS 任务入口以上仍可能遇到哨兵重复帧。任意处理函数内部的 LR/MSP 可能已改变，必须在异常入口捕获。
- 本轮恢复后 VCOM 两次打开并复位均没有字节；串口恢复待 USB 重新插拔复验。此前串口通过不能替代本轮串口结果。串口已释放。
- RTT、SystemView、SWO 尚未接入；本阶段没有改固件运行逻辑、没有重新烧录、没有进行带载或长期稳定性验收。板上镜像包含此前未提交改动，工具提交号不是镜像的完整重现依据。

官方参考：[SEGGER GDB Server RTOS 参数](https://kb.segger.com/J-Link_GDB_Server#-rtos)、[ST Cortex-M7 PM0253](https://www.st.com/resource/en/programming_manual/DM00237416.pdf)。
