//
//  DataResponse.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 07.09.2022.
//

import Foundation

typealias AsyncDataResponse<Success> = DataResponse<Success, NetworkError>

struct DataResponse<Success, Failure: Error> {
    let request: URLRequest?
    let response: HTTPURLResponse?
    let data: Data?
    let result: Result<Success, Failure>
    
    var value: Success? { result.success }
    var error: Failure? { result.failure }
    
    init(request: URLRequest?,
         response: HTTPURLResponse?,
         data: Data?,
         result: Result<Success, Failure>) {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}
