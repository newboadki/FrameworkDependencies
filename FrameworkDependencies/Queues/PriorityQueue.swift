//
//  PriorityQueue.swift
//  Algorithmia
//
//  Created by Borja Arias Drake on 04/11/2016.
//  Copyright © 2016 Borja Arias Drake. All rights reserved.
//



public enum PriorityQueueType {
    case min
    case max
}

public enum PriorityQueueError : Error {
    case invalidOperationForType
    case capacityExceeded
}


/// Priority queues are queues where determining the min, max and extracting them are efficient operations.
/// They mainly add semantics to a queue. Elements are returned in order according to some rule.
///
/// - min is expected to be O(1)
/// - max is expected to be O(1)
/// - extract min is expected to be O(log(N))
/// - extract max is expected to be O(log(N))
protocol PriorityQueue : Queue {
    
    /// Priority queues can return results in ascendent or descendent order
    var type : PriorityQueueType { get }
        
    /// Initializer
    ///
    /// - Parameter type: Type of the priority queue
    init(type: PriorityQueueType)
}
