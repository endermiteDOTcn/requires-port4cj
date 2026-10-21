# API 说明

## required

```cangjie
public func required(port: Int64, protocol: String): Bool
public func required(port: Float64, protocol: String): Bool
public func required(port: String, protocol: String): Bool
```

导入方式：`import requires_port.required`。

返回 `true` 表示 URL 应显式保留这个端口，返回 `false` 表示端口可省略或为空。
三个重载使用同一套协议判断逻辑。

### 参数

| 参数 | 约定 |
| --- | --- |
| `port: Int64` | 整数端口，负数和大于 65535 的数按相同规则参与判断 |
| `port: Float64` | 对应 JavaScript Number，允许小数、正负无穷和 NaN |
| `port: String` | 按上游一元 `+` 的数字字符串规则转换；转换失败返回 `false` |
| `protocol: String` | 协议名、带冒号的协议名或以协议开头的 URL；只取第一个 `:` 前的部分 |

`Int64` 重载先转换为 `Float64`，随后比较零值和各协议的默认端口。

### 协议规则

| 输入协议前缀 | 返回 `false` 的端口 |
| --- | --- |
| `http`、`ws` | 0、NaN、80 |
| `https`、`wss` | 0、NaN、443 |
| `ftp` | 0、NaN、21 |
| `gopher` | 0、NaN、70 |
| `file` | 所有端口 |
| 其他（含空字符串） | 0、NaN |

协议前缀按原始文本匹配，`"HTTP"`、`" http"` 和 `":http"` 都按未知协议处理。

### 字符串转换

- 空字符串和仅包含 ECMAScript 空白的字符串转换为零。
- 接受十进制整数、小数、科学计数法和无符号的 `0x`/`0X`、`0o`/`0O`、`0b`/`0B` 数字。
- 首尾 ECMAScript 空白在转换前去除，包括 U+FEFF。
- `Infinity`、`+Infinity`、`-Infinity` 表示无穷；大小写敏感。
- 非法字符串，例如 `80abc`、`inf`、`80_0`、`+0x50`、`0x1p4`，转换为 NaN，返回 `false`。
- 带有 U+0085 前后缀的数字字符串按非法输入处理，返回 `false`。

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
