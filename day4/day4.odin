package day4

import "core:fmt"
import "core:os"
import "core:strings"
import "core:mem"
import "core:mem/virtual"
import "core:unicode/utf8"

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
    lines := strings.split(string(file), "\r\n", arenaAlloc)
    grid : [dynamic][]rune
    defer delete(grid)
    for line in lines {
        append(&grid, utf8.string_to_runes(line, arenaAlloc))
    }

    fmt.println("Part 1:", part1(grid[:], arenaAlloc))
    fmt.println("Part 2:", part2(grid[:]))
}

part1 :: proc(grid : [][]rune, allocator := context.allocator) -> int {
    size : int = len(grid[0])
    total : int = 0
    for i in 0..<size {
        total += scanLine(grid, {i, 0}, {0, 1}, size)
        total += scanLine(grid, {0, i}, {1, 0}, size)
    }
    for i in 0..<size-3 {
        total += scanLine(grid, {i, 0}, {1, 1}, size - i)
        total += scanLine(grid, {0, i+1}, {1, 1}, size - 1 - i)
        total += scanLine(grid, {size - 1 - i, 0}, {-1, 1}, size - i)
        total += scanLine(grid, {size - 1, i + 1}, {-1, 1}, size - 1 - i)
    }
    return total
}

part2 :: proc(grid : [][]rune) -> int {
    total : int = 0
    for x in 1..<len(grid[0])-1 {
        for y in 1..<len(grid)-1 {
            if grid[y][x] == 'A' {
                upLeft := grid[y-1][x-1]
                upRight := grid[y-1][x+1]
                downLeft := grid[y+1][x-1]
                downRight := grid[y+1][x+1]
                total += (abs(upLeft - downRight) == 6 && (abs(upRight - downLeft) == 6))
            }
        }
    }
    return total
}

Point :: struct {
    x : int,
    y : int
}

scanLine :: proc(grid : [][]rune, point, direction : Point, size : int) -> int {
    ctxPoint := point
    ctxDirection := direction
    bytes : u32 = 0
    result : int = 0
    for _ in 0..<size {
        bytes = (bytes << 8) | (u32(grid[ctxPoint.y][ctxPoint.x]))
        ctxPoint.x += ctxDirection.x
        ctxPoint.y += ctxDirection.y
        // "XMAS" || "SMAX"
        result += int(bytes == 0x584d4153 || bytes == 0x53414d58)
    }
    return result
}
