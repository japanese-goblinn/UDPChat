import CocoaAsyncSocket

class Server: NSObject, GCDAsyncUdpSocketDelegate {
    
    var socket: GCDAsyncUdpSocket!
    let inernalQueue = DispatchQueue(label: "com.japanese-goblinn.server")
    
    override init() {
        super.init()
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: inernalQueue)
        do {
            try socket.enableReusePort(true)
            try socket.bind(toPort: 5000)
            try socket.beginReceiving()
        } catch {
            print(error.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print(String(decoding: data, as: UTF8.self))
    }
}

let server = Server()
print("✨ Server is running... ✨")
while true {
    sleep(20)
}
