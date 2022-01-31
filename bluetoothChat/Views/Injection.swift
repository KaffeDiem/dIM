//
//  Injection.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 31/01/2022.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { SetupViewModel(context: Resolver.resolve()) }
    }
}
