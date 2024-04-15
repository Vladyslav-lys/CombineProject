//
//  API+Certificates.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

extension API {
    public enum Users: RequestConvertible {
        case getUsers(params: [String: Any])
        case uplaod(params: [String: Any])
        case download(destination: DownloadDestination)
        
        public var path: String {
            switch self {
            case .getUsers:
                return "api/"
            case .uplaod:
                return "post"
            case .download:
                return "84e496cd-b0c6-4802-9b1c-24d855387c94.jpeg"
            }
        }
        
        public var method: HTTPMethod {
            switch self {
            case .getUsers, .download:
                return .get
            case .uplaod:
                return .post
            }
        }
        
        public var task: Network.Task {
            switch self {
            case .getUsers(let params):
                return .requestCompositeParameters(bodyParameters: [:],
                                                   bodyEncoding: .url(.default),
                                                   urlParameters: params)
            case .uplaod(let params):
                return .uploadMultipart {
                    guard let data = params["data"] as? Data,
                          let name = params["name"] as? String,
                          let mimeType = params["mimeType"] as? String,
                          let fileExtension = params["fileExtension"] as? String else {
                              return
                          }
                    $0.append(data,
                              withName: "file",
                              fileName: "\(name).\(fileExtension)",
                              mimeType: mimeType)
                }
            case .download(let destination):
                return .downloadDestination(destination)
            }
        }
    }
}
