#!/usr/bin/env bats

# =============================================================================
# Tests for top_ips.sh (Exercise 2.1)
# Validates: argument handling, IP extraction, error count summary
# =============================================================================

SCRIPT="./scripts/top_ips.sh"

setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR

    # Create a sample access log
    cat > "$TEST_DIR/access.log" << 'EOF'
192.168.1.100 - - [15/Mar/2025:10:15:32 +0100] "GET /index.html HTTP/1.1" 200 1234
10.0.0.55 - - [15/Mar/2025:10:15:33 +0100] "POST /api/login HTTP/1.1" 401 89
192.168.1.100 - - [15/Mar/2025:10:15:34 +0100] "GET /styles.css HTTP/1.1" 200 5678
172.16.0.1 - - [15/Mar/2025:10:15:35 +0100] "GET /favicon.ico HTTP/1.1" 404 0
10.0.0.55 - - [15/Mar/2025:10:15:36 +0100] "POST /api/login HTTP/1.1" 401 89
10.0.0.55 - - [15/Mar/2025:10:15:37 +0100] "POST /api/login HTTP/1.1" 200 512
192.168.1.100 - - [15/Mar/2025:10:15:38 +0100] "GET /dashboard HTTP/1.1" 200 8765
192.168.1.200 - - [15/Mar/2025:10:15:39 +0100] "GET /index.html HTTP/1.1" 200 1234
172.16.0.1 - - [15/Mar/2025:10:15:40 +0100] "GET /api/status HTTP/1.1" 200 128
192.168.1.100 - - [15/Mar/2025:10:15:41 +0100] "GET /images/logo.png HTTP/1.1" 200 4567
EOF
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "fails with no arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with non-existent file" {
    run bash "$SCRIPT" "/nonexistent/file.log"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "shows top IPs section header" {
    run bash "$SCRIPT" "$TEST_DIR/access.log"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Top 10"* ]] || [[ "$output" == *"top"* ]] || [[ "$output" == *"IP"* ]]
}

@test "identifies most frequent IP" {
    run bash "$SCRIPT" "$TEST_DIR/access.log"
    [ "$status" -eq 0 ]
    # 192.168.1.100 appears 4 times - should be first
    [[ "$output" == *"4"*"192.168.1.100"* ]]
}

@test "identifies second most frequent IP" {
    run bash "$SCRIPT" "$TEST_DIR/access.log"
    [ "$status" -eq 0 ]
    # 10.0.0.55 appears 3 times
    [[ "$output" == *"3"*"10.0.0.55"* ]]
}

@test "shows error summary section" {
    run bash "$SCRIPT" "$TEST_DIR/access.log"
    [ "$status" -eq 0 ]
    [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]] || [[ "$output" == *"4xx"* ]]
}

@test "counts 4xx errors correctly" {
    run bash "$SCRIPT" "$TEST_DIR/access.log"
    [ "$status" -eq 0 ]
    # There are 3 4xx errors (two 401s and one 404)
    [[ "$output" == *"4xx"*"3"* ]] || [[ "$output" == *"3"*"4xx"* ]]
}

@test "counts 5xx errors correctly" {
    run bash "$SCRIPT" "$TEST_DIR/access.log"
    [ "$status" -eq 0 ]
    # There are 0 5xx errors
    [[ "$output" == *"5xx"*"0"* ]] || [[ "$output" == *"0"*"5xx"* ]]
}
