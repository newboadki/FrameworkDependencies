//
//  Graph.swift
//  UnitTests
//
//  Created by Borja Arias Drake on 14/06/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

/// Conformers of this type support the summation mathematic operation
protocol Summable : Comparable {
    static func +(lhs: Self, rhs: Self) -> Self
}

/// Represents the state of exploration of a graph vertex.
enum VertexExplorationStatus {
    case undiscovered
    case discovered
    case explored
    case processed
}

/// A graph G = (V, E)  is a set of vertices V and set of connections between vertices, called edges.
protocol Graph {
    
    associatedtype Vertex: KeyValuePair
    associatedtype Weight: Summable /* Operator '+' should be defined for type Weight */
    
    /// Array of vertices
    var vertices: [Vertex] {get}
    
    /// Number of vertices in the graph
    var vertexCount: Int {get}
    
    /// Connetions between the vertices
    var edges: [(from: Vertex, to: Vertex, weight: Weight)] {get}
    
    /// Number of edges in the graph
    var edgeCount: Int {get}
    
    /// In a directed graph, connections between vertices have a direction,
    /// making (a -> b) different from (b -> a)
    var directed: Bool {get}
    
    
    /// Given a vertex v, its adjacent vertices are those such that:
    /// - Have an edge connecting them in undirected graphs.
    /// - Have a outgoing edge from v to the other vertix.
    ///
    /// - Parameter vertex: Origin vertex.
    /// - Returns: An array of edges. Or nil if the vertex does not exist in the graph.
    /// - Complexity: O(N), where N is v's degree.
    func adjacentVertices(of vertex: Vertex.K) -> [Vertex]?
    
    
    /// Finds a vertex with the given index as its key
    ///
    /// - Parameter index: index to search for
    /// - Returns: a vertex with the sought index or nil if not found
    /// - Complexity: Default implementation offers O(N), where N is the number of vertex in the graph. Concrete implemetations
    ///   can improve this time complexity given their knowledge of the internals of the data structure.
    func vertex(withIndex index: Vertex.K) -> Vertex?
    
    
    /// Cost associated with traversing the edge joining vertices identified by keys from and to.
    ///
    /// - Parameters:
    ///   - from: origin vertex
    ///   - to: destination vertex
    /// - Returns: The cost of the traversal.
    func weight(from: Vertex.K, to: Vertex.K) -> Weight?
    
    
    /// Creates connections between origin and destination vertices
    ///
    /// - Parameters:
    ///   - originVertex: The origin of the edge
    ///   - destinationVertices: List of destination vertices
    mutating func addEdges(from originVertex: Vertex, to destinationVertices: [(Vertex, Weight)])
    
    
    /// Returns a stack containing a topological sorting according to the implicit sorting of the vertices
    ///
    /// - Parameter graph: graph to be traversed
    /// - Returns: a stack containing a topological sorting according to the implicit sorting of the vertices
    func iterativeTopologicalSort(graph: Self) -> StackBasedOnLinkedList<Self.Vertex>?
    
    
    /// Returns a stack containing a topological sorting according to the implicit sorting of the vertices
    ///
    /// - Parameter graph: graph to be traversed
    /// - Returns: a stack containing a topological sorting according to the implicit sorting of the vertices
    func recursiveTopologicalSort(graph: Self) -> StackBasedOnLinkedList<Self.Vertex>?    
}



// MARK: Basic default implementations

extension Graph {
    
    var vertexCount: Int {
        get {
            return self.vertices.count
        }
        
    }
    
    var edgeCount: Int {
        get {
            return self.edges.count
        }
        
    }
    
    /// Finds a vertex with the given index as its key
    ///
    /// - Parameter index: index to search for
    /// - Returns: a vertex with the sought index or nil if not found
    /// - Complexity: O(N), where N is the number of vertex in the graph. Concrete implemetations
    ///   can improve this time complexity given their knowledge of the internals of the data structure.
    func vertex(withIndex index: Vertex.K) -> Vertex? {
        let findings = self.vertices.filter { (vertex) -> Bool in
            return vertex.key == index
        }
        return findings.first
    }
    
