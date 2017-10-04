//
//  BinaryHeap.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 06/06/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

private class NodeDirectAccecssIndirectStorage<T: KeyValuePair> {
    var directAccessToNodes: Dictionary<T.V, BasicBinaryHeap<T>> = [:]
    
    public subscript(position: T.V) -> BasicBinaryHeap<T>? {
        get {
            return self.directAccessToNodes[position]
        }
        
        set {
            self.directAccessToNodes[position] = newValue
        }
    }
    
    public func removeValue(forKey value: T.V) {
        self.directAccessToNodes.removeValue(forKey: value)
    }
}

/// This class can function as a priority head that stores key-value pairs maintaining their relative order.
/// The order of the elements is based on the key, which is considered the priority.
/// It is possible to update the priority of an element already in the queue. This will be done by using the value
/// as the token to fetch. It reads, update the priority of the element with value V to the new priority K.
final public class BasicBinaryHeap<T: KeyValuePair> : CompleteBinaryTree, TraversableBinaryTree, PriorityQueue {
    
    typealias Item = T
    
    /// Reference to the left subtree
    weak var parent: BasicBinaryHeap?
    
    /// Reference to the left subtree
    var leftChild: BasicBinaryHeap?
    
    /// Reference to the right subtree
    var rightChild: BasicBinaryHeap?
    
    /// A container of information.
    var item: Item?
    
    /// The number of nodes in the tree
    var count: Int = 0
    
    /// Defines the relative order of the nodes in the heap
    var type: PriorityQueueType = .min
    
    /// A traversal strategy
    var iterator: AnyIterator<T>?
    
    /// Data structure to guarantee direct access to the elements in the tree
    /// to help with certain tasks such as updating the priority of an element.
    ///
    /// We use an indirect storage (reference type wrapper) to allow that
    /// all nodes point to the same structure.
    private var directAccessToNodes: NodeDirectAccecssIndirectStorage<T>
    
    
    /// Convenience initializer
    ///
    /// - Parameters:
    ///   - parent: reference to the parent node
    ///   - leftChild: reference to the  left subtree
    ///   - rightChild: reference to the right subtree
    ///   - value: item contained in the tree node.
    public convenience init(value: T,
                parent: BasicBinaryHeap?,
                leftChild: BasicBinaryHeap?,
                rightChild: BasicBinaryHeap?,
                type: PriorityQueueType) {
        self.init(value: value,
                  parent: parent,
                  leftChild: leftChild,
                  rightChild: rightChild,
                  type: type,
                  nodeIndirectStorage:NodeDirectAccecssIndirectStorage<T>())
    }
    
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - parent: reference to the parent node
    ///   - leftChild: reference to the  left subtree
    ///   - rightChild: reference to the right subtree
    ///   - value: item contained in the tree node.
    ///   - nodeIndirectStorage: Data structure with direct access to the nodes.
    private init(value: T?,
                parent: BasicBinaryHeap?,
                leftChild: BasicBinaryHeap?,
                rightChild: BasicBinaryHeap?,
                type: PriorityQueueType,
                nodeIndirectStorage: NodeDirectAccecssIndirectStorage<T>) {
        self.leftChild = leftChild
        self.rightChild = rightChild
        self.item = value
        self.count = 1
        self.type = type
        self.directAccessToNodes = nodeIndirectStorage
        if let v = value {
            self.directAccessToNodes[v.value] = self
        }
    }
    
    
    /// Minimum
    ///
    /// - Returns: The node with the smallest key
    /// - Complexity: O(1)
    public func top() -> BasicBinaryHeap? {
        if self.isEmpty() {
            // If empty tree
            return nil
        } else {
            // Otherwise return the root
            return self
        }        
    }
    
    
    /// Removes and returns the top element of the heap.
    /// Depending on the type of the heap, this will be the
    /// min or max element in the heap.
    ///
    /// - Returns: The top of the heap.
    /// - Complexity: O(log(N)) which is the height of the tree.
    public func extractTop() -> BasicBinaryHeap? {
        
        guard !self.isEmpty() else {
            // If the tree is empty
            return nil
        }
        
        // Create a copy of the top of the heap.
        // TODO: This might be an unnecessary copy for value types, since passing it as a parameter will copy it.
        let top = BasicBinaryHeap<T>(value: self.item!.copy(), parent: nil, leftChild: nil, rightChild: nil, type:self.type, nodeIndirectStorage: self.directAccessToNodes)
        
        // Find the replacement, which is the bottommost rightmost node
        let replacement = self.bottommostRightmostNode()
        
        // Replace values.
        self.item = replacement?.item
        
        // Delete the replacement
        if replacement == replacement?.parent?.leftChild {
            replacement?.parent?.leftChild = nil
        } else if replacement == replacement?.parent?.rightChild {
            replacement?.parent?.rightChild = nil
        } else {
            // Root node
            self.item = nil
        }
        
        // Restore heap properties
        let lastNodeToBeSwapped = self.bubbleDown()
        
        // There won't be an item when deleting the root.
        // The root node stays, but the item is nilled out.
        if let item = lastNodeToBeSwapped.item {
            self.directAccessToNodes[item.value] = lastNodeToBeSwapped
        }
        
        // Delete it from the direct access map
        self.directAccessToNodes.removeValue(forKey: top.item!.value)
        
        return top
    }
    
    
    /// Updates the priority of the element with the passed key.
    ///
    /// - Parameter key: the current priority.
    /// - Parameter newKey: the new priority.
    /// - Complexity: O(Log(N)).
    public func updatePriority(ofValue value:T.V, to newPriority: T.K) {
        if let node = self.directAccessToNodes[value] {
            node.item!.key = newPriority
            var newRef = node.bubbleUp()
            
            if (node === newRef) {
                // It means we didn't buble up. Bubble down then
                newRef = node.bubbleDown()
            }
            self.directAccessToNodes[value] = newRef
        }
    }
}


