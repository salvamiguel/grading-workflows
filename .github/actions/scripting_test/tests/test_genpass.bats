#!/usr/bin/env bats

# =============================================================================
# Tests for genpass.sh (Reto 1.5)
# Validates: password generation, length/count flags, character class exclusions
# =============================================================================

SCRIPT="./scripts/genpass.sh"

@test "generates a password with default settings" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ -n "$output" ]]
}

@test "default password length is 16" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    # Extract the first line (the password) and check length
    password=$(echo "$output" | head -1)
    [ "${#password}" -eq 16 ]
}

@test "custom length with -l flag" {
    run bash "$SCRIPT" -l 32
    [ "$status" -eq 0 ]
    password=$(echo "$output" | head -1)
    [ "${#password}" -eq 32 ]
}

@test "generates multiple passwords with -n flag" {
    run bash "$SCRIPT" -n 5
    [ "$status" -eq 0 ]
    # Should have at least 5 lines of passwords
    password_count=$(echo "$output" | grep -c '[a-zA-Z0-9]')
    [ "$password_count" -ge 5 ]
}

@test "no-symbols flag excludes special characters" {
    run bash "$SCRIPT" --no-symbols -l 100
    [ "$status" -eq 0 ]
    password=$(echo "$output" | head -1)
    # Should only contain alphanumeric characters
    [[ "$password" =~ ^[a-zA-Z0-9]+$ ]]
}

@test "no-uppercase flag excludes uppercase letters" {
    run bash "$SCRIPT" --no-uppercase --no-symbols -l 100
    [ "$status" -eq 0 ]
    password=$(echo "$output" | head -1)
    # Should not contain uppercase letters
    [[ ! "$password" =~ [A-Z] ]]
}

@test "no-numbers flag excludes digits" {
    run bash "$SCRIPT" --no-numbers --no-symbols -l 100
    [ "$status" -eq 0 ]
    password=$(echo "$output" | head -1)
    # Should not contain digits
    [[ ! "$password" =~ [0-9] ]]
}

@test "shows entropy estimate" {
    run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"entropia"* ]] || [[ "$output" == *"Entropia"* ]] || [[ "$output" == *"bits"* ]] || [[ "$output" == *"entropy"* ]]
}

@test "combined flags work together" {
    run bash "$SCRIPT" -l 20 -n 3 --no-symbols
    [ "$status" -eq 0 ]
    password=$(echo "$output" | head -1)
    [ "${#password}" -eq 20 ]
}
