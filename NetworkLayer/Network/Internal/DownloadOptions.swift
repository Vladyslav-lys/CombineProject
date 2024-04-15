//
//  DownloadOptions.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 02.09.2022.
//

import Foundation

public typealias DownloadDestination = (_ temporaryURL: URL,
                                        _ response: HTTPURLResponse) -> (destinationURL: URL,
                                                                         options: Set<DownloadOptions>)

public enum DownloadOptions: Int {
    case createIntermediateDirectories, removePreviousFile
}
