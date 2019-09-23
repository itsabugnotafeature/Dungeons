//
//  TCPConnections.swift
//  Dungeons
//
//  Created by Max Sonderegger on 9/18/19.
//  Copyright © 2019 Max Sonderegger. All rights reserved.
//

import Foundation

typealias SocketFileDescriptor = Int32

struct SocketData: CustomStringConvertible {
    
    let swiftString: String
    let cString: [CChar]
    var description: String
    
    init?(response: String) {
        swiftString = response
        description = response
        if let cString = response.cString(using: .utf8) {
            self.cString = cString
        } else {
            return nil
        }
    }
    
    init(response: [CChar]) {
        cString = response
        swiftString = String(cString: response)
        description = swiftString
    }
}

class TCPIPV4Socket {
    var address: IPV4Address?
    let socket_fd: SocketFileDescriptor
    
    init?() {
        socket_fd = socket(AF_INET, SOCK_STREAM, 0)
        if socket_fd < 0 {
            return nil
        }
    }
    
    @discardableResult func setSocketOption(level: Int32, optionName: Int32, optionValue: Int) -> Bool {
        var localInt = optionValue
        return setsockopt(socket_fd, level, optionName, &localInt, UInt32(MemoryLayout<Int>.size)) == 0
    }
    
    @discardableResult func bind(address: IPV4Address) -> Bool {
        var localAddress = address
        return Darwin.bind(socket_fd, &localAddress.c_sockaddr, localAddress.addrlen) == 0
    }
    
    @discardableResult func bind(sockaddr_in: sockaddr_in) -> Bool {
        var localAddress = sockaddr_in
        var localAddress_sockaddr = UnsafeRawPointer(&localAddress).bindMemory(to: sockaddr.self, capacity: 1).pointee
        return Darwin.bind(socket_fd, &localAddress_sockaddr, UInt32(MemoryLayout<sockaddr_in>.size)) == 0
    }
    
    @discardableResult func bind(to newAddress: IPV4Address) -> Bool {
        var localAddress = newAddress
        return Darwin.bind(socket_fd, &localAddress.c_sockaddr, localAddress.addrlen) == 0
    }
    
    @discardableResult func listen(withBacklog queueSize: Int32) -> Bool {
        return Darwin.listen(socket_fd, queueSize) == 0
    }
    
    func accept() -> Connection? {
        let newSocket: SocketFileDescriptor
        var newSockAddr = sockaddr()
        var newSockAddrLength = UInt32(MemoryLayout<sockaddr>.size)
        newSocket = Darwin.accept(socket_fd, &newSockAddr, &newSockAddrLength)
        
        if newSocket < 0 {
            return nil
        } else {
            let newSockAddr = UnsafeRawPointer(&newSockAddr).bindMemory(to: sockaddr_in.self, capacity: 1).pointee
            return Connection(socket_fd: newSocket, sockaddr_in: newSockAddr)
        }
    }
    
    func connect(address: IPV4Address) -> Connection? {
        var localAddress = address
        
        if Darwin.connect(socket_fd, &localAddress.c_sockaddr, localAddress.addrlen) < 0 {
            return nil
        } else {
            return Connection(socket_fd: socket_fd, address: localAddress)
        }
    }
    
    func close() {
        Darwin.close(socket_fd)
    }
}

class Connection {
    let socket_fd: SocketFileDescriptor
    let sockaddr_in: sockaddr_in
    var valread: Int = 0
    private var buffer = Array<CChar>(repeating: 0, count: 1024)
    
    init(socket_fd: SocketFileDescriptor, sockaddr_in: sockaddr_in) {
        self.socket_fd = socket_fd
        self.sockaddr_in = sockaddr_in
    }
    
    init(socket_fd: SocketFileDescriptor, address: IPV4Address) {
        self.socket_fd = socket_fd
        self.sockaddr_in = address.c_sockaddr_in
    }
    
    func recv() -> SocketData {
        Darwin.recv(socket_fd, &buffer, 1024, 0)
        return SocketData(response: buffer)
    }
    
    @discardableResult func send(_ data: String) -> Int {
        guard let cString = data.cString(using: .utf8) else {
            return -1;
        }
        return Darwin.send(socket_fd, cString, strlen(cString), 0)
    }
    
    @discardableResult func send(_ data: SocketData) -> Int {
        return Darwin.send(socket_fd, data.cString, strlen(data.cString), 0)
    }
    
    func close() {
        Darwin.close(socket_fd)
    }
}

class TCPServer {
    
}
