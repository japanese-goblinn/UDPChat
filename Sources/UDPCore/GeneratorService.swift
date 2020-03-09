//
//  File.swift
//  
//
//  Created by Kirill Gorbachyonok on 3/6/20.
//

import Foundation

public class GeneratorService {
    public static var randomPort: UInt16 {
        UInt16((3000..<5000).lazy.randomElement()!)
    }
    
    public static var randomMulticastIP: String {
        "\((225...239).randomElement()!).\((0...225).randomElement()!).\((0...225).randomElement()!).\((0...225).randomElement()!)"
    }
}

