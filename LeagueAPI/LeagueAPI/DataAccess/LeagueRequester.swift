//
//  LeagueRequester.swift
//  LeagueAPI
//
//  Created by Antoine Clop on 7/26/18.
//  Copyright © 2018 Antoine Clop. All rights reserved.
//

import Foundation

internal class LeagueRequester {
    
    private var key: APIKey
    
    public init(key: APIKey) {
        self.key = key
    }
    
    internal func request<ResultType: Decodable>(method: LeagueMethod, handler: @escaping (ResultType?, String?) -> Void) {
        if canMakeRequest(for: method) {
            let accessMethod: RESTRequester.AccessMethod = method.getAccessMethod()
            let methodUrl: String = method.getMethodUrl()
            let headers: [String: String] = ["X-Riot-Token": self.key.token]
            let body: Data? = method.getMethodBody()
            
            let completion: (ResultType?, RESTRequester.Headers?, String?) -> Void = { (result, headers, error) in
                self.updateKeyLimits(for: method, headers: headers)
                handler(result, error)
            }
            let resultIsJson: Bool = !PrimitiveTypeCheck.isPrimitive(ResultType.self)
            let requester: DataRequester = resultIsJson ? JsonRequester() : RawRequester()
            requester.request(accessMethod: accessMethod, methodUrl: methodUrl, headers: headers, body: body, handler: completion)
        }
        else {
            handler(nil, "Cannot make request for now")
        }
    }
    
    private func updateKeyLimits(for method: LeagueMethod, headers: RESTRequester.Headers?) {
        if let headers = headers {
            if let appRateLimitCount = headers["X-App-Rate-Limit-Count"] as? String, let appRateLimit = headers["X-App-Rate-Limit"] as? String {
                self.key.updateAppRateLimit(with: appRateLimitCount, appRate: appRateLimit)
            }
            if let methodLimitCount = headers["X-Method-Rate-Limit-Count"] as? String, let methodLimit = headers["X-Method-Rate-Limit"] as? String {
                self.key.updateMethodLimit(for: method.getMethodSignature(), newLimits: methodLimitCount, methodRate: methodLimit)
            }
        }
    }
    
    private func canMakeRequest(for method: LeagueMethod) -> Bool {
        let methodSignature: String = method.getMethodSignature()
        return !self.key.hasReachLimit(for: methodSignature)
    }
}
