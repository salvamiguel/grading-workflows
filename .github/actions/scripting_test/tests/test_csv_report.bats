#!/usr/bin/env bats

# =============================================================================
# Tests for csv_report.sh (Reto 2.4)
# Validates: CSV parsing, salary stats, department grouping, top earners
# =============================================================================

SCRIPT="./scripts/csv_report.sh"

setup() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR

    # Create a sample CSV file
    cat > "$TEST_DIR/employees.csv" << 'EOF'
nombre,departamento,salario,fecha_alta
Ana Garcia,Ingenieria,45000,2020-03-15
Carlos Lopez,Marketing,35000,2019-07-01
Maria Fernandez,Ingenieria,52000,2018-11-20
Pedro Sanchez,RRHH,38000,2021-01-10
Laura Martinez,Marketing,42000,2020-06-05
Juan Rodriguez,Ingenieria,48000,2017-09-30
Sofia Ruiz,RRHH,36000,2022-02-14
EOF
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "fails with no arguments" {
    run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"error"* ]]
}

@test "fails with non-existent file" {
    run bash "$SCRIPT" "/nonexistent/file.csv"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"error"* ]]
}

@test "shows total number of employees" {
    run bash "$SCRIPT" "$TEST_DIR/employees.csv"
    [ "$status" -eq 0 ]
    # 7 employees in the sample data
    [[ "$output" == *"7"* ]]
}

@test "calculates salary statistics" {
    run bash "$SCRIPT" "$TEST_DIR/employees.csv"
    [ "$status" -eq 0 ]
    # Min salary is 35000, max is 52000
    [[ "$output" == *"35000"* ]]
    [[ "$output" == *"52000"* ]]
}

@test "groups by department" {
    run bash "$SCRIPT" "$TEST_DIR/employees.csv"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Ingenieria"* ]]
    [[ "$output" == *"Marketing"* ]]
    [[ "$output" == *"RRHH"* ]]
}

@test "lists top 3 earners" {
    run bash "$SCRIPT" "$TEST_DIR/employees.csv"
    [ "$status" -eq 0 ]
    # Top 3: Maria (52000), Juan (48000), Ana (45000)
    [[ "$output" == *"Maria"* ]]
    [[ "$output" == *"Juan"* ]]
}

@test "handles CSV with only header" {
    echo "nombre,departamento,salario,fecha_alta" > "$TEST_DIR/empty.csv"
    run bash "$SCRIPT" "$TEST_DIR/empty.csv"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"datos"* ]]
}

@test "output is formatted" {
    run bash "$SCRIPT" "$TEST_DIR/employees.csv"
    [ "$status" -eq 0 ]
    # Should have some structure (headers, separators, or tabular formatting)
    line_count=$(echo "$output" | wc -l)
    [ "$line_count" -gt 5 ]
}
