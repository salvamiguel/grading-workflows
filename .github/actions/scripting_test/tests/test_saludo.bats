#!/usr/bin/env bats

# =============================================================================
# Tests for saludo.sh (Exercise 1.1)
# Validates: argument handling, age validation, age-based greeting messages
# =============================================================================

SCRIPT="./scripts/saludo.sh"

@test "fails with no arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with only one argument" {
    run bash "$SCRIPT" "Ana"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with three arguments" {
    run bash "$SCRIPT" "Ana" "25" "extra"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with non-numeric age" {
    run bash "$SCRIPT" "Ana" "abc"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with negative age" {
    run bash "$SCRIPT" "Ana" "-5"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "minor message for age under 18" {
    run bash "$SCRIPT" "Ana" "10"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Ana"* ]]
    [[ "$output" == *"menor de edad"* ]]
}

@test "working age message for age 18" {
    run bash "$SCRIPT" "Juan" "18"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Juan"* ]]
    [[ "$output" == *"edad laboral"* ]]
}

@test "working age message for age 64" {
    run bash "$SCRIPT" "Maria" "64"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Maria"* ]]
    [[ "$output" == *"edad laboral"* ]]
}

@test "retirement message for age 65" {
    run bash "$SCRIPT" "Pedro" "65"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pedro"* ]]
    [[ "$output" == *"jubilacion"* ]]
}

@test "retirement message for age 80" {
    run bash "$SCRIPT" "Lucia" "80"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Lucia"* ]]
    [[ "$output" == *"jubilacion"* ]]
}

@test "handles name with spaces" {
    run bash "$SCRIPT" "Ana Garcia" "25"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Ana Garcia"* ]]
}

@test "error messages go to stderr" {
    run bash -c "bash $SCRIPT 2>/dev/null"
    # With stderr suppressed, stdout should be empty or not contain error
    [[ "$output" != *"Error"* ]]
}
