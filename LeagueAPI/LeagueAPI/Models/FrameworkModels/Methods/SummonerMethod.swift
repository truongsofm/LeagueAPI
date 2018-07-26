//
//  SummonerMethod.swift
//  LeagueAPI
//
//  Created by Antoine Clop on 7/26/18.
//  Copyright © 2018 Antoine Clop. All rights reserved.
//

import Foundation

public class SummonerMethod: LeagueMethod {

    public enum SummonerMethods {
        case ByAccountId(id: Double)
        case ByName(name: String)
        case ById(id: Double)
    }
    
    private var service: ServiceProxy
    private var method: SummonerMethods
    
    public init(method: SummonerMethods, region: Region) {
        self.method = method
        self.service = ServiceProxy(for: region)
    }
    
    public func getMethodSignature() -> String {
        switch self.method {
        case .ByAccountId:
            return "SummonerByAccountId"
        case .ByName, .ById:
            return "SummonerBy-\(self.service.region.rawValue)"
        }
    }
    
    public func getMethodUrl() -> String {
        return ""
    }
}
