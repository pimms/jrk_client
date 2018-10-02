//
//  Data+toMap.swift
//  roiclient
//
//  Created by pimms on 24/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

extension Data {
    func toMap() -> [String: AnyObject] {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: []) as! [String: AnyObject]
            return json
        } catch let err {
            print("failed to deserialize json: \(err)")
            return [:]
        }
    }
}
