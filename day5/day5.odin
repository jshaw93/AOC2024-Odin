package day5

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:mem/virtual"
import "core:slice"

ordersGlobal : map[string][]string

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

    orders := make(map[string][]string)
    updates := make([dynamic][]string, arenaAlloc)
    defer {
        delete(orders)
        delete(updates)
    }

    isUpdate : bool = false
    for line in lines {
        if len(line) == 0 {
            isUpdate = true
            continue
        }
        if isUpdate {
            data : []string = strings.split(line, ",", arenaAlloc)
            append(&updates, data)
        } else {
            data : []string = strings.split(line, "|", arenaAlloc)
            key : string = data[0]
            list : []string = orders[key]
            listC : [][]string = {list, {data[1]}}
            orders[key] = slice.concatenate(listC, arenaAlloc)
        }
    }
    ordersGlobal = orders
    fmt.println("Part 1:", part1(orders, updates[:], arenaAlloc))
    fmt.println("Part 2:", part2(orders, updates[:], arenaAlloc))
}

part1 :: proc(orders : map[string][]string, updates : [][]string, allocator := context.allocator) -> int {
    result : int = 0
    updateLoop : for update in updates {
        updateIndexes := make(map[string]int, allocator)
        defer delete(updateIndexes)
        for i, index in update do updateIndexes[i]=index
        
        // Validation check
        for value, index in update {
            ordering : []string = orders[value]
            for order in ordering {
                if !isOrderInUpdate(order, update) do continue
                if index > updateIndexes[order] {
                    continue updateLoop
                }
            }
        }
        result += strconv.atoi(update[len(update)/2])
    }
    return result
}

part2 :: proc(orders : map[string][]string, updates : [][]string, allocator := context.allocator) -> int {
    result : int = 0
    updateLoop : for update in updates {
        updateIndexes := make(map[string]int, allocator)
        defer delete(updateIndexes)
        for i, index in update do updateIndexes[i]=index
        
        // Validation check
        for value, index in update {
            ordering : []string = orders[value]
            for order in ordering {
                if !isOrderInUpdate(order, update) do continue
                if index > updateIndexes[order] {
                    ordered : []string = update
                    slice.sort_by_cmp(ordered, sortUpdateKey)
                    result += strconv.atoi(ordered[len(ordered)/2])
                    continue updateLoop
                }
            }
        }
    }
    return result
}

isOrderInUpdate :: proc(orderValue : string, update : []string) -> bool {
    for updateValue in update {
        if updateValue == orderValue do return true
    }
    return false
}

sortUpdateKey :: proc(a, b : string) -> slice.Ordering {
    if isInOrders(a, b) do return slice.Ordering.Less
    else if isInOrders(b, a) do return slice.Ordering.Greater
    else do return slice.Ordering.Equal
}

isInOrders :: proc(key, value : string) -> bool {
    for v in ordersGlobal[key] {
        if v == value do return true
    }
    return false
}
