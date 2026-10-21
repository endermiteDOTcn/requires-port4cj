# 移植与项目组织说明

## 参考来源

移植基于 [unshiftio/requires-port](https://github.com/unshiftio/requires-port) 的
`07e8e8298f892243734d695e884a78a56e3dccb9` 提交（`[doc] Fix CI badge URL`）。
上游 `package.json` 中的版本号为 1.0.0，源码快照保存在 `requires-port/` 目录中。

仓颉组织方式参考：

1. [Cangjie-TPC/TPC-Resource](https://gitcode.com/Cangjie-TPC/TPC-Resource)：
   用于了解社区三方库分类，以及模板、贡献说明和规范的入口。
2. [Cangjie-TPC/compare-versions-cj](https://gitcode.com/Cangjie-TPC/compare-versions-cj)：
   同样参考 npm 函数库，公开 README 展示了 `src/`、`doc/feature_api.md`、
   `cjpm.toml`、README、CHANGELOG 和 LICENSE 的布局，以及直接导入函数的用法。
3. [仓颉包和模块管理](https://cj-docs.gitcode.com/zh/1.2.0/dev-guide/source_zh_cn/package/package_module_management.html)：
   用于了解目录、包和模块的对应关系。本项目使用仓颉 1.0.5 SDK 构建。

## 目录职责

| 位置 | 职责与学习要点 |
| --- | --- |
| `cjpm.toml` | 定义模块名、SDK 版本、输出类型与依赖；本项目输出静态库 |
| `src/` | 模块根包 `requires_port`；一个 `.cj` 文件实现三个函数重载 |
| `src/*_test.cj` | 与源码同包的标准单元测试，由 `cjpm test` 编译和执行 |
| `examples/basic/` | 独立消费端模块，通过相对路径依赖根库，检验公共导入与链接 |
| `doc/feature_api.md` | 公共签名、参数、返回值和示例 |
| `doc/porting.md` | 上游来源、参考结构和语言差异 |
| `requires-port/` | 原始 JavaScript 代码和 MIT 许可，供学习与对照 |
| `scripts/` | 上游行为对照脚本，通过 Node.js 生成期望值并运行仓颉实现 |
| `target/` | 构建产物及对照脚本生成内容，由 `.gitignore` 排除 |

仓颉的包与目录对应。项目使用根包 `requires_port`，在 `src/requires_port.cj` 中定义公共函数，
通过根目录的 `cjpm.toml` 配置模块与依赖。

示例是 `examples/basic/` 下的独立模块，通过 `path` 依赖引入根库。
在根目录执行 `cjpm test` 运行库的测试，在 `examples/basic/` 下执行 `cjpm run` 运行示例。

## 从 JavaScript 到仓颉

| 上游写法 | 仓颉实现 |
| --- | --- |
| 导出一个函数 | 导出 `public func required`，调用方通过 `import` 引入 |
| Number 或 String | `Int64`、`Float64`、`String` 三个重载 |
| `protocol.split(':')[0]` | 截取首个冒号之前的文本，保留空协议前缀 |
| `port = +port` | 私有字符串转换函数，按 JavaScript 数字字符串语法处理 |
| `if (!port)` | 零值或 NaN 返回 `false` |
| `switch (protocol)` | `match` 共享协议分支 |
| Mocha + assume | 标准库 `std.unittest` 与 `@Test`、`@TestCase`、`@Expect` |

协议名称保持大小写敏感，保留 `gopher` 默认端口 70，未知协议的非零且非 NaN 数字返回 `true`。
负数、小数、大于 65535 的数字和无穷值沿用上游的端口判断规则。

字符串转换先识别 JavaScript 数字语法，再调用 `Float64.tryParse` 处理十进制数字；
进制前缀、`Infinity` 和 ECMAScript 空白分别处理。非法字符串转换为 NaN，
端口判断返回 `false`。

## 验证方法

1. `cjpm build`：验证静态库编译。
2. `cjpm test`：覆盖上游测试的全部协议/端口行为，并加入空协议、大小写、非法字符串、
   Unicode 空白、不同进制、NaN、无穷、小数和越界数字的回归测试。
3. 在 `examples/basic` 下执行 `cjpm run`：验证消费端通过公开接口使用库。
4. `node scripts/check_upstream.cjs`：用上游函数生成期望值，对照 11,970 个输入组合的仓颉结果。

## 许可证

沿用上游 MIT License，在根目录保留原始许可与版权，并在衍生源码和测试中注明来源。
