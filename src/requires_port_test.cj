// Copyright (c) 2015 Unshift.io, Arnout Kazemier, the Contributors.
// Ported to Cangjie in 2026. Licensed under the MIT License.
package requires_port

import std.unittest.*
import std.unittest.testmacro.*

@Test
class RequiresPortTest {
    @TestCase
    func defaultPortsAndProtocolSuffixes(): Unit {
        // Covers all six protocol groups and all input forms in upstream test.js.
        for ((protocol, port) in [("http", 80), ("ws", 80), ("https", 443), ("wss", 443), ("ftp", 21), ("gopher", 70)]) {
            for (suffix in ["", ":", "://", "://www.google.com"]) {
                @Expect(required(port, protocol + suffix), false)
                @Expect(required(port.toString(), protocol + suffix), false)
                @Expect(required(8080, protocol + suffix), true)
                @Expect(required("8080", protocol + suffix), true)
            }
        }
    }

    @TestCase
    func emptyAndZeroPorts(): Unit {
        for (protocol in ["http", "wss", "ws", "cowsack", ""]) {
            for (port in ["", "0", "-0", "+0", "0.0", "  \t\r\n", "0e99"]) {
                @Expect(required(port, protocol), false)
            }
            @Expect(required(0, protocol), false)
            @Expect(required(-0.0, protocol), false)
        }
    }

    @TestCase
    func unknownAndCaseSensitiveProtocols(): Unit {
        for (protocol in ["foo", "bar", "HTTP", "Http", " http", "", ":http", "ssh"]) {
            @Expect(required("80", protocol), true)
            @Expect(required(808, protocol), true)
        }
    }

    @TestCase
    func fileNeverRequiresPort(): Unit {
        for (protocol in ["file", "file:", "file:///tmp/file"]) {
            @Expect(required(8080, protocol), false)
            @Expect(required(-1, protocol), false)
            @Expect(required(Float64.Inf, protocol), false)
            @Expect(required("Infinity", protocol), false)
        }
    }

    @TestCase
    func decimalNumericStrings(): Unit {
        for (port in ["80", "080", "+80", "80.", "80.0", "8e1", "800e-1", " 80 ", "\t80\n"]) {
            @Expect(required(port, "http"), false)
            @Expect(required(port, "https"), true)
        }
        for (port in [".8", "80.5", "-80", "65536", "1e9999", "Infinity", "+Infinity", "-Infinity"]) {
            @Expect(required(port, "http"), true)
        }
        @Expect(required("1e-9999", "http"), false)
    }

    @TestCase
    func radixNumericStrings(): Unit {
        for (port in ["0x50", "0X50", "0o120", "0O120", "0b1010000", "0B1010000"]) {
            @Expect(required(port, "http"), false)
            @Expect(required(port, "https"), true)
        }
        @Expect(required("0x1bb", "https"), false)
        @Expect(required("0x1BB", "https"), false)
        @Expect(required("0xFFFFFFFFFFFFFFFFFFFFFFFF", "http"), true)
        @Expect(required("0b0", "http"), false)
    }

    @TestCase
    func invalidNumericStrings(): Unit {
        for (port in ["abc", "80abc", "80_0", "80f64", "80 0", "NaN", "inf", "infinity", "+", "-", ".", "1e", "1e+",
                "++80", "0x", "0b2", "0o8", "0xfg", "0x1p4", "+0x50", "-0x50", "0x+50", "0x 50", "0b1.0", "80\u{0000}",
                "\u{0085}80"]) {
            @Expect(required(port, "http"), false)
            @Expect(required(port, "unknown"), false)
        }
    }

    @TestCase
    func unicodeWhitespace(): Unit {
        for (space in ["\u{000B}", "\u{000C}", "\u{00A0}", "\u{1680}", "\u{2000}", "\u{2007}", "\u{200A}", "\u{2028}",
                "\u{2029}", "\u{202F}", "\u{205F}", "\u{3000}", "\u{FEFF}"]) {
            @Expect(required(space + "80" + space, "http"), false)
            @Expect(required(space + "81" + space, "http"), true)
            @Expect(required(space, "http"), false)
        }
    }

    @TestCase
    func numericInputsAreNotPortValidation(): Unit {
        @Expect(required(Float64.NaN, "http"), false)
        @Expect(required(Float64.Inf, "http"), true)
        @Expect(required(-Float64.Inf, "http"), true)
        @Expect(required(80.0, "http"), false)
        @Expect(required(80.5, "http"), true)
        @Expect(required(-1, "http"), true)
        @Expect(required(65536, "http"), true)
    }
}
