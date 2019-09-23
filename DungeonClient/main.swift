//
//  main.swift
//  Dungeons
//
//  Created by Max Sonderegger on 8/29/19.
//  Copyright © 2019 Max Sonderegger. All rights reserved.
//
import Foundation

//var sock: Int32 = 0;
//var valread = 0;
//var serv_addr = sockaddr_in()
//var msg = "Hello from client😊"
//var buffer = Array<UInt8>(repeating: 0, count: 1024)
//var struct_serv_addr = IPV4Address(address: "127.0.0.1", port: 8080)!
//
//sock = socket(AF_INET, SOCK_STREAM, 0)
//if sock < 0 {
//    print("Socket creation error")
//    exit(EXIT_FAILURE)
//}
//
//serv_addr.sin_family = UInt8(AF_INET)
//serv_addr.sin_port = UInt16(8080).bigEndian
//print(UInt16(8080).bigEndian)
//
//// Convert IPv4 and IPv6 addresses from text to binary form
//if inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0 {
//    print("Invalid address/ Address not supported")
//    exit(EXIT_FAILURE)
//}
//
//var sockaddr_p = UnsafeRawPointer(UnsafePointer<sockaddr_in>(&serv_addr)).bindMemory(to: sockaddr.self, capacity: 1)
//if connect(sock, &struct_serv_addr.c_sockaddr, UInt32(MemoryLayout<sockaddr_in>.size)) < 0 {
//    print("Connection Failed");
//    exit(EXIT_FAILURE)
//}
//
//var msgCstring = msg.cString(using: .utf8)
//send(sock , msgCstring , strlen(msgCstring!) , 0 )
//print("Hello message sent")
//valread = recv( sock , &buffer, 1024, 0)
//print(String(cString: Array(buffer)))
//close(sock)
guard let clientSocket = TCPIPV4Socket() else {
    perror("Failed to make socket")
    exit(EXIT_FAILURE)
}

guard let serverAddress = IPV4Address(address: "127.0.0.1", port: 8080) else {
    perror("Failed to make address")
    exit(EXIT_FAILURE)
}

guard let connection = clientSocket.connect(address: serverAddress) else {
    perror("Failed to connect to server")
    exit(EXIT_FAILURE)
}

print("Connected to \(serverAddress.address):\(serverAddress.port)")

if connection.send("Hello from client😊") < 0 {
    perror("Failed to send")
}

let response = connection.recv()
print(response)
connection.close()
