package requires_port_example

import requires_port.required

main() {
    println(required("8080", "http")) // true
    println(required(80, "http")) // false
    println(required("443", "https://example.com")) // false
    println(required(8080, "file")) // false
}
