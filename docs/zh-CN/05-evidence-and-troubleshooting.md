# 证据、日志与故障排查

[简体中文](05-evidence-and-troubleshooting.md) | [English](../en/05-evidence-and-troubleshooting.md) | [返回首页](../../README.md)

## 三层证据

| 层级 | 证明什么 | 典型标志 |
|---|---|---|
| 构建证据 | 当前源码能够生成目标文件 | `0 Error(s)` |
| 下载证据 | 当前镜像已写入并校验 | `Programming Done.`、`Verify OK.` |
| 运行证据 | 目标板执行了预期路径 | 断点命中、调用栈、寄存器、串口标志 |

三层证据不能互相替代。串口正常不代表断点正确，断点命中也不代表新镜像已下载。

## 串口日志

使用 [`templates/serial-watch.ps1`](../../templates/serial-watch.ps1) 跟踪新增内容：

```powershell
.\templates\serial-watch.ps1 -Path $env:SERIAL_LOG_PATH -Tail 30
```

串口工具必须启用追加写入和时间戳。下载前记录日志文件长度，下载后只读取新增内容，避免把旧启动信息误认为新固件运行证据。

## 常见问题

### 探针忙或无法连接

- 关闭已有 Keil Debug 和 VS Code Debug 会话。
- 检查 `UV4`、`pyocd`、`arm-none-eabi-gdb` 进程。
- 检查目标供电、SWDIO、SWCLK、GND、参考电压和 RESET。

### 下载耗时很长

不要设置过短超时。以 `Flash Load finished` 为结束标志，而不是以窗口是否短暂无响应判断。

### 启动断点不命中

- 启动函数只运行一次，先复位再继续。
- 确认符号存在于当前 AXF 且没有被优化掉。
- 冒烟测试改用周期性函数。

### QSPI 或外部执行区警告

pyOCD 的默认内存图可能不包含外部执行区。只有在硬件断点、源文件、实际命中和 `#0` 栈帧都正确时，才能把单纯内存图警告视为可接受。

### AXF 段警告

类似 `outside of ELF segments` 的警告通常不影响代码符号调试；如果读取特定 RAM 对象失败，再检查 scatter 文件、GDB 内存图和公开 getter。

### 源码与固件不一致

源码改变后不得跳过编译；AXF 改变后不得跳过下载。否则断点行号和板上代码会错位。

## 会话结束检查

```powershell
$p = Get-Process UV4,pyocd,arm-none-eabi-gdb -ErrorAction SilentlyContinue
if ($null -eq $p) { 'NO_DEBUG_PROCESSES' } else { $p }
```

生成的 `.log`、临时 `.gdb` 文件属于诊断证据，不应提交到 Git。

