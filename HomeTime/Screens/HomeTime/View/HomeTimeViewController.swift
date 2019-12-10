//
//  Copyright © 2017 REA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



class HomeTimeViewController: UITableViewController {

  @IBOutlet var tramTimesTable: UITableView!
  
  var northTrams: [Any]?
  var southTrams: [Any]?
  var loadingNorth: Bool = false
  var loadingSouth: Bool = false
  var token: String?
  var session: URLSession?

  var viewModel: HomeTimeViewModeling?

  private let disposeBag = DisposeBag()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    

    setupBinding()
    
    let config = URLSessionConfiguration.default
    session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)

    clearTramData()
  }
    
    func setupBinding(){
        viewModel = HomeTimeViewModel.init(networkService: NetworkService())
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        viewModel.loadNorthTramsSuccess
            .subscribe(onNext: { [weak self] _ in
                self?.tramTimesTable.reloadData()
            }).disposed(by: disposeBag)
            
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

extension HomeTimeViewController {

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

//    if let token = token {
//      print("Token \(token)")
//      loadTramDataUsing(token: token)
//    } else {
//      fetchApiToken { [weak self] token, error in
//        if let token = token, error == nil  {
//          self?.token = token
//          print("Token: : \(String(describing: token))")
//          self?.loadTramDataUsing(token: token)
//        } else {
//          self?.loadingNorth = false
//          self?.loadingSouth = false
//          print("Error retrieving token: \(String(describing: error))")
//        }
//      }
//    }
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

  func tramsFor(section: Int) -> [Tram]? {
    if section == 0 {
        let trams = viewModel?.northTramArray
        return trams
    } else {
        let trams = viewModel?.southTramArray
        return trams
    }

  }

  func isLoading(section: Int) -> Bool {
    return (section == 0) ? loadingNorth : loadingSouth
  }
}


// MARK - UITableViewDataSource

extension HomeTimeViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TramCellIdentifier", for: indexPath)

    guard let trams = tramsFor(section: indexPath.section), trams.count > 0 else {
        if isLoading(section: indexPath.section) {
          cell.textLabel?.text = "Loading upcoming trams..."
        } else {
          cell.textLabel?.text = "No upcoming trams. Tap load to fetch"
        }
        return cell
    }

    let tram = trams[indexPath.row]
    guard let arrivalDateString = tram.predictedArrivalDateTime else {
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
        guard let count =  viewModel?.northTramArray.count else { return 1 }
        return count == 0 ? 1: count
    }
    else
    {
      guard let count = viewModel?.southTramArray.count else { return 1 }
      return count == 0 ? 1: count
    }
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "North" : "South"
  }
}
