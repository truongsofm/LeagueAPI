//
//  DataDragonRequester.swift
//  LeagueAPI
//
//  Created by Antoine Clop on 8/14/18.
//  Copyright © 2018 Antoine Clop. All rights reserved.
//

import Foundation

internal class DataDragonRequester {
    
    // MARK: - Singleton
    
    public static let instance: DataDragonRequester = DataDragonRequester()
    
    private init() {}
    
    // MARK: - Cache
    
    private var versions: DDragonVersions?
    private var championsDetails: DDragonChampionsFile?
    private var championAdditionalDetails: [String : DDragonChampionFile?] = [:]
    private var profileIcons: [ProfileIcon] = []
    
    // MARK: - Methods
    
    public func getDataVersions(completion: @escaping (DDragonVersions?, String?) -> Void) {
        if let versions = versions {
            completion(versions, nil)
        }
        else {
            let versionUrl: String = "\(ServicesUrl.DDragonUrl)/realms/na.json"
            RESTRequester().requestObject(.GET, url: versionUrl, asType: DDragonVersions.self) { (versions, _, _, error) in
                self.versions = versions
                completion(versions, error)
            }
        }
    }
    
    public func getChampionsDetails(completion: @escaping (DDragonChampionsFile?, String?) -> Void) {
        if let championsDetails = championsDetails {
            completion(championsDetails, nil)
        }
        else {
            getDataVersions() { (versions, error) in
                guard let versions = versions else { completion(nil, error); return }
                let championsUrl: String = "\(ServicesUrl.DDragonCdn)/\(versions.champion)/data/en_US/champion.json"
                RESTRequester().requestObject(.GET, url: championsUrl, asType: DDragonChampionsFile.self) { (championsDetails, _, _, error) in
                    self.championsDetails = championsDetails
                    completion(championsDetails, error)
                }
            }
        }
    }
    
    public func getChampionAdditionalDetails(name: String, completion: @escaping (DDragonChampionFile?, String?) -> Void) {
        if let championDetails = championAdditionalDetails[name.lowercased()] {
            completion(championDetails, nil)
        }
        else {
            getDataVersions() { (versions, error) in
                guard let versions = versions else { completion(nil, error); return }
                let championUrl: String = "\(ServicesUrl.DDragonCdn)/\(versions.champion)/data/en_US/champion/\(name).json"
                RESTRequester().requestObject(.GET, url: championUrl, asType: DDragonChampionFile.self) { (championDetails, _, _, error) in
                    self.championAdditionalDetails[name.lowercased()] = championDetails
                    completion(championDetails, error)
                }
            }
        }
    }
    
    public func getProfileIcon(profileIconId: ProfileIconId, completion: @escaping (ProfileIcon?, String?) -> Void) {
        let cachedProfileIcon: ProfileIcon? = self.profileIcons.filter { return $0.id == profileIconId }.first
        if let cachedProfileIcon = cachedProfileIcon {
            completion(cachedProfileIcon, nil)
        }
        else {
            getDataVersions() { (versions, error) in
                guard let versions = versions else { completion(nil, error); return }
                let temporaryProfileIcon: ProfileIcon = ProfileIcon(id: profileIconId, version: versions.profileIcon)
                RESTRequester().requestImage(.GET, url: temporaryProfileIcon.profileIcon.url) { (image, responseCode, _, error) in
                    if responseCode == .Ok {
                        // We just downloaded image to test if icon exists, so we put it in image's cache
                        temporaryProfileIcon.profileIcon.image = image
                        self.profileIcons.append(temporaryProfileIcon)
                        completion(temporaryProfileIcon, nil)
                    }
                    else {
                        completion(nil, error)
                    }
                }
            }
        }
    }
}
