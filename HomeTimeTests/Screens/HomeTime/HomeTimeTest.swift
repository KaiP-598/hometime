//
//  HomeTimeTest.swift
//  HomeTimeTests
//
//  Copyright © 2019 REA. All rights reserved.
//

import XCTest
import RxSwift
@testable import HomeTime

class HomeTimeTest: XCTestCase {
    
    var viewModel: HomeTimeViewModeling?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
    }
    
    func testSuccessfulGetCountries(){
        let disposeBag = DisposeBag()
        let networkService = MockNetworkService()
        let mockTramsArray = [Tram(),Tram()]
        let result: ([Tram]?, NetworkError) = (mockTramsArray, NetworkError.success)
        networkService.loadTramsResult = result
        viewModel = HomeTimeViewModel.init(networkService: networkService)
        
        let expectTramsFetched = expectation(description:"Fetched result contains trams data")
        viewModel?.getTrams(stopId: "1245")
            .subscribe(onNext: { (trams) in
                let tramsDataFetched: Bool
                if trams.isEmpty{
                    tramsDataFetched = false
                } else {
                    tramsDataFetched = true
                }
                
                XCTAssertTrue(tramsDataFetched)
                expectTramsFetched.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectTramsFetched], timeout:0.1)
    }
    
    func testFailToGetCountries(){
        let disposeBag = DisposeBag()
        let networkService = MockNetworkService()
        let mockTramsArray = [Tram]()
        let result: ([Tram]?, NetworkError) = (mockTramsArray, NetworkError.failure)
        networkService.loadTramsResult = result
        viewModel = HomeTimeViewModel.init(networkService: networkService)
        
        let expectTramsFailedToFetched = expectation(description:"Fetched result does not contains trams data")
        viewModel?.getTrams(stopId: "1234")
            .subscribe(onNext: { (trams) in
                let tramsDataFailedToFetch: Bool
                if trams.isEmpty{
                    tramsDataFailedToFetch = true
                } else {
                    tramsDataFailedToFetch = false
                }
                
                XCTAssertTrue(tramsDataFailedToFetch)
                expectTramsFailedToFetched.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectTramsFailedToFetched], timeout:0.1)
    }
    
}

