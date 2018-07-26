//
//  APIKey.swift
//  LeagueAPI
//
//  Created by Antoine Clop on 7/26/18.
//  Copyright © 2018 Antoine Clop. All rights reserved.
//

import Foundation

internal class APIKey {
    
    public var token: String
    public var appRateLimit: String
    public var methodLimits: Dictionary<String, String>
    
    public init(token: String, appRateLimit: String = "", methodLimits: Dictionary<String, String>? = nil) {
        self.token = token
        self.appRateLimit = appRateLimit
        self.methodLimits = methodLimits ?? Dictionary()
    }
}