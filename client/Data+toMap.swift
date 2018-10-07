//
//  Data+toMap.swift
//  roiclient
//
//  Created by pimms on 24/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

extension Data {
    func deserializeAsJson() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
}
