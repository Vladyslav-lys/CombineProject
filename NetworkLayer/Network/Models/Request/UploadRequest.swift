//
//  UploadRequest.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 06.09.2022.
//

import Foundation

class UploadRequest: DataRequest {
    let multipartFormData: MultipartFormData
    let fileManager: FileManager
    let uploadProgress = Progress(totalUnitCount: 0)
    var uploadProgressCallback: Command<Progress>?
    
    init(urlRequest: URLRequest, multipartFormData: MultipartFormData, fileManager: FileManager) {
        self.multipartFormData = multipartFormData
        self.fileManager = fileManager
        super.init(urlRequest: urlRequest)
    }
    
    func uploadProgress(queue: DispatchQueue = .main, closure: @escaping ProgressHandler) -> Self {
        uploadProgressCallback = Command { progress in
            closure(progress)
        }
        return self
    }
    
    func updateUploadProgress(totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadProgress.totalUnitCount = totalBytesExpectedToSend
        uploadProgress.completedUnitCount = totalBytesSent

        uploadProgressCallback?.perform(value: uploadProgress)
    }
    
    func getUrlRequest() throws -> URLRequest {
        guard var urlRequest = urlRequest else { throw NetworkError.missingUrl }
        let data = try multipartFormData.encode()
        urlRequest.setValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data
        return urlRequest
    }
}
