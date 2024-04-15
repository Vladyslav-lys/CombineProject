//
//  AsyncTask.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Combine

public typealias AsyncTask<T> = AnyPublisher<T, AppError>