    /// Returns a stack containing a topological sorting according to the implicit sorting of the vertices
    ///
    /// - Parameter graph: graph to be traversed
    /// - Returns: a stack containing a topological sorting according to the implicit sorting of the vertices
    func iterativeTopologicalSort(graph: Self) -> StackBasedOnLinkedList<Self.Vertex>? {
        
        var status = Dictionary<Self.Vertex.K, VertexExplorationStatus>()
        status.populate(keys: graph.vertices.map({ (vertex) -> Vertex.K in
            vertex.key
        }), repeating: .undiscovered)
        let stack = StackBasedOnLinkedList<Self.Vertex>()
        
        // We repeat the algorightm for each undiscovered node, because the graph could be disconnected.
        for vertex in graph.vertices {
            if status[vertex.key] == .undiscovered {
                let success = iterativeTopologicalSortSingleNode(graph: graph, initialVertex: graph.vertex(withIndex: vertex.key)!, stack: stack, status: &status)
                if !success {
                    return nil
                }
            }
        }
        
        return stack
    }
    
    
    /// A topological sorting of the vetices of a graph
    ///
    /// - Parameters:
    ///   - graph: The graph to traverse
    ///   - initialVertex: The indeces of the vertices must be numbered from 0 to (graph.vertexCount - 1)
    ///   - stack: this will contain the results of a topological sort starting at the initialVertex
    ///   - status: each node can be .undiscovered, .discovered, .explored and .processed
    /// - Returns: A boolean indicating the success of the operation. False can mean that it's not a DAG or that loops where found.
    func iterativeTopologicalSortSingleNode<S: Stack>(graph: Self, initialVertex: Self.Vertex, stack: S, status: inout Dictionary<Self.Vertex.K, VertexExplorationStatus>) -> Bool where S.Item == Self.Vertex {
        
        guard graph.directed == true else {
            return false
        }
        
        let explorationStack = StackBasedOnLinkedList<Self.Vertex>()
        
        status[initialVertex.key] = .discovered
        explorationStack.push(item: initialVertex)
        
        while let current = explorationStack.peek(), let state = status[current.key] {
            switch state {
            case .discovered:
                // Discovered means that the node has been added to the explorationStack as part of
                // its parent exploring it's children.
                // We need to explore discovered vertices
                let adjacentVertices = self.adjacentVertices(of: current.key)
                if  adjacentVertices != nil {
                    for adjacent in adjacentVertices! {
                        if (status[adjacent.key] != .processed) && (status[adjacent.key] != .undiscovered) {
                            // Cycle found. Topological sorting will only work on DAGs.
                            //return false
                        }
                        
                        if (status[adjacent.key] != .processed) && (status[adjacent.key] != .explored) {
                            status[adjacent.key] = .discovered
                            explorationStack.push(item: adjacent)
                        }
                    }
                }
                status[current.key] = .explored
                break
                
            case .explored:
                // A vertex is explored when all its adjacent nodes have been processed.
                // We find explored vertices the second time we come back after finishing the children.
                status[current.key] = .processed
                _ = explorationStack.pop()
                stack.push(item: current)
                break
                
            case .processed:
                // Because we iterate, we add things to the stack, that might be re-added through
                // a different path if a cycle is found. by the time we find the vertex again,
                // the status should be processed and there's nothing to do other than removing it.
                _ = explorationStack.pop()
                break
                
            default:
                break
            }
        }
        return true
    }
    
    
    /// Returns a stack containing a topological sorting according to the implicit sorting of the vertices
    ///
    /// - Parameter graph: graph to be traversed
    /// - Returns: a stack containing a topological sorting according to the implicit sorting of the vertices
    func recursiveTopologicalSort(graph: Self) -> StackBasedOnLinkedList<Self.Vertex>? {
        
        var status = Dictionary<Self.Vertex.K, VertexExplorationStatus>()
        status.populate(keys: graph.vertices.map({ (vertex) -> Vertex.K in
            vertex.key
        }), repeating: .undiscovered)
        let stack = StackBasedOnLinkedList<Self.Vertex>()
        
        // We repeat the algorightm for each undiscovered node, because the graph could be disconnected.
        for vertex in graph.vertices {
            if status[vertex.key] == .undiscovered {
                let success = recursiveTopologicalSortSingleNode(graph: graph, initialVertex: graph.vertex(withIndex: vertex.key)!, stack: stack, status: &status)
                if !success {
                    return nil
                }
            }
        }
        
        return stack
    }
    
    
    /// A topological sorting of the vetices of a graph
    ///
    /// - Parameters:
    ///   - graph: The graph to traverse
    ///   - initialVertex: The indeces of the vertices must be numbered from 0 to (graph.vertexCount - 1)
    ///   - stack: this will contain the results of a topological sort starting at the initialVertex
    ///   - status: each node can be .undiscovered, .discovered, .explored and .processed
    /// - Returns: A topological sorting of the graph. Nil if the graph is not directed or contains cycles.
    func recursiveTopologicalSortSingleNode<S: Stack>(graph: Self, initialVertex: Self.Vertex, stack: S, status: inout Dictionary<Self.Vertex.K, VertexExplorationStatus>) -> Bool where S.Item == Self.Vertex {
        
        status[initialVertex.key] = .discovered
        
        if let adjacentVertices = graph.adjacentVertices(of: initialVertex.key) {
            for adjacent in adjacentVertices {
                
                if status[adjacent.key] == .discovered && status[adjacent.key] != .processed {
                    // Cycle found. Topological sorting will only work on DAGs.
                    return false
                }
                
                if (status[adjacent.key] != .discovered) && status[adjacent.key] != .processed {
                    let success = recursiveTopologicalSortSingleNode(graph: graph, initialVertex: adjacent, stack: stack, status: &status)
                    if success == false {
                        return false
                    }
                }
            }
        }
        status[initialVertex.key] = .processed
        stack.push(item: initialVertex)
        return true
    }
}

