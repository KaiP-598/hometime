//
//  MockNetworkService.swift
//  HomeTimeTests
//
//  Copyright © 2019 REA. All rights reserved.
//

import XCTest
@testable import HomeTime

class MockNetworkService: NetworkServicing{

    var loadTramsResult: ([Tram]?, NetworkError)?
    
    func loadTrams(stopId: String, completion: @escaping (_ trams: [Tram]?, _ error: NetworkError) -> Void) {
        
        guard let result = loadTramsResult else {
            completion(nil, .failure)
            return
        }
        
        completion(result.0, result.1)
    }
    
    
}