// MARK: Private methods

extension BasicBinaryHeap {
    
    /// Restores the heap invariant. Starts at the current node and goes up.
    ///
    /// - Returns: the node where the bubbling stopped.
    private func bubbleUp() -> BasicBinaryHeap<T> {
        
        var current: BasicBinaryHeap<T>? = self
        
        while /* Not at the root */(current?.parent != nil) &&
            /* Doesn't conserve heap property */(!self.heapPropertiesAreKept(parent: current!.parent, child: current!, type: self.type)) {
                
                // If we got in, we know there's a parent.
                swapItems(parent: current!.parent!, child: current!)
                self.directAccessToNodes.directAccessToNodes[current!.item!.value] = current!
                current = current!.parent
        }
        
        return current!
    }
    
    
    /// Restores the heap invariant. Starts at the current node and goes down.
    ///
    /// - Returns: the node where the bubbling stopped.
    private func bubbleDown() -> BasicBinaryHeap<T> {
        
        var current: BasicBinaryHeap<T>? = self
        
        while let c = current,
            let childToSwap = c.relevantChildrenToSwap(),
            /* Not a leaf */(c.numberOfChildren() > 0) &&
                /* Doesn't conserves heap property */(!self.heapPropertiesAreKept(parent: c, child: childToSwap, type: self.type)) {
                    
                    // If we got in, we know there's a parent.
                    swapItems(parent: c, child: childToSwap)
                    self.directAccessToNodes.directAccessToNodes[c.item!.value] = c
                    current = childToSwap
        }
        
        return current!
    }
    
    private func heapPropertiesAreKept(parent: BasicBinaryHeap<T>?, child: BasicBinaryHeap<T>, type: PriorityQueueType) -> Bool {
        
        if let p = parent {
            switch type {
            case .min:
                return p.item! < child.item!
            case .max:
                return p.item! > child.item!
            }
        } else {
            return true
        }
    }
    
    private func swapItems(parent: BasicBinaryHeap<T>, child: BasicBinaryHeap<T>) {
        let temp = parent.item
        parent.item = child.item
        child.item = temp
    }
    