extension Graph where Vertex.K == Vertex.V, Vertex.K == Weight {
    
    /// Default implementation follows Dijkstra algorithm.
    ///
    /// - Parameters:
    ///   - from: Origin of the path
    ///   - to: Destination of the path
    ///   - minPaths: Data structure to keep the minimum distances found.
    ///   - parent: Data structure to keep track of the predecesors of any given node in the min path.
    ///   - priorityQueue: data structure to efficiently retrieve and update the vertex with the current minimum distance.
    ///   - result: data structure to return the keys of teh vertices in the minimum path.
    /// - Important: Conceptually, this belongs to the Graph protocol, it's not necessary for the Keys to be
    ///   integers for a graph to be able to implement Dijkstra's shortest path algorithm. It is here as a
    ///   simplification, because we would need:
    ///   - a) the weight to be KayValuePair.K so that we could update the priority queue with the result of a summing up keys.
    ///   - b) define a '+' operator on the KeyValuePair.K
    ///   The graph assumes that a vertex's KEY is the IDENTIFIER of the vertex (0, 1, 2, 3....vertices.count)
    ///   This algorithm uses a priority queue, and the queue uses KeyValuePairs. However the meaning is:
    ///    - the queue-element's KEY is the PRIORITY (a path's aggregated weight)
    ///    - the queue-element's VALUE is the IDENTIFIER of the vertex
    ///    => graph-element.KEY == queue-element.VALUE (VERTEX IDENTIFIER)
    ///    => graph-element.VALUE == queue-element.KEY (PRIORITY)
    func shortestPath(from: Self.Vertex, to: Self.Vertex,
                      minPaths:inout Dictionary<Self.Vertex.K, Weight>,
                      parent: inout Dictionary<Self.Vertex.K, Self.Vertex.K>,
                      priorityQueue: BasicBinaryHeap<Self.Vertex>,
                      result: inout [Self.Vertex.K]) {
        
        // Algorithm
        while let current = priorityQueue.dequeue() {
            if let adjacentVertices = self.adjacentVertices(of: current.value) {
                for adjacent in adjacentVertices {
                    let min = Swift.min(minPaths[adjacent.key]!, (minPaths[current.value]! + self.weight(from:current.value, to: adjacent.key)!))
                    if min != minPaths[adjacent.key] {
                        minPaths[adjacent.key] = min
                        priorityQueue.updatePriority(ofValue: adjacent.key, to: min)
                        parent[adjacent.key] = current.value
                    }
                }
            }
        }
        
        // Build the minimum path
        var current: Vertex.K = to.key
        while current != from.key {
            result.append(current)
            current = parent[current]!
        }
        result.append(from.key)
    }
}



extension Dictionary {
    
    mutating func populate(keys: [Key], repeating value: Value) {
        for key in keys {
            self[key] = value
        }
    }
}

