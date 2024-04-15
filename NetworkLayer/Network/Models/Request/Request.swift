//
//  Request.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import Foundation

public typealias ProgressHandler = (Progress) -> Void

public class Request: Responable {
    var urlRequest: URLRequest?
    var data: Data?
    var error: NetworkError?
    var responseCallback: Command<HTTPURLResponse>?
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    init(urlRequest: URLRequest?,
         data: Data?,
         error: NetworkError) {
        self.urlRequest = urlRequest
        self.data = data
        self.error = error
    }
}
