package day2

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:mem/virtual"
import "core:mem"

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
    file, readErr := os.read_entire_file_from_handle(handle, arenaAlloc)
    lines, err := strings.split(string(file), "\r\n", arenaAlloc)

    fmt.println("Part 1:", part1(lines[:], arenaAlloc))
    fmt.println("Part 2:", part2(lines[:], arenaAlloc))
}

parseLine :: proc(line : string, allocator := context.allocator) -> [dynamic]int {
    nums : [dynamic]int
    numStrings := strings.split(line, " ", allocator)
    for n in numStrings {
        num : int = strconv.atoi(n)
        append(&nums, num)
    }
    return nums
}

part1 :: proc(lines : []string, allocator := context.allocator) -> int {
    safeReports : int = 0
    for line in lines {
        levels : [dynamic]int = parseLine(line, allocator)
        safePos := make(map[int]byte, allocator = allocator)
        safePos = {1=1, 2=1, 3=1}
        safeNeg := make(map[int]byte, allocator = allocator)
        safeNeg = {-1=1, -2=1, -3=1}
        defer {
            delete(safePos)
            delete(safeNeg)
            delete(levels)
        }
        for i in 1..<len(levels) {
            safePos[levels[i] - levels[i-1]] = 1
            safeNeg[levels[i] - levels[i-1]] = 1
        }
        if len(safePos) == 3 || len(safeNeg) == 3 do safeReports += 1
    }
    return safeReports
}

part2 :: proc(lines : []string, allocator := context.allocator) -> int {
    safeReports : int = 0
    lineLoop : for line in lines {
        safePos := make(map[int]byte, allocator = allocator)
        safePos = {1=1, 2=1, 3=1}
        safeNeg := make(map[int]byte, allocator = allocator)
        safeNeg = {-1=1, -2=1, -3=1}
        levels : [dynamic]int = parseLine(line, allocator)
        defer {
            delete(safePos)
            delete(safeNeg)
            delete(levels)
        }
        for i in 1..<len(levels) {
            safePos[levels[i] - levels[i-1]] = 1
            safeNeg[levels[i] - levels[i-1]] = 1
        }
        if len(safePos) == 3 || len(safeNeg) == 3 {
            safeReports += 1
            continue
        }

        // Lax check
        iterations := genIterations(levels[:], allocator)
        defer {
            for i in 0..<len(iterations) do delete(iterations[i])
            delete(iterations)
        }
        for iteration in iterations {
            clear(&safePos)
            clear(&safeNeg)
            safePos[1]=1; safePos[2]=1; safePos[3]=1; safeNeg[-1]=1; safeNeg[-2]=1; safeNeg[-3]=1
            for i in 1..<len(iteration) {
                safePos[iteration[i] - iteration[i-1]] = 1
                safeNeg[iteration[i] - iteration[i-1]] = 1
            }
            if len(safePos) == 3 || len(safeNeg) == 3 {
                safeReports += 1
                continue lineLoop
            }
        }
    }
    return safeReports
}

genIterations :: proc(levels : []int, allocator := context.allocator) -> [dynamic][dynamic]int {
    iterations := make([dynamic][dynamic]int, allocator = allocator)
    for i in 0..<len(levels) {
        iteration : [dynamic]int
        for level, index in levels {
            if index == i do continue
            append(&iteration, level)
        }
        append(&iterations, iteration)
    }
    return iterations
}
