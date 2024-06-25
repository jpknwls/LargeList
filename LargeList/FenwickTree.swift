//
//  FenwickTree.swift
//  LargeList
//
//  Created by John Knowles on 6/24/24.
// CREDIT: https://gist.github.com/ielyamani/f586600cccb0845a73ae429e26f75120

import Foundation


protocol _FenwickTree {
    associatedtype T

    var data    : [T] { get set }
    var tree    : [T] { get set }
    var count: Int { get }
    
    func accumulated(at index: Int) -> T
    func value(at index: Int) -> T
    func max() -> T
    func index(for value: T) -> Int
    func update(index: Int, with newValue: T)
    func add(_ newValue: T)
}

class FenwickTree<T: BinaryFloatingPoint>: CustomDebugStringConvertible {
    
    private let count   : Int
    private let neutral : T
    private let forward : (T,T) -> T
    private let reverse : (T,T) -> T

    private var data    : [T]
    private var tree    : [T]
    
    init(
        count: Int,
        neutralElement: T,
        forward: @escaping (T,T) -> T,
        reverse: @escaping (T,T) -> T
        ) {
        self.count = count
        self.neutral = neutralElement
        self.forward = forward
        self.reverse = reverse
        self.data = Array(repeating: neutralElement, count: count)
        self.tree = Array(repeating: neutralElement, count: count + 1)
    }
    
    // to do: add, remove
    
    func update(index: Int, with newValue: T) {
        let oldValue = data[index];
        let delta = reverse(newValue, oldValue)
        data[index] = newValue
        var treeIndex = index + 1
        while treeIndex <= count{
            tree[treeIndex] = forward(tree[treeIndex], delta)
            treeIndex += treeIndex & -treeIndex
        }
    }
    
    func accumulated(at index: Int) -> T {
        var sum = neutral
        var treeIndex = index + 1
        while 0 < treeIndex {
            sum = forward(tree[treeIndex], sum)
            treeIndex -= treeIndex & -treeIndex
//            print(treeIndex)
        }
        return sum
    }
    
    func accumulated(in range: Range<Int>) -> T {
        let low = range.lowerBound, high = range.upperBound - 1
        let cumulatedLow = low == 0 ? neutral : accumulated(at: low - 1)
        let cumulatedHigh = accumulated(at: high)
        return low == high ? data[low] : reverse(cumulatedHigh,cumulatedLow)
    }
    
    
    func value(at index: Int) -> T {
        guard index >= 0 && index < count else { return neutral }
        return data[index]
    }
    
    func values(in range: ClosedRange<Int>) -> [T] {
        guard range.lowerBound >= 0 && range.upperBound < count else { return [] }
        return Array(data[range])
    }
    
    func maxValue() -> T {
        let index = count - 1
        return accumulated(at: index) + value(at: index)
    }
    
    func index(for value: T) -> Int {
        
            var left = 0
            var right = count - 1

            while left <= right {
                let mid = left + (right - left) / 2
                let accumulated = accumulated(at: mid)
                if accumulated == value {
                    return mid
                } else if accumulated < value {
                    left = mid + 1
                } else {
                    right = mid - 1
                }
            }
        
        return max(left, right)

    }
    
    var debugDescription: String {
        let dataDescription = data.map { "\($0),\t"  }.joined().dropLast(2)
        let treeDescription = tree.dropFirst().map { "\($0),\t" }.joined().dropLast(2)
        
        return  "data :\t" + dataDescription
                + "\n" +
                "tree :\t" + treeDescription
    }
}
