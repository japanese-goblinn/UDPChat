import Foundation
import UDPCore
import TSCBasic

print("Welcome to Chat 💬")
print("Inroduce yourself: ", terminator: "")

guard let name = readLine(), !name.isEmpty else { exit(EXIT_FAILURE) }
let client = Client(with: name)
client.register()

while true {
    print(
        """
        \nChat menu 💬:
            1. Message to user
            2. List all users
            3. List all groups
            4. Create group
            5. Leave group
            6. Join group
            7. Message to group

        Press anything to exit... \n
        """
    )
    guard let terminalController = TerminalController(stream: stdoutStream) else { continue }
    terminalController.write("\n\(client.name): ", inColor: .cyan, bold: true)
    guard let read = readLine() else { exit(EXIT_FAILURE) }
    switch read {
    case "1":
        terminalController.write("\n\(client.name) writing to user: ", inColor: .cyan, bold: true)
        guard let str = readLine(), !str.isEmpty else { continue }
        let content = str.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        guard content.count == 2 else {
            print("Bad message formatting")
            continue
        }
        client.send(to: content[0], this: content[1])
    case "2":
        client.allUsers()
    case "3":
        client.allGroups()
    case "4":
        terminalController.write("\n\(client.name) creating group with name: ", inColor: .cyan, bold: true)
        guard let str = readLine(), !str.isEmpty else { continue }
        client.createGroup(name: str)
    case "5":
        terminalController.write("\n\(client.name) leaving group with name: ", inColor: .cyan, bold: true)
        guard let str = readLine(), !str.isEmpty else { continue }
        client.leaveGroup(name: str)
    case "6":
        terminalController.write("\n\(client.name) joining group with name: ", inColor: .cyan, bold: true)
        guard let str = readLine(), !str.isEmpty else { continue }
        client.joinGroup(name: str)
    case "7":
        terminalController.write("\n\(client.name) writing to group: ", inColor: .cyan, bold: true)
        guard let str = readLine(), !str.isEmpty else { continue }
        let content = str.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)
        guard content.count == 2 else {
            print("Bad message formatting")
            continue
        }
        client.sendToGroup(content[0], this: content[1])
    default:
        client.leave()
        print("See ya 👋")
        exit(EXIT_SUCCESS)
    }
    sleep(1)
}

