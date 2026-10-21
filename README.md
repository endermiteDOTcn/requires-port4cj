# requires-port4cj

`requires-port` 的纯仓颉移植，用于判断 URL 中是否需要显式保留给定端口。上游为
[unshiftio/requires-port](https://github.com/unshiftio/requires-port)，移植版本为 **1.0.0**。

例如，`http:80` 可以省略端口，`http:8080` 需要保留端口。

## 项目特性

- 提供 `required(port, protocol): Bool`，支持 `Int64`、`Float64` 和 `String` 端口。
- 支持 `http`、`https`、`ws`、`wss`、`ftp`、`gopher`、`file`，保留上游的未知协议处理规则。
- 使用仓颉标准库实现。

## 项目结构

```text
requires-port4cj/
├── cjpm.toml                       # 仓颉模块配置，包名 requires_port
├── src/
│   ├── requires_port.cj            # 公共接口及私有转换函数
│   └── requires_port_test.cj       # 仓颉标准单元测试
├── examples/basic/                 # 独立的消费端模块，演示 path 依赖
│   ├── cjpm.toml
│   └── src/main.cj
├── doc/
│   ├── feature_api.md              # 接口与参数说明
│   └── porting.md                  # 参考仓库、结构说明、移植决策
├── scripts/check_upstream.cjs      # 对照上游 JavaScript 的验证脚本
├── requires-port/                 # 保留的上游源码、测试和许可证
├── CHANGELOG.md
├── LICENSE
└── README.md
```

组织方式参考 [Cangjie-TPC/compare-versions-cj](https://gitcode.com/Cangjie-TPC/compare-versions-cj) 的
`src/`、`doc/feature_api.md`、`cjpm.toml`、README、CHANGELOG 和 LICENSE 布局；
测试采用当前 SDK 支持的同包 `_test.cj` 方式，示例放在独立模块中。
更详细的对应关系见 [移植说明](doc/porting.md)。

## 环境要求

- 仓颉 SDK **1.0.5**，`cjc` 和 `cjpm` 可用，已加载 SDK 环境。
- 验证环境：Windows x86_64、Cangjie 1.0.5。
- 上游行为对照脚本使用 Node.js。

## 编译与测试

在本仓库根目录执行：

```shell
cjpm build
cjpm test
```

运行独立示例：

```shell
cd examples/basic
cjpm run
```

输出：

```text
true
false
false
false
```

在仓库根目录运行上游行为对照：

```shell
node scripts/check_upstream.cjs
```

脚本调用保留的上游 `requires-port/index.js` 计算期望值，然后生成并运行仓颉消费端。
生成内容位于 `target/upstream-compat/` 中；包含协议、进制、Unicode 空白、非法输入、
浮点边界和固定种子生成的数字字符串组合，共 11,970 个用例。结果一致时输出通过数量，
出现差异时输出对应输入并以失败状态退出。

## 引入与使用

在消费端项目的 `cjpm.toml` 中添加本地依赖（路径相对于消费端的配置文件）：

```toml
[dependencies]
requires_port = { path = "../requires-port4cj" }
```

```cangjie
import requires_port.required

main() {
    println(required("8080", "http")) // true
    println(required(80, "http")) // false
    println(required("443", "https://example.com")) // false
}
```

仓库名使用 `requires-port4cj`，仓颉模块名使用合法标识符 `requires_port`；
`import` 中使用模块名。公共函数 `required` 位于模块根包。

## 接口行为

| 协议 | 可以省略的默认端口 |
| --- | --- |
| `http`、`ws` | `80` |
| `https`、`wss` | `443` |
| `ftp` | `21` |
| `gopher` | `70` |
| `file` | 任意端口均返回 `false` |
| 其他协议 | 非零且非 NaN 的端口返回 `true` |

协议取第一个 `:` 之前的原始文本进行匹配，保留大小写和首尾空白。
空端口、零端口、NaN 和无法转换为数字的字符串返回 `false`。
字符串支持十进制、小数、科学计数法、`0x`/`0o`/`0b` 前缀及 ECMAScript 首尾空白。
负数、超出 `65535` 的数字和无穷值沿用上游行为。完整约定见 [API 文档](doc/feature_api.md)。

## 开源协议与贡献

采用 [MIT License](LICENSE)，保留上游版权和许可证。上游目录用于溯源和对照验证；
仓颉库的源码入口为根目录的 `src/`。修改接口行为时请同时更新单元测试和文档，
并运行上游对照脚本检查兼容性。
