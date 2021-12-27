//
//  Socket.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 9/14/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

typealias ReceivedRequestCallback = ((Request, Socket) -> Bool)

enum SocketErrors: Swift.Error {
    case ListenError
    case PortUsedError
}

protocol SocketServer {

    func startOnPort(_: Int) throws
    func disconnect()
    
    var receivedRequestCallback: ReceivedRequestCallback? { get set }
}

protocol Socket {
    func sendData(data: NSData)
}

// Mark: SwiftSocket Implementation of the Socket and SocketServer protocol


import SwiftSockets
import Dispatch
import Foundation


struct SwiftSocket: Socket {
    
    let socket: ActiveSocketIPv4
    
    func sendData(data: NSData) {
        (data as Data).withUnsafeBytes { ptr in
            let data = DispatchData(bytes: ptr)
            socket.write(data: data)
            socket.close()
        }
    }
}

class SwiftSocketServer: SocketServer {
    
    var socket: PassiveSocketIPv4!
    
    var receivedRequestCallback: ReceivedRequestCallback?
    
    func startOnPort(_ p: Int) throws {
        
        guard let socket = PassiveSocketIPv4(address: sockaddr_in(port: p)) else { throw SocketErrors.ListenError }
        socket.listen(queue: DispatchQueue.global()) {
            socket in
            
            socket.onRead {
                newsock, length in
                
                socket.isNonBlocking = true
                
                var initialData: NSData?
                var bodyData: NSData?
                
                let (size, data, _) = newsock.read()
                
                if size > 0 {
                    initialData = NSData(bytes: data, length: size)
                }
                
                if let initialData = initialData {
                    let request = Request(headerData: initialData)
                    
                    // Initial data may not contain body
                    // Check if request contains a body, and that it hasn't been read yet
                    if let lengthString = request.headers["Content-Length"],
                       let length = UInt(lengthString), length > 0 && request.bodyString == nil {
                            
                            let (bSize, bData, _) = newsock.read()
                            
                            if bSize > 0 {
                                bodyData = NSData(bytes: bData, length: bSize)
                                request.parseBodyData(bodyData)
                            }
                    }
                    
                    self.receivedRequestCallback?(request, SwiftSocket(socket: socket))
                }
            }
        }
        
        self.socket = socket
    }
    
    func disconnect() {
        self.socket.close()
    }
}
