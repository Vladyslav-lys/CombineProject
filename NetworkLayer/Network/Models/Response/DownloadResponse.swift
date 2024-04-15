//
//  DownloadResponse.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 07.09.2022.
//

import Foundation

typealias AsyncDownloadResponse<Success> = DownloadResponse<Success, NetworkError>

struct DownloadResponse<Success, Failure: Error> {
    let urlRequest: URLRequest?
    let response: HTTPURLResponse?
    let destination: DownloadDestination?
    let result: Result<Success, Failure>
    
    var value: Success? { result.success }
    var error: Failure? { result.failure }
    
    init(urlRequest: URLRequest?,
         response: HTTPURLResponse?,
         destination: DownloadDestination?,
         result: Result<Success, Failure>) {
        self.urlRequest = urlRequest
        self.response = response
        self.destination = destination
        self.result = result
    }
}
