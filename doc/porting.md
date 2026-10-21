# 移植与项目组织说明

## 参考来源

本次移植输入为仓库中的 `requires-port/`，其 `package.json` 声明版本为 1.0.0，
上游地址为 <https://github.com/unshiftio/requires-port>。本地上游检出的提交为
`07e8e8298f892243734d695e884a78a56e3dccb9`（`[doc] Fix CI badge URL`），工作区无修改。
在本移植仓库中以普通文件保留该源码快照，不使用子模块；版本号取自上游 `package.json`，
不将其视为已验证的发布标签。

仓颉组织方式参考：

1. [Cangjie-TPC/TPC-Resource](https://gitcode.com/Cangjie-TPC/TPC-Resource)：
   用于了解社区三方库分类，以及模板、贡献说明和规范的入口。
2. [Cangjie-TPC/compare-versions-cj](https://gitcode.com/Cangjie-TPC/compare-versions-cj)：
   同样参考 npm 函数库，公开 README 展示了 `src/`、`doc/feature_api.md`、
   `cjpm.toml`、README、CHANGELOG 和 LICENSE 的布局，以及直接导入函数的用法。
3. [仓颉包和模块管理](https://cj-docs.gitcode.com/zh/1.2.0/dev-guide/source_zh_cn/package/package_module_management.html)：
   用于了解目录、包和模块的对应关系；具体编译及配置以本地 1.0.5 SDK 的实际结果为准。

参考的是可读取的项目结构与说明，没有复制其他仓库的源码。
TPC-Resource 的模板和规范文件页面未能完整读取，因此本项目没有宣称已满足该组织全部准入规范。

## 为什么这样分目录

| 位置 | 职责与学习要点 |
| --- | --- |
| `cjpm.toml` | 定义模块名、SDK 版本、输出类型与依赖；本项目输出静态库 |
| `src/` | 模块根包 `requires_port`；一个 `.cj` 文件实现三个函数重载 |
| `src/*_test.cj` | 与源码同包的标准单元测试，由 `cjpm test` 编译和执行 |
| `examples/basic/` | 独立消费端模块，通过相对路径依赖根库，检验公共导入与链接 |
| `doc/feature_api.md` | 公共签名、参数、返回值、边界和例子 |
| `doc/porting.md` | 上游来源、参考结构和语言差异 |
| `requires-port/` | 原始 JavaScript 代码和 MIT 许可，供学习与对照 |
| `scripts/` | 可选开发工具；Node.js 不参与仓颉库的构建或运行 |
| `target/` | 构建产物及对照脚本生成内容，不提交到版本库 |

仓颉的包与目录对应；当前 API 很小，用一个根包即可。以后需要子包时再添加子目录，
不照搬 npm 的 `module.exports`、`package.json` 或 `node_modules`。

示例不属于根库的 `src/`，不会把 `main` 入口混入静态库。根目录 `cjpm test` 执行根库测试，
示例需进入 `examples/basic` 后单独运行；本项目无需为一个小型库引入 workspace。

## 从 JavaScript 到仓颉

| 上游写法 | 仓颉实现 |
| --- | --- |
| 导出一个函数 | 导出 `public func required`，调用方通过 `import` 引入 |
| Number 或 String | `Int64`、`Float64`、`String` 三个重载 |
| `protocol.split(':')[0]` | 找到首个冒号，保留其前缀；避免仓颉 `split` 丢弃空片段的差异 |
| `port = +port` | 私有字符串转换函数，限制为 JavaScript 数字字符串语法 |
| `if (!port)` | 零值或 NaN 返回 `false` |
| `switch (protocol)` | `match` 共享协议分支 |
| Mocha + assume | 标准库 `std.unittest` 与 `@Test`、`@TestCase`、`@Expect` |

协议名称保持大小写敏感，保留 `gopher` 默认端口 70，未知协议的非零数字返回 `true`。
没有额外增加端口范围校验，因为那会改变上游语义。

字符串转换需要单独处理：仓颉 `Float64.tryParse` 接受 `inf` 等上游不接受的输入，
所以先限制语法，再调用标准转换；进制前缀和 ECMAScript 空白单独处理。
对外只保证端口判断语义，不提供通用 JavaScript 动态类型转换。

## 验证方法

1. `cjpm build`：验证静态库编译。
2. `cjpm test`：覆盖上游测试的全部协议/端口行为，并加入空协议、大小写、非法字符串、
   Unicode 空白、不同进制、NaN、无穷、小数和越界数字的回归测试。
3. 在 `examples/basic` 下执行 `cjpm run`：验证消费端通过公开接口使用库。
4. `node scripts/check_upstream.cjs`：直接用本地原始函数生成期望值，验证相同输入的仓颉结果。
   该脚本是有限样本对照，不等于对所有可能输入的形式化证明。

## 许可证

沿用上游 MIT License，在根目录保留原始许可与版权，并在衍生源码和测试中注明来源。
参考目录组织不意味着需要改成其他参考仓库的许可证。
