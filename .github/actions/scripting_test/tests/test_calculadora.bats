#!/usr/bin/env bats

# =============================================================================
# Tests for calculadora.sh (Exercise 1.3)
# Validates: argument handling, arithmetic operations, error handling
# =============================================================================

SCRIPT="./scripts/calculadora.sh"

@test "fails with no arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with two arguments" {
    run bash "$SCRIPT" "5" "+"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with non-numeric first argument" {
    run bash "$SCRIPT" "abc" "+" "5"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with non-numeric second argument" {
    run bash "$SCRIPT" "5" "+" "xyz"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "addition works" {
    run bash "$SCRIPT" "15" "+" "27"
    [ "$status" -eq 0 ]
    [[ "$output" == *"15 + 27 = 42"* ]]
}

@test "subtraction works" {
    run bash "$SCRIPT" "50" "-" "8"
    [ "$status" -eq 0 ]
    [[ "$output" == *"50 - 8 = 42"* ]]
}

@test "multiplication works" {
    run bash "$SCRIPT" "6" "*" "7"
    [ "$status" -eq 0 ]
    [[ "$output" == *"6 * 7 = 42"* ]]
}

@test "division works" {
    run bash "$SCRIPT" "84" "/" "2"
    [ "$status" -eq 0 ]
    [[ "$output" == *"84 / 2 = 42"* ]]
}

@test "division by zero fails" {
    run bash "$SCRIPT" "100" "/" "0"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
    [[ "$output" == *"cero"* ]]
}

@test "unsupported operator fails" {
    run bash "$SCRIPT" "8" "%" "3"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "negative numbers work" {
    run bash "$SCRIPT" "-10" "+" "52"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-10 + 52 = 42"* ]]
}

@test "integer division truncates" {
    run bash "$SCRIPT" "7" "/" "2"
    [ "$status" -eq 0 ]
    [[ "$output" == *"7 / 2 = 3"* ]]
}
