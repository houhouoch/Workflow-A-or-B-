# 流程 C 源码调试验收：2026-10-09

[简体中文](09-workflow-c-source-debug-2026-10-09.md) | [English](../en/09-workflow-c-source-debug-2026-10-09.md) | [流程 C](07-workflow-c-macos-jlink.md) | [首页](../../README.md)

## 结果与范围

在同一 UDP3900 / STM32H750、Apple Silicon macOS 和 J-Link 上，SEGGER 9.84 原生 GDB Server + GNU Arm GDB 16.3 完成基础源码调试。沿用用户已确认的输出 OFF、List 停止状态。未开启输出，未发送串口命令。

独立 `ReleaseSymbols` 配置使用 `-Os -g3`。其 4225012 字节机器码与 Release、板上 pyOCD 完整回读一致，SHA-256 为 `93b3b78c1b80e78cf75a3687923d6ec8eaeeaff72d64d40d848ff48960038612`，因此本次无需重新编程。镜像仍来自含未提交 UI/工具改动的 checkout，提交号单独不能重现该镜像。

| 验收项 | 实际证据 |
|---|---|
| 周期函数硬件断点 | WatchdogTask_Run 第 115 行，PC=0x900eb63e；执行 continue 后命中 |
| 参数与调用者 | WatchdogTask_Heartbeat 第 175 行，client=WATCHDOG_TASK_CLIENT_CAN；调用者 CanTask_Run 第 3473 行 |
| 局部变量 | observed_mask=15，monitoring_started=1，health_window_ticks=3000 |
| 函数调用栈 | PlatformWatchdog_Refresh 第 33 行，调用者 WatchdogTask_Run 第 115 行 |
| 指令单步 | 进入 PlatformWatchdog_Refresh，PC=0x900eb790 |
| 源码单步 | 心跳函数由第 175 行推进到第 180 行，PC=0x900eb74a |
| 恢复 | 删除断点、恢复原冻结寄存器、go/detach 后 CPU Running；Tick 继续增长 |
| 串口复验 | 先采集再软件复位；115200，45 秒一次启动，DSP 9/9、UI ready，无 heartbeat missing/reset pending |
| 清理 | GDB Server 退出，串口采集退出；2331 无监听，同一串口无残留占用 |
| 最终构建 | 普通 Release 重建通过，镜像哈希保持不变；架构与内存布局检查通过 |

## 可复用入口

板级实现见工程的 [ReleaseSymbols 配置](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/CMakePresets.json)、[macOS 构建脚本](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/tools/macos/build_cmake.sh)、[GDB 模板](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/tools/programming/jlink_source_debug.gdb.example)和[完整说明](https://github.com/houhouoch/UDP_3900_CMAKE/blob/a021d4ce/docs/CMAKE_GCC_WORKFLOW.md)。工程仓库为私有，需要访问权限；工具改动提交 `a021d4ce`。这些文件不复制到本知识库。

先保存 Release 镜像、构建 ReleaseSymbols，再用完整回读核对机器码。匹配后启动原生后端，GDB 只加载 ELF 符号：

```bash
tools/macos/build_cmake.sh --build-type ReleaseSymbols
"$SEGGER_RUNTIME_DIR/JLinkGDBServerCLExe"   -select "USB=$JLINK_UID" -device STM32H750XB -if SWD -speed 10000   -endian little -port 2331 -swoport 2332 -telnetport 2333   -localhostonly 1 -noreset -noir -nohalt -nogui -singlerun
```

另一终端，从工程根目录执行：

```bash
arm-none-eabi-gdb -q build/ReleaseSymbols/UDP3900.elf   -x tools/programming/jlink_source_debug.gdb.example
```

模板使用 `hbreak`，关闭 Flash Breakpoints，保存并设置停核时 IWDG 冻结位。在真实命中后使用 `info args`、`info locals`、`bt 5`、`step` 或 `stepi`。退出前执行 `udp3900-debug-finish`，清理断点、恢复冻结寄存器并运行/分离；失败时也必须显式清理。GDB Server 与 pyOCD 后端不能争用同一调试连接。

## 限制与下一步

- `-Os` 优化会使 now_ticks、flags 等变量显示 `<optimized out>`，本次未验证所有变量都可观察。
- 真实函数与调用者可回溯；FreeRTOS 任务入口以上出现哨兵/重复帧并停止。这不证明应用栈损坏，也不代表全任务栈或 RTOS 插件已验收。
- 原生 GDB 的批量外部 QSPI 读取失败；减小包大小后仍在 0x90002800 失败。完整镜像校验由 pyOCD 完成，不宣称原生批量读取已修复。
- 本次没有验证 GDB `load`、SEGGER 原生 QSPI loader、观察点、HardFault 现场、FreeRTOS 插件、RTT、SystemView 或 SWO。
- 应用 115200，未更新的 Bootloader 460800；开头可能乱码。45 秒窗口不能代替长期稳定性验收。
- 本次无产品逻辑改动；没有重复运行完整主机测试，沿用同日已通过的 99 项记录。新配置分别完成 ReleaseSymbols/Release 构建、架构检查和实机调试。

下一项优先验证 FreeRTOS 插件与任务栈边界，再验证观察点和异常现场。[SEGGER GDB Server 官方参考](https://kb.segger.com/J-Link_GDB_Server)。
