# SDK 兼容性验证

本报告区分 2026-11-14 的完整历史矩阵与 2026-11-16 的四环境端点复验，两轮均未发现需要修改生产逻辑的 SDK 兼容性问题。本轮未重新执行中间四个 SDK 的完整矩阵。日期、源码摘要及结果见 [机器结果](validation-results.json)。

## 历史矩阵：2026-11-14

| SDK | Windows x86_64 | Linux x86_64 / WSL2 |
| --- | --- | --- |
| 1.0.5 | 通过 | 通过 |
| 1.1.0 | 通过 | 通过 |
| 1.1.3 | 通过 | 通过 |
| 1.1.5 | 通过 | 通过 |
| 1.2.0 | 通过 | 通过 |
| 1.2.1 | 通过 | 通过 |

Windows 为 10.0.28000.0、PowerShell 7.6.9；Linux 为 Ubuntu 26.04.1 / WSL2。两平台均使用 Node.js 22.20.0。编译目标分别为 `x86_64-w64-mingw32` 和 `x86_64-unknown-linux-gnu`。各 SDK 使用独立源码与构建目录，检查工具版本、路径并清理缓存。

历史基线为本仓 `5f3cf14a7a4e440e2e5b2009c2059eefb182a067`、集成库 `8181a1589158bbe8a8a45e12c5acf6f324deaf93`，最终矩阵另含种子入口、测试字符串和 URL 测试及注释改动，不能仅用基线提交代表完整受测源码。

每个环境的 release/debug 静态库构建、9 个原生单测及 `examples/basic` 均通过，无失败、错误或跳过。示例输出均为 `true`、`false`、`false`、`false`。独立消费端直接导入两库，验证 URL 对 port 的传递依赖和公开行为，release/debug 均通过。

两库历史共 **578 个成功命令步骤**：基线 266、扩展 276、最终 URL 注释后复验 36；其中包含 6 个 `--help` 命令，578 不是测试用例数。覆盖率、lint、打包和后续复验不计入该值。

八种子为 `0, 1, 42, 24301, 20261021, 20261114, 2147483648, 4294967295`。每种子比较 11,970 次，每环境 95,760 次，12 个环境共 **1,149,120 次 port 比较**；连同 URL 的 503,040 次，两库共 **1,652,160 次比较执行，零差异**。

这些是 release 下的比较执行次数，固定案例重复且生成输入可能重叠，不代表唯一样本数；八种子差分未在 debug 下执行。同一种子的生成源码摘要在 12 个环境一致，八种子摘要互不相同。摘要包含实际输入及原始 JavaScript 计算的期望值。

## 本轮复验：2026-11-16

本轮基于 main `b60e58e06f2d2de486a0d1b9666ae4fd7e72b584`，URL 集成库 main 为 `532370817fb20873685f3e89b209a83e1d459bcc`。源码清单与摘要用于绑定实际受测工作区；`cjc-version = "1.0.5"` 未改。

| 当前源码端点复验 | SDK 1.0.5 | SDK 1.2.1 |
| --- | --- | --- |
| Windows x86_64 | 通过 | 通过 |
| Linux x86_64 / WSL2 | 通过 | 通过 |

四个环境均通过两库 release/debug 构建、原生单测（port 9、URL 26）、示例和独立消费端。共 154 个成功命令步骤，另验证 112 次预期的非法种子拒绝。显式八种子对照为 port **383,040 次**、URL 167,680 次，两库共 **550,720 次比较执行，零差异**；不将默认种子和前导零补充运行计入这个比较次数。

生产实现保持不变。测试中的 `://www.google.com` 后缀使用 `://localhost`，函数只按冒号前的协议判定默认端口，断言语义不变。

对照脚本只在入口接受十进制数字串，允许前导零，并限制为 0 至 4294967295；未设置时默认 `20261021`。空串、空白、负数、小数和超范围值无效。随机算法、生成规则及回放实现保持不变；本轮全部八种子的生成源码 SHA-256 与历史 12 环境同种子摘要一致。

四个环境均确认未设置种子与显式 `20261021` 的语料一致；Windows / SDK 1.2.1 另确认 `00042` 与 `42` 一致。非法输入在启动编译前拒绝。历史受测归档中的 46 个源码、清单、示例及 oracle 输入与本轮比对，其中 44 个输入文件的内容逐字节一致，仅两库种子脚本的入口校验改变。

