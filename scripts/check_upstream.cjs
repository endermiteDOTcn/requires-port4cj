'use strict';

// Compare the Cangjie implementation with the preserved JavaScript upstream.
// No npm packages are required. Generated files stay under target/.
const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');
const required = require('../requires-port');

const root = path.resolve(__dirname, '..');
const generated = path.join(root, 'target', 'upstream-compat');
const protocols = ['http', 'ws', 'https', 'wss', 'ftp', 'gopher', 'file', 'unknown',
  '', ':http', 'HTTP', ' http', 'http ', 'http:', 'https://example.com',
  'ws://localhost', 'file:///tmp/file', 'http:extra:parts', '协议'];
const strings = ['', ' ', '0', '-0', '+0', '80', '443', '21', '70', '8080',
  '080', '+80', '80.', '80.0', '8e1', '800e-1', '.8', '-80', '80.5',
  '0x50', '0X50', '0o120', '0O120', '0b1010000', '0B1010000', '0x1bb',
  '0xFFFFFFFFFFFFFFFFFFFFFFFF', 'Infinity', '+Infinity', '-Infinity', '1e9999',
  '1e-9999', 'NaN', 'inf', 'infinity', 'abc', '80abc', '80_0', '80f64',
  '80 0', '+', '-', '.', '1e', '1e+', '++80', '0x', '0b2', '0o8', '0xfg',
  '0x1p4', '+0x50', '-0x50', '0x+50', '0x 50', '0b1.0', '80\0', '\u008580',
  '0.00000000000000000001', '5e-324', '1e-324', '65536', '-1'];
const whitespace = ['\t', '\n', '\v', '\f', '\r', ' ', '\u00a0', '\u1680',
  ...Array.from({ length: 11 }, (_, i) => String.fromCodePoint(0x2000 + i)),
  '\u2028', '\u2029', '\u202f', '\u205f', '\u3000', '\ufeff'];
for (const space of whitespace) strings.push(space, space + '80' + space, space + '81' + space);

// Seeded generated decimal inputs supplement the explicit regression cases.
let seed = 20261021;
for (let i = 0; i < 160; i++) {
  seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
  const n = seed % 100000;
  strings.push(String(n), `${n}e-2`, `0x${n.toString(16)}`);
}
const quote = value => JSON.stringify(value)
  .replace(/\\u([0-9a-f]{4})/gi, '\\u{$1}')
  .replace(/[^\x20-\x7e]/gu, value => `\\u{${value.codePointAt(0).toString(16)}}`);
const expectedBits = port => quote(protocols.map(protocol => required(port, protocol) ? '1' : '0').join(''));
const stringCases = strings.map(port => `        (${quote(port)}, ${expectedBits(port)})`);
const numbers = [[0, '0.0'], [-0, '-0.0'], [80, '80.0'], [443, '443.0'],
  [21, '21.0'], [70, '70.0'], [8080, '8080.0'], [-1, '-1.0'], [80.5, '80.5'],
  [NaN, 'Float64.NaN'], [Infinity, 'Float64.Inf'], [-Infinity, '-Float64.Inf']];
const numberCases = numbers.map(([port, literal]) => `        (${literal}, ${expectedBits(port)})`);

fs.mkdirSync(path.join(generated, 'src'), { recursive: true });
fs.writeFileSync(path.join(generated, 'cjpm.toml'), `[package]
cjc-version = "1.0.5"
name = "upstream_compat"
version = "1.0.0"
output-type = "executable"

[dependencies]
requires_port = { path = "../.." }
`, 'utf8');
fs.writeFileSync(path.join(generated, 'src', 'main.cj'), `package upstream_compat
import requires_port.required

main() {
    let protocols = [${protocols.map(quote).join(', ')}]
    let strings: Array<(String, String)> = [
${stringCases.join(',\n')}
    ]
    for (index in 0..strings.size) {
        let (port, bits) = strings[index]
        let expected = bits.toArray()
        for (p in 0..protocols.size) {
            if (required(port, protocols[p]) != (expected[p] == b'1')) {
                throw Exception("String input mismatch at case \${index}: port=\${port}, protocol=\${protocols[p]}")
            }
        }
    }
    let numbers: Array<(Float64, String)> = [
${numberCases.join(',\n')}
    ]
    for ((port, bits) in numbers) {
        let expected = bits.toArray()
        for (p in 0..protocols.size) {
            if (required(port, protocols[p]) != (expected[p] == b'1')) {
                throw Exception("Numeric input mismatch: port=\${port}, protocol=\${protocols[p]}")
            }
        }
    }
    println("Upstream compatibility: \${(strings.size + numbers.size) * protocols.size} cases passed")
}
`, 'utf8');
execFileSync('cjpm', ['run'], { cwd: generated, stdio: 'inherit' });
