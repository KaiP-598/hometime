//
//  Copyright © 2017 REA. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import HomeTime

class MockURLSessionDataTask: URLSessionDataTask {
  override func resume() {
    print("mock resume")
  }
}

class MockURLSession: URLSession {
  override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

    let jsonString =  """
{
"responseObject" :
  [
    {
    "PredictedArrivalDateTime": "/Date(1426821588000+1100)/"
    }
  ]
}
"""
    let data = jsonString.data(using: .utf8)!
    completionHandler(data, nil, nil)

    return MockURLSessionDataTask()
  }
}

// MARK: -

class ViewControllerSpec: QuickSpec {
  
  override func spec() {
    describe("ViewController") {
      var viewController: ViewController?

      beforeEach {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "viewController") as? ViewController
        viewController?.loadViewIfNeeded()
        viewController?.token = "theToken"
      }

      it("should have sections for north and south") {
        let sections = viewController?.tramTimesTable.numberOfSections

        expect(sections) == 2
      }

      it("should initialize no tram data") {
        let tramsTable = viewController?.tramTimesTable

        let north = tramsTable?.numberOfRows(inSection: 0)
        expect(north) == 1

        let placeholderCell = tramsTable?.cellForRow(at: IndexPath(row: 0, section: 0))
        let placeholder = placeholderCell?.textLabel?.text
        expect(placeholder?.hasPrefix("No upcoming trams")) == true

        let south = tramsTable?.numberOfRows(inSection: 1)
        expect(south) == 1
      }

      it("should display arriveDateTime on table after load api response") {
        viewController?.session = MockURLSession()
        viewController?.loadTramData()

        let tramsTable = viewController?.tramTimesTable
        let northTramCell = tramsTable?.cellForRow(at: IndexPath(row: 0, section: 0))
        expect(northTramCell?.textLabel?.text) == "14:19"

        let southTramCell = tramsTable?.cellForRow(at: IndexPath(row: 0, section: 1))
        expect(southTramCell?.textLabel?.text) == "14:19"
      }
    }

  }
}
