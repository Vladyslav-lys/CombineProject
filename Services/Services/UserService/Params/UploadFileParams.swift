//
//  UploadFileParams.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 06.10.2022.
//

import Foundation

public struct UploadFileParams {
    enum CodingKeys: String, CodingKey {
        case data, name, mimeType, fileExtension
    }
    
    var data: Data
    var name: String
    var mimeType: String
    var fileExtension: String
    
    public init(data: Data, name: String, mimeType: String, fileExtension: String) {
        self.data = data
        self.name = name
        self.mimeType = mimeType
        self.fileExtension = fileExtension
    }
    
    public var parameters: [String: Any] {
        [
            CodingKeys.data.rawValue: data,
            CodingKeys.name.rawValue: name,
            CodingKeys.mimeType.rawValue: mimeType,
            CodingKeys.fileExtension.rawValue: fileExtension
        ]
    }
}
