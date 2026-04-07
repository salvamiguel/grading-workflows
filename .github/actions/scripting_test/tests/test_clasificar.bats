#!/usr/bin/env bats

# =============================================================================
# Tests for clasificar.sh (Exercise 1.2)
# Validates: argument handling, file classification by type, summary output
# =============================================================================

SCRIPT="./scripts/clasificar.sh"

setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "fails with no arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with non-existent directory" {
    run bash "$SCRIPT" "/nonexistent/path/abc123"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "fails with a file instead of directory" {
    touch "$TEST_DIR/file.txt"
    run bash "$SCRIPT" "$TEST_DIR/file.txt"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]]
}

@test "classifies regular files" {
    touch "$TEST_DIR/file1.txt"
    touch "$TEST_DIR/file2.log"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Archivos regulares"* ]]
    [[ "$output" == *"file1.txt"* ]]
    [[ "$output" == *"file2.log"* ]]
}

@test "classifies directories" {
    mkdir "$TEST_DIR/subdir1"
    mkdir "$TEST_DIR/subdir2"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Directorios"* ]]
    [[ "$output" == *"subdir1"* ]]
    [[ "$output" == *"subdir2"* ]]
}

@test "classifies symbolic links" {
    touch "$TEST_DIR/target.txt"
    ln -s "$TEST_DIR/target.txt" "$TEST_DIR/link.txt"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Enlaces simbolicos"* ]]
    [[ "$output" == *"link.txt"* ]]
}

@test "symlinks are not counted as regular files" {
    touch "$TEST_DIR/target.txt"
    ln -s "$TEST_DIR/target.txt" "$TEST_DIR/link.txt"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    # Summary should show 1 regular file and 1 symlink
    [[ "$output" == *"Archivos regulares: 1"* ]]
    [[ "$output" == *"Enlaces simbolicos: 1"* ]]
}

@test "shows summary with counts" {
    touch "$TEST_DIR/file.txt"
    mkdir "$TEST_DIR/subdir"
    touch "$TEST_DIR/target.txt"
    ln -s "$TEST_DIR/target.txt" "$TEST_DIR/link.txt"

    run bash "$SCRIPT" "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Resumen"* ]]
    [[ "$output" == *"Archivos regulares: 2"* ]]
    [[ "$output" == *"Directorios: 1"* ]]
    [[ "$output" == *"Enlaces simbolicos: 1"* ]]
}
