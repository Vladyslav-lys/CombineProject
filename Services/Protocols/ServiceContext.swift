//
//  ServiceContext.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer

public protocol ServiceContext {
    var network: Network { get }
}
