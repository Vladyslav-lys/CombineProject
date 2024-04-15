//
//  User+Response.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

extension User {
    struct Response: Decodable {
        let name: Name
        let gender: String
        let email: String
    }
}

extension User {
    init(from response: Response) {
        name = response.name
        gender = response.gender
        email = response.email
        comments = []
    }
}
