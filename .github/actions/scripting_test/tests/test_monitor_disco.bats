#!/usr/bin/env bats

# =============================================================================
# Tests for monitor_disco.sh (Exercise 2.2)
# Validates: threshold flag, logging, trap cleanup, exit codes
# =============================================================================

SCRIPT="./scripts/monitor_disco.sh"

@test "runs with default threshold" {
    run bash "$SCRIPT"
    # Should succeed (exit 0) or alert (exit 2) — never error (exit 1)
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
    [[ "$output" == *"INFO"* ]]
}

@test "accepts custom threshold with -t flag" {
    run bash "$SCRIPT" -t 99
    [ "$status" -eq 0 ]
    [[ "$output" == *"99%"* ]] || [[ "$output" == *"99"* ]]
}

@test "threshold 1 triggers alerts" {
    run bash "$SCRIPT" -t 1
    # With threshold of 1%, at least one partition should exceed it
    [ "$status" -eq 2 ]
    [[ "$output" == *"WARN"* ]] || [[ "$output" == *"SUPERA"* ]]
}

@test "fails with non-numeric threshold" {
    run bash "$SCRIPT" -t abc
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"Error"* ]]
}

@test "shows help with -h flag" {
    run bash "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Uso"* ]] || [[ "$output" == *"uso"* ]] || [[ "$output" == *"threshold"* ]]
}

@test "output includes timestamps" {
    run bash "$SCRIPT" -t 99
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]
}

@test "output includes partition information" {
    run bash "$SCRIPT" -t 99
    [ "$status" -eq 0 ]
    # Should mention mount points
    [[ "$output" == *"/"* ]]
}

@test "cleans up temp files on exit" {
    # Run the script and check no temp files are leaked
    BEFORE=$(ls /tmp/tmp.* 2>/dev/null | wc -l || echo 0)
    bash "$SCRIPT" -t 99 > /dev/null 2>&1 || true
    AFTER=$(ls /tmp/tmp.* 2>/dev/null | wc -l || echo 0)
    [ "$AFTER" -le "$BEFORE" ]
}

@test "exit code 2 for alerts, 0 for all ok" {
    # With a very high threshold, everything should be fine
    run bash "$SCRIPT" -t 100
    [ "$status" -eq 0 ]
}
