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
        
        viewModel.loadSouthTramsSuccess
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
    viewModel?.clearTramData()
    loadingNorth = false
    loadingSouth = false

    tramTimesTable.reloadData()
  }

  func loadTramData() {
    loadingNorth = true
    loadingSouth = true
    viewModel?.loadNorthTrams.onNext(())
    viewModel?.loadSouthTrams.onNext(())

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
