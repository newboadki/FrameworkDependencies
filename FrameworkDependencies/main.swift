//
//  main.swift
//  FrameworkDependencies
//
//  Created by Borja Arias Drake on 09/09/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation


let systemFrameworksPath = "/System/Library/Frameworks/"
let frameworkExtension = ".framework"
let frameworkNameRegularExpression = "([A-Za-z0-9]+)\(frameworkExtension)"

func frameworks() -> [String] {
    let output = shell(launchPath: "/bin/ls", arguments: [systemFrameworksPath]).0
    var frameworks = [String]()
    for line in (output?.components(separatedBy: .newlines))! {
        if let _ = line.range(of: frameworkNameRegularExpression, options: .regularExpression) {
            frameworks.append(line.components(separatedBy: frameworkExtension)[0])
        }
    }
    return frameworks
}

func dependencies(for frameworkName: String) -> [(StringKeyedPair, Int)] {
    let output = shell(launchPath: "/usr/bin/otool", arguments: ["-L", "\(systemFrameworksPath)\(frameworkName)\(frameworkExtension)/\(frameworkName)"]).0
    
    var dependencies = [(StringKeyedPair, Int)]()
    
    for line in (output?.components(separatedBy: .newlines))! {
        if let range = line.range(of: frameworkNameRegularExpression, options: .regularExpression) {
            let foundName = line[range].components(separatedBy: ".")[0]
            if foundName != frameworkName {
                
                let alreadyContained = dependencies.contains(where: { (edge) -> Bool in
                    edge.0.key == foundName
                })
                
                if !alreadyContained {
                    dependencies.append((StringKeyedPair(key: foundName, value: 0), 1)) // Edge's weight == 1
                }
            }
        }
    }
    return dependencies
}

func shell(launchPath: String, arguments: [String] = []) -> (String? , Int32) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    
    return (output, task.terminationStatus)
}

func printTopologicalSortedPath(for framework: String, from graph: AdjacencyListGraph<StringKeyedPair, Int>) {
    print("-- Dependencies of \(framework)")
    let stack = StackBasedOnLinkedList<StringKeyedPair>()
    var status = Dictionary<String, VertexExplorationStatus>()
    status.populate(keys: graph.vertices.map({ (vertex) -> String in
        vertex.key
    }), repeating: .undiscovered)
    let success = graph.iterativeTopologicalSortSingleNode(graph: graph, initialVertex: StringKeyedPair(key: framework, value: 0), stack: stack, status: &status)
    print("Success: \(success), COUNT: \(stack.count())")
    var i = 0
    while let v = stack.pop() {
        print("- \(v.key)")
        i += 1
    }
}

func printDependencies(of frameworkName: String, from graph: AdjacencyListGraph<StringKeyedPair, Int>) {
    print("-- Dependencies of \(frameworkName)")
    let d1 = graph.adjacentVertices(of: frameworkName)
    for v in d1! {
        print("\(v.key)")
    }
}

extension Int: Summable {}

let listOfFrameworks = frameworks()
let vertices = listOfFrameworks.map { (name) -> StringKeyedPair in
    StringKeyedPair(key: name, value: 0)
}
let edges = [(StringKeyedPair, StringKeyedPair, Int)]()

var graph = AdjacencyListGraph<StringKeyedPair, Int>(vertices: vertices, edges: edges, directed: true)

for v in vertices {
    graph.addEdges(from: v, to: dependencies(for: v.key))
}






let stack = graph.iterativeTopologicalSort(graph: graph)
var i = 0
while let v = stack?.pop() {
    print("\(v.key)")
    i += 1
}

