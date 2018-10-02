//
//  WeakRef.swift
//  roiclient
//
//  Created by pimms on 25/09/2018.
//  Copyright © 2018 pimms. All rights reserved.
//

import Foundation

class WeakRef<T> where T: AnyObject {
    private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
}
