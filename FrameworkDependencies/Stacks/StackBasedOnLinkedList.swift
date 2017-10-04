//
//  BaseStack.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 07/05/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

open class StackBasedOnLinkedList<T> : Stack
{
    typealias Item = T
    
    /// Internal data structure
    internal var list = SinglyLinkedList<T>()

    
    /// Adds a new element in Last In First Out order
    ///
    /// - Parameter item: new element to be added
    func push(item: Item)
    {
        self.list.prepend(value: item)
    }
    
    
    /// Removes and returns the item at the top of the stack
    func pop() -> Item?
    {
        guard (self.list.count > 0) else {
            return nil
        }

        return self.list.deleteItem(at: 0)
    }
    
    /// Returns without removing the item at the top of the stack
    func peek() -> Item?
    {
        return self.list.first
    }
    
    func count() -> Int {
        return self.list.count
    }
}
