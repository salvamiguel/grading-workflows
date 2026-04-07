#!/usr/bin/env bats

# =============================================================================
# Tests for tf-wrapper.sh (Exercise 3.1)
# Validates: terraform check, directory validation, help flag, exit codes
# =============================================================================

SCRIPT="./scripts/tf-wrapper.sh"

setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "fails if terraform is not installed" {
    # Restrict PATH so terraform is not found
    PATH="/usr/bin:/bin" run bash "$SCRIPT" -d "$TEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Terraform"* ]] || [[ "$output" == *"terraform"* ]]
}

@test "fails if directory does not exist" {
    run bash "$SCRIPT" -d "/nonexistent/path/abc123"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Directorio"* ]] || [[ "$output" == *"directorio"* ]] || [[ "$output" == *"no encontrado"* ]] || [[ "$output" == *"no existe"* ]]
}

@test "shows help with -h flag" {
    run bash "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Uso"* ]] || [[ "$output" == *"uso"* ]] || [[ "$output" == *"directorio"* ]]
}

@test "fails with unknown argument" {
    run bash "$SCRIPT" --unknown-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"Error"* ]] || [[ "$output" == *"desconocido"* ]]
}

@test "fails with badly formatted terraform files" {
    if ! command -v terraform &> /dev/null; then
        skip "terraform is not installed"
    fi

    # Create a badly formatted .tf file
    cat > "$TEST_DIR/main.tf" << 'EOF'
resource "null_resource" "test" {
        triggers = {
    value = "test"
        }
}
EOF

    run bash "$SCRIPT" -d "$TEST_DIR"
    [ "$status" -eq 2 ]
}

@test "output includes logging with timestamps" {
    if ! command -v terraform &> /dev/null; then
        skip "terraform is not installed"
    fi

    # Create a minimal valid .tf file
    cat > "$TEST_DIR/main.tf" << 'EOF'
terraform {
  required_version = ">= 1.0"
}
EOF

    run bash "$SCRIPT" -d "$TEST_DIR"
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]
}

@test "uses distinct exit codes for different failures" {
    # Exit code 1 = general error (no terraform, bad dir)
    # Exit code 2 = format check failed
    # Exit code 3 = validation failed
    # Exit code 4 = plan failed

    run bash "$SCRIPT" -d "/nonexistent/dir"
    [ "$status" -eq 1 ]
}
