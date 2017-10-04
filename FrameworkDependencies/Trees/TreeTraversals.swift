//
//  TreeTraversal.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 15/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation


// MARK: Depth-first traversals

/// Returns an iterator to traverse a tree in order.
///
/// - Parameter tree: Tree to be traversed. The tree must be Traversable becuase some implementations
///   define an internal structure that would make this code fail.
/// - Returns: An iterator to traverse a tree in order.
/// - Complexity: O(N)
func inOrderTraversalIterator<Element, T: TraversableBinaryTree>(tree: T) -> AnyIterator<Element> where Element == T.Item {
    
    let stack = StackBasedOnLinkedList<T>()
    var current: T? = tree
    
    return AnyIterator {
        repeat {
            // Find the minimum
            while(current != nil) {
                stack.push(item: current!)
                current = current?.leftChild
            }
            
            if(!stack.isEmpty) {
                let top = stack.pop()
                current = top?.rightChild
                return top?.item
            }
            
        } while((!stack.isEmpty) || (current != nil))
        
        return nil        
    }
}


/// Returns an iterator to traverse a tree in post order.
///
/// - Parameter tree: Tree to be traversed. The tree must be Traversable becuase some implementations define an internal structure that would make this code fail.
/// - Returns: An iterator to traverse a tree in post order.
/// - Complexity: O(N)
func postOrderTraversalIterator<Element, T: TraversableBinaryTree>(tree: T) -> AnyIterator<Element> where Element == T.Item {
    
    let stack = StackBasedOnLinkedList<T>()
    var previous: T? = nil
    var current: T? = tree
    
    return AnyIterator {
        
        repeat {
            
            while(current != nil) {
                stack.push(item: current!)
                current = current?.leftChild
            }
            
            while(current == nil) && (!stack.isEmpty) {
                
                // Update the current
                current = stack.peek()
                
                // If already visited
                if(current?.rightChild == nil) || (current?.rightChild == previous) {
                    
                    previous = current
                    current = nil
                    return stack.pop()?.item
                    
                } else {
                    current = current?.rightChild
                }
            }
            
        } while(!stack.isEmpty)
        
        return nil
    }
}

/// Returns an iterator to traverse a tree in post order checking for each
/// subtree the right child first, then the left one and finally the root.
///
/// - Parameter tree: Tree to be traversed. The tree must be Traversable becuase
///   some implementations define an internal structure that would make this code fail.
/// - Returns: An iterator to traverse a tree in post order.
/// - Complexity: O(N)
func postOrderRightToLeftTraversalIterator<Element, T: TraversableBinaryTree>(tree: T) -> AnyIterator<Element> where Element == T.Item {
    
    let stack = StackBasedOnLinkedList<T>()
    var previous: T? = nil
    var current: T? = tree
    
    return AnyIterator {
        
        repeat {
            
            while(current != nil) {
                stack.push(item: current!)
                current = current?.rightChild
            }
            
            while(current == nil) && (!stack.isEmpty) {
                
                // Update the current
                current = stack.peek()
                
                // If already visited left branch
                if(current?.leftChild == nil) || (current?.leftChild == previous) {
                    
                    previous = current
                    current = nil
                    return stack.pop()?.item
                    
                } else {
                    current = current?.leftChild
                }
            }
            
        } while(!stack.isEmpty)
        
        return nil
    }
}


/// Returns an iterator to traverse a tree in post order checking for each
/// subtree the right child first, then the left one and finally the root.
///
/// - Parameter tree: Tree to be traversed. The tree must be Traversable becuase
///   some implementations define an internal structure that would make this code fail.
/// - Returns: An iterator to traverse a tree in post order. Each returned item includes the height too.
/// - Complexity: O(N)
func postOrderRightToLeftTraversalIterator<T: TraversableBinaryTree>(tree: T) -> AnyIterator<(node: T, height: Int)> {
    
    let stack = StackBasedOnLinkedList<T>()
    var previous: T? = nil
    var current: T? = tree
    var currentHeight = 0 // Start at the root

    return AnyIterator {
        
        repeat {
            
            while(current != nil) {
                stack.push(item: current!)
                current = current?.rightChild
                currentHeight += 1
            }
            
            while(current == nil) && (!stack.isEmpty) {
                
                // Update the current
                current = stack.peek()
                
                // If already visited left branch
                if(current?.leftChild == nil) || (current?.leftChild == previous) {
                    
                    previous = current
                    current = nil
                    let height = currentHeight
                    currentHeight -= 1
                    if let top = stack.pop() {
                        return (node: top, height: height)
                    } else {
                        return nil
                    }
                    
                    
                } else {
                    current = current?.leftChild                 
                }
            }
            
        } while(!stack.isEmpty)
        
        return nil
    }
}



// MARK: Breadth-first traversals

/// Breadth First Search is an algorithm that visits the nodes in the same
/// level first before moving on to nodes in levels below.
///
/// - Parameter tree: Tree to be traversed
/// - Returns: An iterator that respects BFS order. Each returned elements contains the height too.
/// - Complexity: O(N)
func breadthFirstSearchTraversalIterator<T: TraversableBinaryTree>(tree: T) -> AnyIterator<(node: T, height: Int)> {
    
    var queue = SinglyLinkedList<T>()
    try! queue.enqueue(item: tree)
    var level: Int = 1 // Start at the root
    var maxLevelCount: Int = 1 // Level 1 can only have the root
    var levelCount: Int = 0 // We have not processed any nodes yet
    
    return AnyIterator {
        
        while queue.count > 0 {
            
            let head = queue.dequeue()
            // Increase the count of processed nodes
            levelCount += 1
            var movedToNextLevel = false
            
            if levelCount >= maxLevelCount {
                maxLevelCount = (maxLevelCount * 2) // In a binary tree, the next level will have at most double the elements from the preivous
                levelCount = 0 // Reset the node count
                level += 1 // Move to the next level
                movedToNextLevel = true
            }
            
            if let leftChild = head?.leftChild {
                try! queue.enqueue(item: leftChild)
            }
            
            if let rightChild = head?.rightChild {
                try! queue.enqueue(item: rightChild)
            }
            
            if movedToNextLevel {
                return (node: head!, height: (level-1))
            } else {
                return (node: head!, height: level)
            }
        }
        
        return nil
    }
}
