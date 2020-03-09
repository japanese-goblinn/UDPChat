//
//  Server.swift
//  
//
//  Created by Kirill Gorbachyonok on 3/9/20.
//

import UDPCore
import CocoaAsyncSocket

class Server: NSObject {
    
    private let internalQueue = DispatchQueue(label: "com.japanese-goblinn.server")
    private var socket: GCDAsyncUdpSocket!
    private let ip = "localhost"
    
    private var users = [String : Register.User]()
    private var allUsers: String {
        users.keys.enumerated().map { "\($0.offset + 1). \($0.element)\n" }.reduce("", +)
    }
    
    private var groups = [String : String]()
    private func isGroupExist(ip: String) -> Bool { groups.values.contains(ip) }
    private func isGroupExist(name: String)-> Bool { groups.keys.contains(name) }
    private var allGroups: String {
        groups.keys.enumerated().map { "\($0.offset + 1). \($0.element)\n" }.reduce("", +)
    }

    override init() {
        super.init()
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: internalQueue)
        do {
            try socket.bind(toPort: 5000)
            try socket.beginReceiving()
        } catch {
            print(error.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
        
    private func send(this message: String, to port: Register.User) {
        let messageData = Data(message.utf8)
        socket.send(messageData, toHost: ip, port: port, withTimeout: -1, tag: 0)
    }
    
    private func send(this data: Data, to port: Register.User) {
        socket.send(data, toHost: ip, port: port, withTimeout: -1, tag: 0)
    }
}

extension Server: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let decoder = JSONDecoder()
        let content = try! decoder.decode(ContentWrapper.self, from: data)
        switch content.type {
        case .register:
            let register = try! decoder.decode(Register.self, from: content.data)
            users[register.name] = register.user
        case .leave:
            let username = String(decoding: content.data, as: UTF8.self)
            users[username] = nil
        case .groupRegister:
            let input = String(decoding: content.data, as: UTF8.self).components(separatedBy: .whitespaces)
            let (groupName, fromUser) = (input[0], input[1])
            guard let user = users[fromUser] else { return }
            guard !isGroupExist(name: groupName) else {
                send(this: "Group '\(groupName)' already exist", to: user)
                return
            }
            send(this: "Group '\(groupName)' was created", to: user)
            while true {
                let ip = GeneratorService.randomMulticastIP
                if !isGroupExist(ip: ip) {
                    groups[groupName] = ip
                    let wrapper = ContentWrapper(of: Data(ip.utf8), type: .groupSuccessRegister)
                    guard let data = try? JSONEncoder().encode(wrapper) else { return }
                    send(this: data, to: user)
                    break
                } else {
                    continue
                }
            }
        case .groupLeave:
            let input = String(decoding: content.data, as: UTF8.self).components(separatedBy: .whitespaces)
            let (groupName, fromUser) = (input[0], input[1])
            guard let user = users[fromUser], let group = groups[groupName] else { return }
            let wrap = ContentWrapper(of: Data(group.utf8), type: .groupLeave)
            guard let encoded = try? JSONEncoder().encode(wrap) else { return }
            send(this: encoded, to: user)
        case .groupJoin:
            let input = String(decoding: content.data, as: UTF8.self).components(separatedBy: .whitespaces)
            let (groupName, fromUser) = (input[0], input[1])
            guard let user = users[fromUser], let group = groups[groupName] else { return }
            let wrap = ContentWrapper(of: Data(group.utf8), type: .groupJoin)
            guard let encoded = try? JSONEncoder().encode(wrap) else { return }
            send(this: encoded, to: user)
        case .regularMessage:
            let message = try! decoder.decode(Message.self, from: content.data)
            switch message.type {
            case .toUser:
                guard
                    let toUser = users[message.to],
                    let fromUser = users[message.from]
                else {
                    send(this: "User is not exists", to: users[message.from]!)
                    return
                }
                send(this: data, to: toUser)
                send(this: "✅ Recived", to: fromUser)
            case .toGroup:
                guard let toGroup = groups[message.to] else {
                    send(this: "Group is not exists", to: users[message.from]!)
                    return
                }
                let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: internalQueue)
                do {
                    try socket.enableReusePort(true)
                    try socket.bind(toPort: 5001)
                    try socket.connect(toHost: toGroup, onPort: 5001)
                    socket.send(data, toHost: toGroup, port: 5001, withTimeout: -1, tag: 0)
                } catch {
                    print(error.localizedDescription)
                }
            }
        case .allUsers:
            let username = String(decoding: content.data, as: UTF8.self)
            guard let user = users[username] else { return }
            send(this: "\nList of all users:\n" + allUsers, to: user)
        case .allGroups:
            let username = String(decoding: content.data, as: UTF8.self)
            guard let user = users[username] else { return }
            if allGroups.isEmpty {
                send(this: "\nNo groups available\n", to: user)
            } else {
                send(this: "\nList of all groups:\n" + allGroups, to: user)
            }
        default:
            return
        }
    }
}
