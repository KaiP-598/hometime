//
//  Copyright © 2017 REA. All rights reserved.
//

import UIKit

typealias JSONDictionary = [String: Any]

enum JSONError: Error {
  case serialization
}

class ViewController: UITableViewController {

  @IBOutlet var tramTimesTable: UITableView!
  
  var northTrams: [Any]?
  var southTrams: [Any]?
  var loadingNorth: Bool = false
  var loadingSouth: Bool = false
  var token: String?
  var session: URLSession?

  override func viewDidLoad() {
    super.viewDidLoad()

    let config = URLSessionConfiguration.default
    session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)

    clearTramData()
  }

  @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
    clearTramData()
  }

  @IBAction func loadButtonTapped(_ sender: UIBarButtonItem) {
    clearTramData()
    loadTramData()
  }

}

// MARK: - Tram Data

extension ViewController {

  func clearTramData() {
    northTrams = nil
    southTrams = nil
    loadingNorth = false
    loadingSouth = false

    tramTimesTable.reloadData()
  }

  func loadTramData() {
    loadingNorth = true
    loadingSouth = true

    if let token = token {
      print("Token \(token)")
      loadTramDataUsing(token: token)
    } else {
      fetchApiToken { [weak self] token, error in
        if let token = token, error == nil  {
          self?.token = token
          print("Token: : \(String(describing: token))")
          self?.loadTramDataUsing(token: token)
        } else {
          self?.loadingNorth = false
          self?.loadingSouth = false
          print("Error retrieving token: \(String(describing: error))")
        }
      }
    }
  }

  func fetchApiToken(completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
    let tokenUrl = "http://ws3.tramtracker.com.au/TramTracker/RestService/GetDeviceToken/?aid=TTIOSJSON&devInfo=HomeTimeiOS"

    loadTramApiResponseFrom(url: tokenUrl) { response, error in
      let tokenObject = response?.first
      let token = tokenObject?["DeviceToken"] as? String
      completion(token, error)
    }
  }

  func loadTramDataUsing(token: String) {
    let northStopId = "4055"
    let northTramsUrl = urlFor(stopId: northStopId, token: token)
    loadTramApiResponseFrom(url: northTramsUrl) { [weak self] trams, error in
      self?.loadingNorth = false

      if error != nil {
        print("Error retrieving trams: \(String(describing: error))")
      } else {
        self?.northTrams = trams
        self?.tramTimesTable.reloadData()
      }
    }

    let southStopId = "4155"
    let southTramsUrl = urlFor(stopId: southStopId, token:token)
    loadTramApiResponseFrom(url: southTramsUrl) { [weak self] trams, error in
      self?.loadingSouth = false

      if error != nil {
        print("Error retrieving trams: \(String(describing: error))")
      } else {
        self?.southTrams = trams;
        self?.tramTimesTable.reloadData()
      }
    }

  }

  func urlFor(stopId: String, token: String) -> String {
    let urlTemplate = "http://ws3.tramtracker.com.au/TramTracker/RestService/GetNextPredictedRoutesCollection/{STOP_ID}/78/false/?aid=TTIOSJSON&cid=2&tkn={TOKEN}"
    return urlTemplate.replacingOccurrences(of: "{STOP_ID}", with: stopId).replacingOccurrences(of: "{TOKEN}", with: token)
  }

  func loadTramApiResponseFrom(url: String, completion: @escaping (_ responseData: [JSONDictionary]?, _ error: Error?) -> Void) {
    let task = session?.dataTask(with: URL(string: url)!) { data, response, error in
      if error != nil {
        completion(nil, error)
      } else {
        do {
          if let data = data,
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONDictionary {
            let objects = jsonResponse["responseObject"] as? [JSONDictionary]
            completion(objects, nil)
          } else {
            completion(nil, JSONError.serialization)
          }
        } catch {
          completion(nil, JSONError.serialization)
        }
      }
    }

    task?.resume()
  }

  func tramsFor(section: Int) -> [Any]? {
    return (section == 0) ? northTrams : southTrams
  }

  func isLoading(section: Int) -> Bool {
    return (section == 0) ? loadingNorth : loadingSouth
  }
}


// MARK - UITableViewDataSource

extension ViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TramCellIdentifier", for: indexPath)

    let trams = tramsFor(section: indexPath.section)
    guard let tram = trams?[indexPath.row] as? JSONDictionary else {
      if isLoading(section: indexPath.section) {
        cell.textLabel?.text = "Loading upcoming trams..."
      } else {
        cell.textLabel?.text = "No upcoming trams. Tap load to fetch"
      }
      return cell
    }

    guard let arrivalDateString = tram["PredictedArrivalDateTime"] as? String else {
      return cell
    }
    let dateConverter = DotNetDateConverter()
    cell.textLabel?.text = dateConverter.formattedDateFromString(arrivalDateString)

    return cell;
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 0)
    {
      guard let count = northTrams?.count else { return 1 }
      return count
    }
    else
    {
      guard let count = southTrams?.count else { return 1 }
      return count
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "North" : "South"
  }
}
