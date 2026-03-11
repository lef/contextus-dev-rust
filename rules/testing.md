# Rust Testing

## File Structure

```
src/
├── lib.rs
├── module.rs        ← unit tests here, in #[cfg(test)] block
tests/
├── common/
│   └── mod.rs       ← shared test helpers
└── integration.rs   ← integration tests (public API only)
```

## Unit Tests

Place in the same file as the code being tested:

```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add_positive_numbers() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    fn test_add_negative_numbers() {
        assert_eq!(add(-1, -1), -2);
    }

    #[test]
    #[should_panic(expected = "overflow")]
    fn test_add_overflow_panics() {
        add(i32::MAX, 1);
    }
}
```

## Test Naming

Pattern: `test_<function>_<scenario>`

```rust
fn test_parse_host_with_port()       // happy path with port
fn test_parse_host_without_port()    // default port case
fn test_parse_host_empty_string()    // edge case
fn test_parse_host_invalid_chars()   // error case
```

## Integration Tests

Test public API end-to-end from `tests/`:

```rust
// tests/proxy.rs
use ductus::proxy;

#[test]
fn test_proxy_allows_listed_domain() {
    let result = proxy::check_allowed("example.com", &allowlist());
    assert!(result.is_ok());
}
```

## Async Tests

```rust
#[tokio::test]
async fn test_async_operation() {
    let result = async_fn().await;
    assert!(result.is_ok());
}
```

## Doc Tests

Write examples in doc comments — they run as tests:

```rust
/// ```
/// use mylib::parse_host;
/// assert_eq!(parse_host("example.com:443").unwrap().as_str(), "example.com");
/// ```
pub fn parse_host(header: &str) -> Result<String, Error> { }
```

Run with: `cargo test --doc`

## Running Tests

```bash
cargo test           # all tests
cargo test --doc     # doc tests only
cargo test <name>    # filter by test name
cargo test -- --nocapture  # show println! output
```
