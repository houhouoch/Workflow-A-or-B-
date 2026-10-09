# 流程 C 验收记录：2026-10-09

[简体中文](08-workflow-c-validation-2026-10-09.md) | [English](../en/08-workflow-c-validation-2026-10-09.md) | [流程 C](07-workflow-c-macos-jlink.md) | [首页](../../README.md)

## 范围与环境

Apple Silicon macOS、UDP3900 / STM32H750、J-Link（USB 枚举为 PLUS，硬件 V12.00）、SWD 10 MHz、UART7 115200。SEGGER 9.84、pyOCD 0.45.1、GNU Arm 15.2.1、STM32H7 DFP 2.7.0；VTref 3.257 V。用户在板测前确认输出 OFF、List 已停止。

工程基线提交为 `75f831a4c13a450245cbffcee422353150ac1515`，checkout 含未提交的 UI 和工具改动。镜像不是“该提交的干净构建”，本记录不宣称干净 checkout 可直接生成相同镜像。

## 分层结果

| 阶段 | 实测结果 |
|---|---|
| 架构检查 | 通过 |
| 主机测试 | `Host tests passed: 99 executable(s).` |
| Release 编译 | 成功；镜像 4225012 字节，CRC32 0x4BCC358A |
| 编程流程 | 0 字节擦除、0 字节写入；4227072 字节 / 1032 页 identical，跳过重复写入 |
| 烧录前备份 | 应用区 8376320 字节，已保存本地 |
| 全量回读 | 4225012 字节，长度与 SHA-256 均和 APP.BIN 一致 |
| 向量与 CPU | VTOR 0x90002000、CPU Running、Tick 递增 |
| UART 参数 | 运行中句柄为 115200 |
| 串口 | USB 重插后收到启动日志，45 秒观察窗口内一次启动 |
| DSP | 启动同步 9/9 完成，failed-action=0 |
| UI | startup gate ready、ready route=1 |
| 清理 | 采集退出，串口无残留占用 |

`4227072` 是工具报告的编程页范围，和实际镜像长度 `4225012` 不同；哈希比较使用实际镜像长度。

APP.BIN 与 READBACK.BIN 的 SHA-256：

```text
93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612
```

关键串口证据摘录（省略端口和个人路径）：

```text
[CAN] startup sync request=1 state=2 completed=9/9 failed-action=0
[WATCHDOG] critical task monitoring active
[UI] startup gate ready; DSP synchronized and protection clear
[UI] ready route=1 heap=1024 KiB backlight=100%
[HOST] capture completed
```

## 警告与限制

- 下载/复位工具出现 RESET pin 15、CPU could not be halted 警告；一次复位调用还出现核心识别警告。后续显式 reset/go、Cortex-M7 Running、完整回读与串口证据通过，但警告原因未解决，不能当作不存在。
- 初次 50 秒采集与后续 25 秒原始字节采集无数据；用户核对接线并重新插拔 J-Link USB 后恢复。VCOM 节点此前已存在，因而“存在节点”不是 UART 通路已验收的证明。
- 应用为 115200；Bootloader 仍为 460800，开头存在乱码。本次未更新 Bootloader。
- 45 秒无重复启动仅代表该观察窗口，不等于长期稳定性测试。
- 源码断点、单步、变量/调用栈、RTT、FreeRTOS 插件、SystemView、SWO 与 SEGGER 原生 QSPI loader 尚未验收。
- COMTool 关闭/重开竞态已在模拟串口中复现，尚未修复；最终串口验收使用独立只读脚本，不经过 COMTool。
- 固件、完整备份与原始日志保留本地，不随知识库上传。
