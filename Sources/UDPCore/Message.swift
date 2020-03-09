//
//  File.swift
//  
//
//  Created by Kirill Gorbachyonok on 3/8/20.
//

import Foundation

public struct Message: Codable {
    
    public let type: MessageType
    public let from: String
    public let to: String
    public let content: String
    
    public init(from: String, to: String, content: String, type: MessageType) {
        self.from = from
        self.to = to
        self.content = content
        self.type = type
    }
}

public extension Message {
    enum MessageType: String, Codable {
        case toUser
        case toGroup
    }
}

