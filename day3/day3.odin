package day3

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem/virtual"
import "core:mem"
import "core:unicode/utf8"
import "core:strconv"

main :: proc() {
    arena : virtual.Arena
    initErr := virtual.arena_init_growing(&arena)
    if initErr != nil do fmt.panicf("Arena initialization error: %s", initErr)
    defer virtual.arena_destroy(&arena)
    arenaAlloc := virtual.arena_allocator(&arena)

    handle, fErr := os.open("input.txt")
    if fErr != os.ERROR_NONE {
        fmt.panicf("Err: File open")
    }
    defer os.close(handle)
    file, readErr := os.read_entire_file_from_handle(handle, allocator=arenaAlloc)
    line := string(file)
    
    fmt.println("Part 1:", part1(line))
    fmt.println("Part 2:", part2(line))
}

ALLOWED_RUNES :[]rune: {'m', 'u', 'l', '(', ')', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ','}
EXPECTED_INNER :[]rune: {'(', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ','}
EXPECTED_MUL :string: "mul("

part1 :: proc(line : string, allocator := context.allocator) -> int {
    // Holy this is a bowl of spaghetti
    total : int = 0
    parsedCommand := make([dynamic]rune, allocator=allocator)
    defer delete(parsedCommand)
    lineLoop : for char, index in line {
        if char == 'm' {
            if line[index:index+4] != EXPECTED_MUL do continue
            inner : bool = false
            for i in index..<len(line) {
                character := rune(line[i])
                if character == '(' do inner = true
                if !checkAllowed(character) {
                    clear(&parsedCommand)
                    continue lineLoop
                }
                if inner {
                    if character == ')' {
                        append(&parsedCommand, character)
                        result := runCommand(parsedCommand[:])
                        total += result
                    }
                    if !checkInner(character) {
                        clear(&parsedCommand)
                        continue lineLoop
                    }
                }
                append(&parsedCommand, character)
            }
        }
    }
    return total
}

part2 :: proc(line : string, allocator := context.allocator) -> int {
    // Bigger bowl of spaghetti
    total : int = 0
    parsedCommand := make([dynamic]rune, allocator=allocator)
    defer delete(parsedCommand)
    enabled : bool = true
    lineLoop : for char, index in line {
        if char == 'd' {
            doCheck := line[index:index+4]
            dontCheck := line[index:index+7]
            if doCheck == "do()" do enabled = true
            if dontCheck == "don't()" do enabled = false
        }
        if char == 'm' && enabled {
            if line[index:index+4] != EXPECTED_MUL do continue
            inner : bool = false
            for i in index..<len(line) {
                character := rune(line[i])
                if character == '(' do inner = true
                if !checkAllowed(character) {
                    clear(&parsedCommand)
                    continue lineLoop
                }
                if inner {
                    if character == ')' {
                        append(&parsedCommand, character)
                        result := runCommand(parsedCommand[:])
                        total += result
                    }
                    if !checkInner(character) {
                        clear(&parsedCommand)
                        continue lineLoop
                    }
                }
                append(&parsedCommand, character)
            }
        }
    }
    return total
}

checkAllowed :: proc(char: rune) -> bool {
    for allowed in ALLOWED_RUNES {
        if allowed == char do return true
    }
    return false
}

checkInner :: proc(char: rune) -> bool {
    for allowed in EXPECTED_INNER {
        if allowed == char do return true
    }
    return false
}

runCommand :: proc(command : []rune) -> int {
    stripped : []rune = command[4:len(command)-1]
    strippedString : string = utf8.runes_to_string(stripped, context.temp_allocator)
    split := strings.split(strippedString, ",", context.temp_allocator)
    if len(split) != 2 do return 0 // mul(456)
    numLeft := strconv.atoi(split[0])
    numRight := strconv.atoi(split[1])
    free_all(context.temp_allocator)
    return numLeft * numRight
}
