//
//  File.swift
//  
//
//  Created by Kirill Gorbachyonok on 3/8/20.
//

import Foundation

public struct Register: Codable {
    
    public let user: User
    public let name: String
    
    public init(user: User, with name: String) {
        self.user = user
        self.name = name
    }
}

public extension Register {
    typealias User = UInt16
}

