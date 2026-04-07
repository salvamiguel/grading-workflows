#!/usr/bin/env bats

# =============================================================================
# Tests for student-written BATS tests (Exercise 3.3)
# Validates that the student's tf-wrapper.bats file follows BATS best practices
# =============================================================================

STUDENT_TESTS="./tests/tf-wrapper.bats"

@test "student test file exists" {
    [ -f "$STUDENT_TESTS" ]
}

@test "student test file has bats shebang" {
    head -1 "$STUDENT_TESTS" | grep -q "bats" || head -1 "$STUDENT_TESTS" | grep -q "bash"
}

@test "student tests define a setup function" {
    grep -q "setup()" "$STUDENT_TESTS"
}

@test "student tests define a teardown function" {
    grep -q "teardown()" "$STUDENT_TESTS"
}

@test "student tests use @test annotations" {
    test_count=$(grep -c "@test" "$STUDENT_TESTS")
    [ "$test_count" -ge 4 ]
}

@test "student tests check terraform not installed" {
    grep -q "terraform" "$STUDENT_TESTS"
    # Should have a test that modifies PATH or checks for terraform
    grep -q "PATH" "$STUDENT_TESTS" || grep -q "command -v" "$STUDENT_TESTS"
}

@test "student tests check non-existent directory" {
    grep -q "directorio\|directory\|no existe\|inexistente" "$STUDENT_TESTS"
}

@test "student tests check help flag" {
    grep -q "\-h\|help\|ayuda" "$STUDENT_TESTS"
}

@test "student tests check exit status" {
    grep -q 'status' "$STUDENT_TESTS"
}

@test "student tests use run command" {
    grep -q "run " "$STUDENT_TESTS"
}

@test "student tests use temporary directories" {
    grep -q "mktemp\|TMPDIR\|TEST_DIR\|tmp" "$STUDENT_TESTS"
}

@test "student tests are syntactically valid" {
    # Try to parse the file with bats --count (just counts tests, doesn't run them)
    if command -v bats &> /dev/null; then
        run bats --count "$STUDENT_TESTS"
        [ "$status" -eq 0 ]
        [ "$output" -ge 4 ]
    else
        skip "bats not available for syntax check"
    fi
}
