//
//  URLProtocolMock.swift
//  LBCTests
//
//  Created by Berserk on 30/05/2024.
//

import Foundation

class URLProtocolMock: URLProtocol {
    
    // For static responses with predefined data.
    static var testURLs = [URL?: Data]()
    
    // For Dynamic responses based on the URLRequest properties.
    static var loadingHandler: ((URLRequest) -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let handler = URLProtocolMock.loadingHandler {
            let (response, data) = handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } else if let data = URLProtocolMock.testURLs[request.url] {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        print("stopLoading")
    }
}
