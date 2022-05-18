//
//  Encodable+Dictionary.swift
//  Miqi
//
//  Created by Elena Gordienko on 27.03.2022.
//

import Foundation

public extension Encodable {
    func asDictionary(encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
        let data = try? encoder.encode(self)
        guard
            let data = data,
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                as? [String: Any]
        else { return [:] }
        return dictionary
    }
}
