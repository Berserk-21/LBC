//
//  URLProtocolMock.swift
//  LBCTests
//
//  Created by Berserk on 30/05/2024.
//

import Foundation

class URLProtocolMock: URLProtocol {
    
    static var testURLs = [URL?: Data]()
    static var loadingHandler: ((URLRequest) -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let url = request.url, let handler = URLProtocolMock.loadingHandler {
            let (response, data) = handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } else if let data = URLProtocolMock.testURLs[request.url] {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
}
