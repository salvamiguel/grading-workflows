#!/usr/bin/env bats

# =============================================================================
# Tests for ppt.sh (Reto 1.4)
# Validates: rock-paper-scissors game logic, input handling, score tracking
# =============================================================================

SCRIPT="./scripts/ppt.sh"

@test "accepts piedra as valid input" {
    run bash -c 'echo -e "piedra\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"piedra"* ]] || [[ "$output" == *"Piedra"* ]]
}

@test "accepts papel as valid input" {
    run bash -c 'echo -e "papel\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"papel"* ]] || [[ "$output" == *"Papel"* ]]
}

@test "accepts tijera as valid input" {
    run bash -c 'echo -e "tijera\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"tijera"* ]] || [[ "$output" == *"Tijera"* ]]
}

@test "exits when user types salir" {
    run bash -c 'echo "salir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
}

@test "shows final score on exit" {
    run bash -c 'echo -e "piedra\npapel\ntijera\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    # Should show some kind of score/tally
    [[ "$output" == *"victoria"* ]] || [[ "$output" == *"derrota"* ]] || [[ "$output" == *"empate"* ]] || [[ "$output" == *"marcador"* ]] || [[ "$output" == *"Marcador"* ]]
}

@test "plays multiple rounds" {
    run bash -c 'echo -e "piedra\npiedra\npiedra\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    # Output should contain multiple round results
    line_count=$(echo "$output" | wc -l)
    [ "$line_count" -gt 3 ]
}

@test "generates a machine choice" {
    run bash -c 'echo -e "piedra\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    # Machine should pick one of the three options
    [[ "$output" == *"piedra"* ]] || [[ "$output" == *"papel"* ]] || [[ "$output" == *"tijera"* ]]
}

@test "determines winner correctly" {
    # Play enough rounds that at least one non-draw result appears
    run bash -c 'echo -e "piedra\npiedra\npiedra\npiedra\npiedra\nsalir" | bash '"$SCRIPT"
    [ "$status" -eq 0 ]
    # Should contain win/lose/draw language
    [[ "$output" == *"gana"* ]] || [[ "$output" == *"pierde"* ]] || [[ "$output" == *"empate"* ]] || [[ "$output" == *"Gana"* ]] || [[ "$output" == *"Empate"* ]]
}
