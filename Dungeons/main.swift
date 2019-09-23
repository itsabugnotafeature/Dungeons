//
//  main.swift
//  Dungeons
//
//  Created by Max Sonderegger on 8/30/19.
//  Copyright © 2019 Max Sonderegger. All rights reserved.
//
import Foundation

guard let serverSocket = TCPIPV4Socket() else {
    perror("Error creating socket")
    exit(EXIT_FAILURE)
}

guard let serverAddress = IPV4Address(address: "INADDR_ANY", port: 8080) else {
    print("Error creating address")
    exit(EXIT_FAILURE)
}

serverSocket.setSocketOption(level: SOL_SOCKET, optionName: SO_REUSEADDR, optionValue: 1)

serverSocket.bind(to: serverAddress)

serverSocket.listen(withBacklog: 5)

print("Listening on \(serverAddress.address):\(serverAddress.port)")

guard let connection = serverSocket.accept() else {
    perror("Failed to accept")
    exit(EXIT_FAILURE)
}


let clientAddress = IPV4Address(address: connection.sockaddr_in)
print("Connected to \(clientAddress.address):\(clientAddress.port)")

var data = connection.recv()
print(data.swiftString)
connection.send("Hello from server")
connection.close()
print("Closed connection to \(clientAddress.address):\(clientAddress.port)")
//print("Closed conn")

serverSocket.close()
print("Closed server to \(clientAddress.address):\(clientAddress.port)")
//print("Closed server")
