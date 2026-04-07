#!/usr/bin/env bats

# =============================================================================
# Tests for backup.sh (Exercise 2.3)
# Validates: argument handling, backup creation, integrity check, rotation
# =============================================================================

SCRIPT="./scripts/backup.sh"

setup() {
    TEST_DIR=$(mktemp -d)
    SOURCE_DIR="$TEST_DIR/source"
    DEST_DIR="$TEST_DIR/backups"
    mkdir -p "$SOURCE_DIR" "$DEST_DIR"

    # Create some files to back up
    echo "file1 content" > "$SOURCE_DIR/file1.txt"
    echo "file2 content" > "$SOURCE_DIR/file2.txt"
    mkdir -p "$SOURCE_DIR/subdir"
    echo "nested file" > "$SOURCE_DIR/subdir/nested.txt"

    export TEST_DIR SOURCE_DIR DEST_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "fails without required arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"ERROR"* ]]
}

@test "fails without source directory" {
    run bash "$SCRIPT" -d "$DEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"origen"* ]]
}

@test "fails without destination directory" {
    run bash "$SCRIPT" -s "$SOURCE_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"destino"* ]]
}

@test "fails with non-existent source directory" {
    run bash "$SCRIPT" -s "/nonexistent/path" -d "$DEST_DIR"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"ERROR"* ]]
}

@test "creates backup successfully" {
    run bash "$SCRIPT" -s "$SOURCE_DIR" -d "$DEST_DIR"
    [ "$status" -eq 0 ]

    # Check that a .tar.gz file was created in the destination
    backup_count=$(ls "$DEST_DIR"/*.tar.gz 2>/dev/null | wc -l)
    [ "$backup_count" -eq 1 ]
}

@test "backup contains source files" {
    bash "$SCRIPT" -s "$SOURCE_DIR" -d "$DEST_DIR"
    backup_file=$(ls "$DEST_DIR"/*.tar.gz | head -1)

    # Verify the backup contains our files
    tar tzf "$backup_file" | grep -q "file1.txt"
    tar tzf "$backup_file" | grep -q "file2.txt"
    tar tzf "$backup_file" | grep -q "nested.txt"
}

@test "backup is not empty" {
    bash "$SCRIPT" -s "$SOURCE_DIR" -d "$DEST_DIR"
    backup_file=$(ls "$DEST_DIR"/*.tar.gz | head -1)

    file_count=$(tar tzf "$backup_file" | wc -l)
    [ "$file_count" -gt 0 ]
}

@test "shows help with -h flag" {
    run bash "$SCRIPT" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Uso"* ]] || [[ "$output" == *"uso"* ]]
}

@test "rotates old backups when exceeding max" {
    # Create 3 fake old backups
    touch "$DEST_DIR/backup_source_20250101_010000.tar.gz"
    sleep 1
    touch "$DEST_DIR/backup_source_20250102_010000.tar.gz"
    sleep 1
    touch "$DEST_DIR/backup_source_20250103_010000.tar.gz"

    # Run backup with max 2
    run bash "$SCRIPT" -s "$SOURCE_DIR" -d "$DEST_DIR" -n 2
    [ "$status" -eq 0 ]

    # Should have at most 2 backups remaining
    backup_count=$(ls "$DEST_DIR"/backup_source_*.tar.gz 2>/dev/null | wc -l)
    [ "$backup_count" -le 2 ]
}

@test "output includes logging with timestamps" {
    run bash "$SCRIPT" -s "$SOURCE_DIR" -d "$DEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]
}

@test "creates destination directory if it does not exist" {
    NEW_DEST="$TEST_DIR/new_backup_dir"
    run bash "$SCRIPT" -s "$SOURCE_DIR" -d "$NEW_DEST"
    [ "$status" -eq 0 ]
    [ -d "$NEW_DEST" ]
}
