//
//  TypeExtensions.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 25/07/2021.
//

import Foundation

extension String {
    var fixedBase64Format: Self {
        let offset = count % 4
        guard offset != 0 else { return self }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
}
