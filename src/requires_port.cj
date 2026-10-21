// Copyright (c) 2015 Unshift.io, Arnout Kazemier, the Contributors.
// Ported to Cangjie in 2026. Licensed under the MIT License.
package requires_port

import std.convert.*

/** Whether a URL needs to include the supplied port, following requires-port 1.0.0. */
public func required(port: Int64, protocol: String): Bool {
    return required(Float64(port), protocol)
}

/** Numeric overload preserving the upstream behavior for fractions, NaN and infinities. */
public func required(port: Float64, protocol: String): Bool {
    if (port == 0.0 || port.isNaN()) {
        return false
    }
    let runes = protocol.toRuneArray()
    var end = 0
    while (end < runes.size && runes[end] != r':') {
        end++
    }
    match (String(runes[..end])) {
        case "http" | "ws" => port != 80.0
        case "https" | "wss" => port != 443.0
        case "ftp" => port != 21.0
        case "gopher" => port != 70.0
        case "file" => false
        case _ => true
    }
}

/** String overload accepting JavaScript numeric strings; invalid strings return false. */
public func required(port: String, protocol: String): Bool {
    return required(parsePort(port), protocol)
}

// JavaScript's unary + accepts a different grammar from std.convert (e.g. "inf"
// and hexadecimal floating-point literals must be rejected). Keep that boundary here.
private func parsePort(port: String): Float64 {
    let runes = port.toRuneArray()
    var start = 0
    var end = runes.size
    while (start < end && isNumberWhitespace(runes[start])) {
        start++
    }
    while (end > start && isNumberWhitespace(runes[end - 1])) {
        end--
    }
    if (start == end) {
        return 0.0
    }
    let text = String(runes[start..end])
    if (text == "Infinity" || text == "+Infinity") {
        return Float64.Inf
    }
    if (text == "-Infinity") {
        return -Float64.Inf
    }
    let bytes = text.toArray()
    if (bytes.size >= 2 && bytes[0] == b'0') {
        let radix: Int64 = match (bytes[1]) {
            case b'x' | b'X' => 16
            case b'o' | b'O' => 8
            case b'b' | b'B' => 2
            case _ => 0
        }
        if (radix != 0) {
            return parseRadix(bytes, radix)
        }
    }
    for (byte in bytes) {
        if (!((byte >= b'0' && byte <= b'9') || byte == b'+' || byte == b'-' || byte == b'.' || byte == b'e' || byte ==
            b'E')) {
            return Float64.NaN
        }
    }
    return Float64.tryParse(text).getOrDefault({=> Float64.NaN})
}

private func parseRadix(bytes: Array<UInt8>, radix: Int64): Float64 {
    if (bytes.size == 2) {
        return Float64.NaN
    }
    var value = 0.0
    for (index in 2..bytes.size) {
        let byte = bytes[index]
        let digit = if (byte >= b'0' && byte <= b'9') {
            Int64(byte - b'0')
        } else if (byte >= b'a' && byte <= b'f') {
            Int64(byte - b'a') + 10
        } else if (byte >= b'A' && byte <= b'F') {
            Int64(byte - b'A') + 10
        } else {
            return Float64.NaN
        }
        if (digit >= radix) {
            return Float64.NaN
        }
        value = value * Float64(radix) + Float64(digit)
    }
    return value
}

// ECMAScript WhiteSpace and LineTerminator, including BOM but excluding U+0085.
private func isNumberWhitespace(value: Rune): Bool {
    let code = UInt32(value)
    return (code >= 0x0009 && code <= 0x000D) || code == 0x0020 || code == 0x00A0 || code == 0x1680 || (code >= 0x2000 &&
        code <= 0x200A) || code == 0x2028 || code == 0x2029 || code == 0x202F || code == 0x205F || code == 0x3000 ||
        code == 0xFEFF
}
