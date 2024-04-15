//
//  Network+Task.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 30.08.2022.
//

import Foundation

extension Network {
    public enum Task {
        case requestPlain
        case requestData(Data)
        case requestCompositeData(bodyData: Data, urlParameters: Parameters)
        case requestCompositeParameters(bodyParameters: Parameters,
                                        bodyEncoding: ParameterEncoding,
                                        urlParameters: Parameters = [:])
        case uploadMultipart(MultipartFormDataBuilder)
        case uploadCompositeMultipart(urlParameters: Parameters, MultipartFormDataBuilder)
        case downloadDestination(DownloadDestination)
        case downloadParameters(parameters: Parameters,
                                encoding: ParameterEncoding,
                                destination: DownloadDestination)
    }
}
