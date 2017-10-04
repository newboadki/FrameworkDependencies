//
//  KeyValuePairsConcreteTypes.swift
//  UnitTests
//
//  Created by Borja Arias Drake on 16/09/2017.
//  Copyright © 2017 Borja Arias Drake. All rights reserved.
//

import Foundation


/// Concrete impletation of a KeyValuePair where  both the key and the value
/// are Integers.
struct IntegerPair : KeyValuePair {
    
    // MARK - KeyValuePair protocol
    var key : Int
    var value : Int
    
    func copy() -> IntegerPair {
        return IntegerPair(key: self.key, value: self.value)
    }
}


struct StringKeyedPair : KeyValuePair {
    
    // MARK - KeyValuePair protocol
    var key : String
    var value : Int
    
    func copy() -> StringKeyedPair {
        return StringKeyedPair(key: self.key, value: self.value)
    }
}
