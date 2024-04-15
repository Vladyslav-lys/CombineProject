//
//  LimitOffset.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

public struct LimitOffset {
    static let defaultLimit = 10

    enum CodingKeys: String, CodingKey {
        case offset
        case limit
    }

    var offset: Int
    var limit: Int
    var total: Int

    init(offset: Int = 0, limit: Int = defaultLimit, total: Int = -1) {
        self.offset = offset
        self.limit = limit
        self.total = total
    }

    var parameters: [String: Any] {
        let dict: [String: Any] = [CodingKeys.offset.stringValue: offset,
                                   CodingKeys.limit.stringValue: limit]
        return dict
    }

    var isFirstPage: Bool {
        offset == 0
    }
    
    var hasMore: Bool {
        isFirstPage || total > offset
    }
    
    mutating func reset() {
        offset = 0
    }
}

extension LimitOffset {
    public struct Response: Decodable {
        enum CodingKeys: String, CodingKey {
            case totalCount
            case nextOffset
            case limit
        }

        let totalCount: Int
        let nextOffset: Int
        let limit: Int?

        var hasMore: Bool {
            totalCount > nextOffset
        }
    }

    init(_ response: Response) {
        self.init(offset: response.nextOffset, limit: response.limit ?? LimitOffset.defaultLimit, total: response.totalCount)
    }
}
