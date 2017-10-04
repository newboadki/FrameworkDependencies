//
//  BasicGraph.swift
//  UnitTests
//
//  Created by Borja Arias Drake on 14/06/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation

/// An edge node and a position in the array 'adjacencyList' represent an edge (a -> b)
/// where:
///   - the origin vertex's KEY comes determined by the index in 'adjacencyList'
///   - and the destination vertex's KEY is defined by EdgeNode.destination.KEY
struct EdgeNode<VertexKeyInfo: KeyValuePair, Weight: Comparable> {
    
    /// Identifier of the
    var destination: VertexKeyInfo
    
    /// Cost of traversing to the destination from the current node.
    /// In an adjacency list this comes defined by a position in the array of vertices.
    var weight: Weight
    
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - destinationVertexKey: destination vertex.
    ///   - weight: cost associated with traversing this edge.
    init(destinationVertexKey: VertexKeyInfo, weight: Weight) {
        self.destination = destinationVertexKey
        self.weight = weight
    }
}



/// This implementation of a graph uses a linked list to keep adjacency information.
/// Finding the first adjacent node of a given vertex takes O(1)
/// Iterating through its neighbours takes O(N)
///
/// This implementaiton assumes that vertices are identified with Integers, this is to be able
/// to efficiently and conviniently index them.
struct AdjacencyListGraph<VertexInfo: KeyValuePair, WeightType: Summable> : Graph {
        
    typealias Vertex = VertexInfo
    typealias Weight = WeightType
    
    
    /// Vertices with which the graph was initialized
    public var vertices: [VertexInfo]
    
    /// Edges with which the graph was initialized
    public var edges: [(from: VertexInfo, to: VertexInfo, weight: Weight)]
    
    /// This is a convenience variable, since a directed gaph is really
    /// implemented here if (a->b) exists but (b->a) does not.
    public var directed: Bool
    
    /// TODO: Not in use.
    private(set) var maxCountOfVertices = 1000
    
    /// Adjancency info for all vertices
    private var adjacencyList: Dictionary<Vertex.K, SinglyLinkedList<EdgeNode<Vertex, Weight>>>
    
    
    
    /// Designated Initializer
    ///
    /// - Parameters:
    ///   - vertices: Array of vertices.
    ///   - edges: Connections between vertices.
    ///   - directed: wether the edges have a direction of traversal.
    init(vertices: [VertexInfo], edges: [(VertexInfo, VertexInfo, Weight)], directed: Bool) {
        self.vertices = vertices.sorted(by: { (p1, p2) -> Bool in
            p1.key < p2.key
        })
        self.edges = edges
        self.directed = true
        self.adjacencyList = AdjacencyListGraph.adjacencyList(fromVertices: vertices, andEdges: edges)
    }
    
    
    /// Convenience initializer
    /// Creates an empty graph
    init() {
        self.edges = [(from: VertexInfo, to: VertexInfo, weight: Weight)]()
        self.vertices = [VertexInfo]()
        self.adjacencyList = Dictionary<Vertex.K, SinglyLinkedList<EdgeNode<VertexInfo, Weight>>>()
        self.directed = false
    }

    
    /// Given a vertex v, its adjacent vertices are those such that:
    /// - Have an edge connecting them in undirected graphs.
    /// - Have a outgoing edge from v to the other vertix.
    ///
    /// - Parameter vertex: Origin vertex.
    /// - Returns: An array of edges.
    /// - Complexity: O(N), where N is v's degree.
    func adjacentVertices(of vertexIndex: Vertex.K) -> [Vertex]? {
        var vertices = [Vertex]()
        
        guard let list = self.adjacencyList[vertexIndex] else {
            return nil
        }
        
        for adjNode in list {
            vertices.append(adjNode.destination)
        }
        
        return vertices
    }
    
    
    /// Cost associated with traversing an edge between two vertices.
    ///
    /// - Parameters:
    ///   - from: Key of the origin vertex
    ///   - to: Key of the destination vertex
    /// - Returns: the cost of traversing the edge joining from and to vertices.
    public func weight(from: Vertex.K, to: Vertex.K) -> Weight? {
        let fromVertexAdjacencyList = self.adjacencyList[from]
        let searchResults = fromVertexAdjacencyList?.filter { (edgeNode) -> Bool in
            return edgeNode.destination.key == to
        }
        return searchResults?.first?.weight
    }
    
    
    /// Creates connections between origin and destination vertices
    ///
    /// - Parameters:
    ///   - originVertex: The origin of the edge
    ///   - destinationVertices: List of destination vertices
    /// - Important: This method does not check for duplicates
    public mutating func addEdges(from originVertex: Vertex, to destinationVertices: [(Vertex, Weight)]) {
        
        for destination in destinationVertices {
            AdjacencyListGraph.addEdge(from: originVertex, to: destination.0, with: destination.1, inDictionary: &self.adjacencyList)
            self.edges.append((from: originVertex, to: destination.0, weight: destination.1))
        }
    }
}



// MARK: Private methods

extension AdjacencyListGraph {
    
    /// Helper method to populate the internal data structures of an adjacency list graph.
    ///
    /// - Parameters:
    ///   - vertices: array of vertices in the graph
    ///   - edges: array of edges in the graph
    /// - Returns: array of linked lists (adjacency list).
    private static func adjacencyList(fromVertices vertices:[VertexInfo], andEdges edges:[(from: VertexInfo, to: VertexInfo, weight: Weight)]) -> Dictionary<Vertex.K, SinglyLinkedList<EdgeNode<VertexInfo, Weight>>> {
        
        var hash = Dictionary<Vertex.K, SinglyLinkedList<EdgeNode<VertexInfo, Weight>>>()
        
        for edge in edges {
            AdjacencyListGraph.addEdge(from: edge.from, to: edge.to, with: edge.weight, inDictionary: &hash)
        }
        
        return hash
    }
    
    /// Creates a connection between two vertices, creating the list if necessary and a node in the list.
    ///
    /// - Parameters:
    ///   - from: Origin vertex
    ///   - to: Destination vertex
    ///   - weight: Edge's weight
    ///   - hash: inout dictionary of adjancecy to modify    
    private static func addEdge(from origin: Vertex, to destination: Vertex, with weight: Weight, inDictionary hash: inout Dictionary<Vertex.K, SinglyLinkedList<EdgeNode<VertexInfo, Weight>>>) {
        var linkedList = hash[origin.key]
        let destinationNode = EdgeNode(destinationVertexKey: destination, weight: weight)
        if linkedList != nil {
            linkedList!.append(value: destinationNode)
        } else {
            linkedList = SinglyLinkedList<EdgeNode<VertexInfo, Weight>>(value: destinationNode)
        }
        hash[origin.key] = linkedList
    }
}



//// MARK: IntegerIndexableGraph

extension AdjacencyListGraph {
    
    /// Finds a vertex with the given index as its key
    ///
    /// - Parameter index: index to search for
    /// - Returns: a vertex with the sought index or nil if not found
    /// - Complexity: O(1)
    func vertex(withIndex index: Int) -> Vertex? {
        return self.vertices[index]
    }
}

