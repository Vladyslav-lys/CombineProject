//
//  Network+Header.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 05.09.2022.
//

import Foundation

extension HTTPHeader {
    static func accept(contentTypes: [String]) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: contentTypes.joined(separator: ", "))
    }
    
    static var defaultAccept: HTTPHeader {
        accept(contentTypes: ["application/json"])
    }
}
