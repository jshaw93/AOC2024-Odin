package day1

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:slice"

main :: proc() {
    handle, fErr := os.open("input.txt")
    if fErr != os.ERROR_NONE {
        fmt.panicf("Err: File open")
    }
    defer os.close(handle)
    file, readErr := os.read_entire_file_from_handle(handle)
    defer delete(file)
    lines, err := strings.split(string(file), "\r\n")
    
    fmt.println("Part 1:", part1(lines[:]))
    fmt.println("Part 2:", part2(lines[:]))
}

part1 :: proc(lines : []string) -> int {
    totalDistance : int = 0

    leftList : [dynamic]int
    rightList : [dynamic]int
    defer delete(leftList)
    defer delete(rightList)

    // Split lines into left and right lists
    for line in lines {
        splitLine := strings.split(line, "   ")
        append(&leftList, strconv.atoi(splitLine[0]))
        append(&rightList, strconv.atoi(splitLine[1]))
    }
    
    // Sort left, right smallest to largest number
    slice.sort(leftList[:])
    slice.sort(rightList[:])
    
    // Calculate absolute distance between left and right nums based on
    // smallest to largest value
    for i in 0..<len(leftList) {
        leftNum : int = leftList[i]
        rightNum : int = rightList[i]
        totalDistance += abs(leftNum - rightNum)
    }
    return totalDistance
}

part2 :: proc(lines : []string) -> int {
    totalSimilarity : int = 0

    leftList : [dynamic]int
    rightList : [dynamic]int
    defer delete(leftList)
    defer delete(rightList)

    // Split lines into left and right lists
    for line in lines {
        splitLine := strings.split(line, "   ")
        append(&leftList, strconv.atoi(splitLine[0]))
        append(&rightList, strconv.atoi(splitLine[1]))
    }

    // Calculate similarity
    for i in 0..<len(leftList) {
        leftNum : int = leftList[i]
        occurred : int = numOccurred(leftNum, rightList[:])
        totalSimilarity += leftNum * occurred
    }

    return totalSimilarity
}

numOccurred :: proc(number : int, rightList : []int) -> int {
    occurred : int = 0
    for num in rightList {
        if number == num do occurred += 1
    }
    return occurred
}
