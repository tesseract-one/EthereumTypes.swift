//
//  APIRegistry.swift
//  EthereumTypes
//
//  Created by Yehor Popovych on 3/29/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

// Place for Instance API registration
public protocol InstanceAPIRegistry {
    var signProvider: SignProvider { get }
}

// Place for Module API registration
public protocol ModuleAPIRegistry {
    var signProvider: SignProvider { get }
}

// Struct for API registration handling
public struct APIRegistry: InstanceAPIRegistry, ModuleAPIRegistry {
    public let signProvider: SignProvider
    
    public init(signProvider: SignProvider) {
        self.signProvider = signProvider
    }
}
