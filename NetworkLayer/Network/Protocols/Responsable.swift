//
//  Responsable.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 09.09.2022.
//

import Foundation

protocol Responable {
    associatedtype Response
    var responseCallback: Command<Response>? { get set }
}
