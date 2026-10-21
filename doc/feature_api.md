# API 说明

## required

```cangjie
public func required(port: Int64, protocol: String): Bool
public func required(port: Float64, protocol: String): Bool
public func required(port: String, protocol: String): Bool
```

导入方式：`import requires_port.required`。

返回 `true` 表示 URL 应显式保留这个端口，返回 `false` 表示端口可省略或为空。
三个重载使用同一套协议判断逻辑，均无外部依赖或 I/O。

### 参数

| 参数 | 约定 |
| --- | --- |
| `port: Int64` | 整数端口；不校验范围，负数和大于 65535 的数也参与判断 |
| `port: Float64` | 对应 JavaScript Number，允许小数、正负无穷和 NaN |
| `port: String` | 按上游一元 `+` 的数字字符串规则转换；转换失败返回 `false` |
| `protocol: String` | 协议名、带冒号的协议名或以协议开头的 URL；只取第一个 `:` 前的部分 |

`Int64` 重载会先转为 `Float64`。大整数存在 IEEE 754 精度损失，符合上游 Number 的类型模型；
由于这里只比较零和几个较小的默认端口，该转换不影响判断结果。

### 协议规则

| 输入协议前缀 | 返回 `false` 的端口 |
| --- | --- |
| `http`、`ws` | 0、NaN、80 |
| `https`、`wss` | 0、NaN、443 |
| `ftp` | 0、NaN、21 |
| `gopher` | 0、NaN、70 |
| `file` | 所有端口 |
| 其他（含空字符串） | 0、NaN |

`"HTTP"`、`" http"` 和 `":http"` 都按未知协议处理，不进行大小写归一化、去空格或 URL 校验。

### 字符串转换

- 空字符串和仅包含 ECMAScript 空白的字符串转换为零。
- 接受十进制整数、小数、科学计数法和无符号的 `0x`/`0X`、`0o`/`0O`、`0b`/`0B` 数字。
- 接受首尾 ECMAScript 空白，包括 U+FEFF；U+0085 不属于该集合。
- `Infinity`、`+Infinity`、`-Infinity` 表示无穷；大小写敏感。
- 非法字符串，例如 `80abc`、`inf`、`80_0`、`+0x50`、`0x1p4`，转换为 NaN，返回 `false`。
- 不接受 JavaScript 的对象、数组、布尔、`null`、`undefined` 等动态类型输入。
  仓颉 API 的参数范围为上述三个重载。

该函数只暴露最终的端口判断结果，不暴露数字转换值。极大进制整数内部使用浮点累积；
不能用它作为通用 JavaScript Number 转换器。

### 示例

```cangjie
required("8e1", "http")       // false
required("0x50", "http")      // false
required(80, "HTTP")          // true
required(0, "unknown")        // false
required("abc", "unknown")    // false
required(-1, "http")          // true
required(8080, "file:///tmp")  // false
```
