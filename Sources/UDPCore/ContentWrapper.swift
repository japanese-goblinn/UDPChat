//
//  ContentWrapper.swift
//  
//
//  Created by Kirill Gorbachyonok on 3/8/20.
//

import Foundation

public struct ContentWrapper: Codable {
    
    public let type: ContentType
    public let data: Data
    
    public init(of data: Data, type: ContentType) {
        self.data = data
        self.type = type
    }
}

public extension ContentWrapper {
    enum ContentType: String, Codable {
        case register
        case leave
        case groupRegister
        case groupJoin
        case groupSuccessRegister
        case groupLeave
        case regularMessage
        case allUsers
        case allGroups
    }
}
