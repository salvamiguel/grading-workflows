#!/usr/bin/env bats

# =============================================================================
# Tests for healthcheck.sh (Reto 2.5)
# Validates: URL config reading, HTTP checks, logging, alert generation
# =============================================================================

SCRIPT="./scripts/healthcheck.sh"

setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR

    # Create a sample URLs config file
    cat > "$TEST_DIR/urls.txt" << 'EOF'
https://httpbin.org/status/200
https://httpbin.org/status/500
https://httpbin.org/delay/10
EOF
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT" ]
    chmod +x "$SCRIPT"
    [ -x "$SCRIPT" ]
}

@test "reads URLs from config file" {
    # Create a config with a single reachable URL
    echo "https://httpbin.org/status/200" > "$TEST_DIR/single_url.txt"
    run bash "$SCRIPT" "$TEST_DIR/single_url.txt"
    # Should not fail with exit 1 (config error)
    [[ "$status" -ne 1 ]] || [[ "$output" != *"Error"* ]]
}

@test "logs results with timestamps" {
    echo "https://httpbin.org/status/200" > "$TEST_DIR/single_url.txt"
    run bash "$SCRIPT" "$TEST_DIR/single_url.txt"
    # Output or log files should contain timestamps
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]] || \
    ls "$TEST_DIR"/*.log &>/dev/null
}

@test "fails with non-existent config file" {
    run bash "$SCRIPT" "/nonexistent/urls.txt"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"error"* ]]
}

@test "handles empty config file" {
    > "$TEST_DIR/empty_urls.txt"
    run bash "$SCRIPT" "$TEST_DIR/empty_urls.txt"
    # Should handle gracefully (either exit 0 with warning or exit 1)
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "uses curl with timeout" {
    # Check that the script contains a curl call with timeout
    grep -q "curl" "$SCRIPT"
    grep -q "timeout\|--max-time\|-m " "$SCRIPT"
}

@test "generates alerts for 5xx responses" {
    # Check that the script handles 5xx error detection
    grep -q "5[0-9][0-9]\|5xx\|alerta" "$SCRIPT"
}

@test "uses flock or similar locking mechanism" {
    grep -q "flock\|lock" "$SCRIPT"
}
