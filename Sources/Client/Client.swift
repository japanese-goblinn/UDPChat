//
//  Client.swift
//  
//
//  Created by Kirill Gorbachyonok on 3/9/20.
//

import UDPCore
import CocoaAsyncSocket
import TSCBasic

class Client: NSObject {
    
    var name: String
    private let serverPort: UInt16 = 5000
    private let serverIP = "localhost"
    private var listenSocket: GCDAsyncUdpSocket!
    private var groupListenSocket: GCDAsyncUdpSocket!
    private var serverSocket: GCDAsyncUdpSocket!

    init(with name: String) {
        self.name = name
        super.init()
        serverSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.global())
        groupListenSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.global())
        do {
            try groupListenSocket.enableReusePort(true)
            try groupListenSocket.bind(toPort: 5001)
            try groupListenSocket.beginReceiving()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func register() {
        var port: UInt16
        while true {
            port = GeneratorService.randomPort
            do {
                listenSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.global())
                try listenSocket.bind(toPort: port)
                try listenSocket.beginReceiving()
                let data = try JSONEncoder().encode(
                    Register(user: port, with: name)
                )
                send(this: ContentWrapper(of: data, type: .register))
                break
            } catch { continue }
        }
    }
    
    private func join(this group: String) {
        do {
            try groupListenSocket.joinMulticastGroup(group)
            print("Joined to group")
        } catch {
            print("Already joined this group")
        }
    }
    
    private func leave(this group: String) {
        do {
            try groupListenSocket.leaveMulticastGroup(group)
        }  catch {
            print("Failed to leave this group")
        }
    }
    
    func allUsers() {
        let wrapper = ContentWrapper(of: Data(name.utf8), type: .allUsers)
        send(this: wrapper)
    }
    
    func allGroups() {
        let wrapper = ContentWrapper(of: Data(name.utf8), type: .allGroups)
        send(this: wrapper)
    }
    
    func createGroup(name: String) {
        let message = "\(name) \(self.name)"
        let wrapper = ContentWrapper(of: Data(message.utf8), type: .groupRegister)
        send(this: wrapper)
    }
    
    func leaveGroup(name: String) {
        let message = "\(name) \(self.name)"
        let wrap = ContentWrapper(of: Data(message.utf8), type: .groupLeave)
        send(this: wrap)
    }
    
    func joinGroup(name: String) {
        let message = "\(name) \(self.name)"
        let wrap = ContentWrapper(of: Data(message.utf8), type: .groupJoin)
        send(this: wrap)
    }
    
    func leave() {
        let wrapper = ContentWrapper(of: Data(name.utf8), type: .leave)
        send(this: wrapper)
    }
    
    func sendToGroup(_ groupName: String, this message: String) {
        let message = Message(from: name, to: groupName, content: message, type: .toGroup)
        guard let data = try? JSONEncoder().encode(message) else { return }
        let wrapper = ContentWrapper(of: data, type: .regularMessage)
        send(this: wrapper)
    }
    
    func send(to user: String, this content: String) {
        let message = Message(from: name, to: user, content: content, type: .toUser)
        guard let data = try? JSONEncoder().encode(message) else { return }
        let wrapper = ContentWrapper(of: data, type: .regularMessage)
        send(this: wrapper)
    }
    
    func send(this content: ContentWrapper) {
        guard let data = try? JSONEncoder().encode(content) else { return }
        send(this: data)
    }
    
    func send(this data: Data) {
        serverSocket.send(data, toHost: serverIP, port: serverPort, withTimeout: -1, tag: 0)
    }
        
    func send(this message: String) {
        let data = Data(message.utf8)
        serverSocket.send(data, toHost: serverIP, port: serverPort, withTimeout: -1, tag: 0)
    }
}

extension Client: GCDAsyncUdpSocketDelegate {
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let decoder = JSONDecoder()
        do {
            guard let terminalController = TerminalController(stream: stdoutStream) else { return }
            let content = try decoder.decode(ContentWrapper.self, from: data)
            switch content.type {
            case .regularMessage:
                let message = try decoder.decode(Message.self, from: content.data)
                switch message.type {
                case .toUser:
                    terminalController.moveCursor(up: 1)
                    terminalController.write("\n\(message.from): \(message.content)", inColor: .red, bold: true)
                    terminalController.endLine()
                    terminalController.write("\n\(name): ", inColor: .cyan, bold: true)
                case .toGroup:
                    guard message.from != name else { return }
                    terminalController.moveCursor(up: 1)
                    terminalController.write("\n\(message.to): \(message.content)", inColor: .green, bold: true)
                    terminalController.endLine()
                    terminalController.write("\n\(name): ", inColor: .cyan, bold: true)
                }
            case .groupSuccessRegister:
                let groupIP = String(decoding: content.data, as: UTF8.self)
                join(this: groupIP)
            case .groupLeave:
                let groupIP = String(decoding: content.data, as: UTF8.self)
                leave(this: groupIP)
                print("You left this group")
            case .groupJoin:
                let groupIP = String(decoding: content.data, as: UTF8.self)
                join(this: groupIP)
            default:
                return
            }
        } catch {
            print(String(decoding: data, as: UTF8.self))
        }
    }
}