    /// TODO: Tidy up. Reduce duplication. Use Swifts max, min functions.
    private func relevantChildrenToSwap() -> BasicBinaryHeap<T>? {
        
        guard self.numberOfChildren() > 0 else {
            return nil
        }
        
        if self.numberOfChildren() == 1 {
            if let leftChild = self.leftChild {
                switch type {
                case .min:
                    return (self.item! > leftChild.item!) ? leftChild : nil
                case .max:
                    return self.item! < leftChild.item! ? leftChild : nil
                }
                
            } else {
                switch type {
                case .min:
                    return (self.item! > self.rightChild!.item!) ? rightChild : nil
                case .max:
                    return self.item! < self.rightChild!.item! ? rightChild : nil
                }
                
            }
        } else {
            switch type {
            case .min:
                let minChild = BasicBinaryHeap.minBetween(n1: self.leftChild!, n2: self.rightChild!)
                return (self.item! > minChild.item!) ? minChild : nil
            case .max:
                let maxChild = BasicBinaryHeap.maxBetween(n1: self.leftChild!, n2: self.rightChild!)
                return self.item! < maxChild.item! ? maxChild : nil
            }
        }
    }
    
    private static func minBetween(n1: BasicBinaryHeap<T>, n2: BasicBinaryHeap<T>) -> BasicBinaryHeap<T> {
        
        if n1.item! < n2.item! {
            return n1
        } else {
            return n2
        }
        
    }
    
    private static func maxBetween(n1: BasicBinaryHeap<T>, n2: BasicBinaryHeap<T>) -> BasicBinaryHeap<T> {
        
        if n1.item! > n2.item! {
            return n1
        } else {
            return n2
        }
    }
}


// MARK: BinaryTree

extension BasicBinaryHeap {
    
    /// Finds a node in the tree with the given key
    ///
    /// - Parameter key: Key to search for.
    /// - Returns: A node with the given key or nil if not found.
    /// - TODO: Not implemented
    public func search(key: T.K) -> BasicBinaryHeap? {
        return nil
    }
    
    /// Removes a node from the tree, that has a matching key.
    ///
    /// - Parameter elementWithKey: the key the element to be deleted must have.
    /// - Returns: True if an element was deleted.
    /// - TODO: Not implemented
    public func delete(elementWithKey: T.K) -> Bool {
        return false
    }
    
    /// Adds a new node to the tree.
    ///
    /// - Parameter item: new item to be added to the tree.
    /// - Complexity: O(Log(N)).
    public func insert(item: T) {
        
        guard !self.isEmpty() else {
            self.item = item.copy()
            return
        }
        
        // Create a new node
        let newNode = BasicBinaryHeap<T>(value: item, parent:nil, leftChild: nil, rightChild: nil, type: self.type, nodeIndirectStorage: self.directAccessToNodes)
        
        // Insert the new node into the first free place that respects the completeness of the tree.
        // All levels complete, except the last one that can have free places, but it's complete from left to right
        let nodeWithSpace = self.nextIncompleteNode()
        
        if nodeWithSpace.leftChild == nil {
            nodeWithSpace.leftChild = newNode
        } else if nodeWithSpace.rightChild == nil {
            nodeWithSpace.rightChild = newNode
        }
        
        newNode.parent = nodeWithSpace
        
        // Bubble up to restore properties of a heap
        let insertedNode = newNode.bubbleUp()
        self.directAccessToNodes[insertedNode.item!.value] = insertedNode
    }
    
    
    func minimum() -> BasicBinaryHeap<T>? {
        return self.top()
    }
    
    
    func maximum() -> BasicBinaryHeap<T>? {
        return self.top()
    }
}



// MARK: Priority Queue

extension BasicBinaryHeap {
    
    /// Convenience initializer
    ///
    /// - Parameters:
    ///   - type: relative order of elements in the heap.
    convenience init(type: PriorityQueueType) {
        self.init(value: nil,
                  parent: nil,
                  leftChild: nil,
                  rightChild: nil,
                  type: type,
                  nodeIndirectStorage: NodeDirectAccecssIndirectStorage<Item>())
    }
    
    
    /// Dequeues the oldest element in the queue.
    ///
    /// - Returns: The oldest element in the queue, which gets removed from it.
    func dequeue() -> Item? {
        return self.extractTop()?.item
    }
    
    
    /// Returns the oldest element in the queue.
    ///
    /// - Returns: The oldest element in the queue. It does not dequeue it.
    func getFirst() -> Item? {
        return self.top()?.item
    }
    
    
    /// Adds an element to the queue
    ///
    /// - Parameter item: Item to be added
    /// - Throws: There are cases where the operation might fail. For example if there is not enough space.
    func enqueue(item: Item) throws {
        self.insert(item: item)
    }
}
