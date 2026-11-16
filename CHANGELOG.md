# Changelog

## Unreleased

- 验证六个 SDK（1.0.5、1.1.0、1.1.3、1.1.5、1.2.0、1.2.1）在 Windows/Linux x86_64 的 release/debug 构建、单测、示例及消费端集成。
- 上游对照脚本支持 `UPSTREAM_SEED`，在入口校验非空十进制 uint32；保持默认种子并记录八种子 release 对照结果。
- 将协议后缀测试的域名改为 localhost，保持端口判断断言不变，并补充覆盖率和提交前检查记录。

## 1.0.0

- 基于本地 requires-port 1.0.0 源码创建纯仓颉移植。
- 添加 `required` 的 `Int64`、`Float64` 和 `String` 重载。
- 保留上游协议、默认端口与数字字符串判断规则。
- 添加仓颉单元测试、独立示例和上游行为对照脚本。
- 添加 API 文档及仓库结构、移植决策说明。
