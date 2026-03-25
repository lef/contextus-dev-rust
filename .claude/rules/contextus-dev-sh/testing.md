# Shell Script Testing

## Test Framework: bats-core

Use [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

```bash
# Install
brew install bats-core          # macOS
sudo apt-get install bats       # Ubuntu/Debian
```

## RED → GREEN → REFACTOR in Shell

Shell has one kind of RED (test fails at runtime):

```bash
bats tests/           # confirm RED — test must fail before implementation
```

**Rules**:
- Write the failing test first — never write implementation before a RED test
- One failing test at a time
- Write the minimum code to pass
- Refactor only on GREEN

## File Structure

```
your-script.sh
tests/
└── your-script.bats   # test file alongside or in tests/
```

## Bats Test Structure

```bash
#!/usr/bin/env bats

setup() {
  # Runs before each test
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  # Runs after each test — always clean up
  rm -rf "$TEST_DIR"
}

@test "description of what is tested" {
  run your-script.sh --some-flag
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected string"* ]]
}

@test "exits non-zero on invalid input" {
  run your-script.sh --invalid
  [ "$status" -ne 0 ]
}
```

## Testing Patterns

### Test exit codes

```bash
@test "succeeds on valid config" {
  run setup.sh --valid-flag
  [ "$status" -eq 0 ]
}

@test "fails on missing required arg" {
  run setup.sh
  [ "$status" -eq 1 ]
}
```

### Test output content

```bash
@test "prints expected message" {
  run my-script.sh
  [[ "$output" == *":: setup complete"* ]]
}

@test "prints error to stderr" {
  run my-script.sh --bad-input
  [[ "$stderr" == *"error:"* ]]
}
```

### Test file side effects with tmpdir

```bash
@test "creates HANDOFF.md when missing" {
  run setup.sh --project-dir "$TEST_DIR"
  [ -f "$TEST_DIR/HANDOFF.md" ]
}

@test "does not overwrite existing HANDOFF.md" {
  echo "existing" > "$TEST_DIR/HANDOFF.md"
  run setup.sh --project-dir "$TEST_DIR"
  [[ "$(cat "$TEST_DIR/HANDOFF.md")" == "existing" ]]
}
```

### Test with fake git/gh (stub commands)

```bash
setup() {
  TEST_DIR="$(mktemp -d)"
  # Put fake commands early in PATH
  mkdir -p "$TEST_DIR/bin"
  printf '#!/bin/bash\necho "fake gh $*"\nexit 0\n' > "$TEST_DIR/bin/gh"
  chmod +x "$TEST_DIR/bin/gh"
  export PATH="$TEST_DIR/bin:$PATH"
}
```

## Running Tests

```bash
bats tests/                    # run all tests
bats tests/setup.bats          # run one file
bats --filter "creates " tests/ # filter by name
bats --tap tests/              # TAP output for CI
```

## CI Integration

```yaml
# GitHub Actions
- name: Install bats
  run: sudo apt-get install -y bats

- name: Run shell tests
  run: bats tests/
```

## Test Naming

Pattern: `<what it does> <under what condition>`

```bash
@test "creates HANDOFF.md when not present"
@test "skips AGENTS.md when already exists"
@test "exits 1 when gh is not installed"
@test "records L2 profile in layers manifest"
```