2026-11-16 已在 Windows / SDK 1.2.1 的独立快照执行 `cjpm test --coverage` 和 `cjcov`，9 个原生单测通过。外部原始记录为 `packaging-work/local-checks/summary.json`，汇总见本报告同目录机器结果。

| 生产源码 | 命中/可执行行 | 行覆盖率 |
| --- | --- | --- |
| `src/requires_port.cj` | 68/68 | 100.00% |

统计排除 `_test.cj`，只计算本库可执行生产行；不是分支覆盖率，也未将差分次数计入覆盖率。原生测试直接调用真实实现；对照程序从保留的原始 JavaScript 实现取得期望值后导入本库比较，没有复制仓颉业务算法。上游版本、锁定提交和适配范围见 [移植说明](porting.md)。

## 复现与保留结果

加载待测 SDK，在本仓根目录运行 `cjc -v`、`cjpm -v`、`cjpm clean`、`cjpm build`、`cjpm test --no-color --no-progress`，再运行 `cjpm build -g`、`cjpm test -g --no-color --no-progress`。在 `examples/basic` 清理后分别执行 `cjpm run`、`cjpm run -g`。每换 SDK 使用新目录或清理库、示例和生成程序的缓存。

八种子命令在本仓根目录的单独终端执行。每次保留日志、生成源码及其 SHA-256，避免后一次覆盖 `target/upstream-compat/src/main.cj`。

```powershell
New-Item -ItemType Directory -Force target/seed-results | Out-Null
foreach ($seed in @('0','1','42','24301','20261021','20261114','2147483648','4294967295')) {
    $env:UPSTREAM_SEED = $seed
    node scripts/check_upstream.cjs *> "target/seed-results/seed-$seed.log"
    if ($LASTEXITCODE -ne 0) { throw "seed $seed failed" }
    $source = "target/seed-results/seed-$seed.cj"
    Copy-Item -LiteralPath target/upstream-compat/src/main.cj -Destination $source
    (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash.ToLower() |
        Set-Content -Encoding ascii "target/seed-results/seed-$seed.sha256"
}
$env:UPSTREAM_SEED = $null
```

```sh
set -e
mkdir -p target/seed-results
for seed in 0 1 42 24301 20261021 20261114 2147483648 4294967295; do
    UPSTREAM_SEED="$seed" node scripts/check_upstream.cjs > "target/seed-results/seed-$seed.log" 2>&1
    cp target/upstream-compat/src/main.cj "target/seed-results/seed-$seed.cj"
    sha256sum "target/seed-results/seed-$seed.cj" > "target/seed-results/seed-$seed.sha256"
done
```

每次日志应包含 `Upstream compatibility: 11970 cases passed`。未设置 `UPSTREAM_SEED` 时直接运行 `node scripts/check_upstream.cjs` 可复验默认种子；无效种子应在启动编译前失败。生成源码摘要与日志摘要用途不同，语料比较使用前者。

行覆盖率可用 `cjpm clean`、`cjpm test --coverage --no-color --no-progress`、`cjcov --root . --source src --output target/coverage --json --html-details` 复现，运行 `cjcov` 前先创建输出目录。统计时只取 `src/requires_port.cj`。

Windows 单测框架使用本机 TCP；若执行环境禁止该通信并报 `SocketException 10013`，需要在允许本机通信的环境重跑，不能将该次失败计为库测试通过。

## 打包与验证范围

2026-11-14 的最终源码包已在 SDK 1.2.1 下通过默认 `cjpm bundle`，未跳过测试或 lint；解包后的构建、9 个单测、独立示例和 11,970 次默认种子比较均通过。该历史结果只绑定当时的包与源码摘要，不代表本轮最终包已验收。

本轮须在源码和文档冻结后重新打包，并核对包内容、包 SHA-256 及解包后的构建、单测、示例和默认种子对照。最终包的验证结果、命令日志和哈希由外部收据及 PR 正文记录，避免文档包含其所在包的自引用摘要。

静态检查需保留真实诊断等级；默认 bundle 通过不能表述为零诊断。URL 集成库当前仍使用本地路径依赖，其中心仓打包约束不影响本库已测的源码调用行为；发布前须使用真实包身份并重新验证依赖消费。本轮未执行中心仓发布。

结论限于列出的 SDK 下重新从源码构建；Linux 证据来自 WSL2。未实测 macOS、ARM、OpenHarmony/HarmonyOS 设备或跨 SDK 产物混合链接，未完成中心仓服务端验收。
