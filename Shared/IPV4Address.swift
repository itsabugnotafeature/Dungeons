//
//  IPV4Address.swift
//  Dungeons
//
//  Created by Max Sonderegger on 9/17/19.
//  Copyright © 2019 Max Sonderegger. All rights reserved.
//

import Foundation

struct IPV4Address {
    let address: String
    let port: UInt16
    //Both point to the same struct, but have different types
    var c_sockaddr: sockaddr
    var c_sockaddr_in: sockaddr_in
    
    let addrlen = UInt32(MemoryLayout<sockaddr_in>.size)
    
    init?(address: String, port: UInt16) {
        self.address = address
        self.port = port
        var addr = sockaddr_in()
        if address == "INADDR_ANY" {
            addr.sin_addr.s_addr = INADDR_ANY
        } else {
            if var cString = address.cString(using: .utf8) {
                if (inet_pton(AF_INET, &cString, UnsafeMutableRawPointer(mutating: UnsafePointer<in_addr>(&addr.sin_addr))) != 1) {
                    print("Invalid address: \(address)")
                    return nil
                }
            }
        }
        addr.sin_port = port.bigEndian
        addr.sin_family = UInt8(AF_INET).bigEndian
        
        c_sockaddr_in = addr
        c_sockaddr = UnsafeRawPointer(&c_sockaddr_in).bindMemory(to: sockaddr.self, capacity: 1).pointee
    }
    
    init(address c_sockaddr_in: sockaddr_in) {
        self.address = String(cString: inet_ntoa(c_sockaddr_in.sin_addr))
        port = c_sockaddr_in.sin_port.bigEndian
        
        self.c_sockaddr_in = c_sockaddr_in
        c_sockaddr = UnsafeRawPointer(&self.c_sockaddr_in).bindMemory(to: sockaddr.self, capacity: 1).pointee
    }
}
