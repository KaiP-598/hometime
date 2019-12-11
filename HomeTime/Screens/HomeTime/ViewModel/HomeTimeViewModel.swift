import Foundation
import RxSwift

protocol HomeTimeViewModeling {
    var northTramArray: [Tram] {get set}
    var southTramArray: [Tram] {get set}
    
    var loadNorthTrams: PublishSubject<Void> {get}
    var loadSouthTrams: PublishSubject<Void> {get}
    var loadNorthTramsSuccess: PublishSubject<Void> {get}
    var loadSouthTramsSuccess: PublishSubject<Void> {get}
    
    func clearTramData()
}

class HomeTimeViewModel: HomeTimeViewModeling{
    var northTramArray: [Tram] = [Tram]()
    var southTramArray: [Tram] = [Tram]()
    
    var loadNorthTrams: PublishSubject<Void> = PublishSubject<Void>()
    var loadSouthTrams: PublishSubject<Void> = PublishSubject<Void>()
    var loadNorthTramsSuccess: PublishSubject<Void> = PublishSubject<Void>()
    var loadSouthTramsSuccess: PublishSubject<Void> = PublishSubject<Void>()
    
    let networkService: NetworkServicing
    
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkServicing){
        self.networkService = networkService
        
        loadNorthTrams
            .flatMapLatest { [weak self] (_) -> Observable<[Tram]> in
                self?.getTrams(stopId: "4055") ?? Observable.just([Tram]())
                
            }
        .subscribe(onNext: { [weak self] (trams) in
            self?.northTramArray = trams
            self?.loadNorthTramsSuccess.onNext(())
        })
        .disposed(by: disposeBag)
        
        loadSouthTrams
            .flatMapLatest { [weak self] (_) -> Observable<[Tram]> in
                self?.getTrams(stopId: "4155") ?? Observable.just([Tram]())
                
            }
        .subscribe(onNext: { [weak self] (trams) in
            self?.southTramArray = trams
            self?.loadSouthTramsSuccess.onNext(())
        })
        .disposed(by: disposeBag)
    }
    
    func getTrams(stopId: String) -> Observable<[Tram]>{
        //Create an observable of tram array here
        return Observable.create { [weak self] observer in
            self?.networkService.loadTrams(stopId: stopId, completion: { (tramsArray, result) in
                switch result{
                case .failure:
                    debugPrint("There is an error when getting tram data")
                    observer.onNext([Tram]())
                case .success:
                    if let trams = tramsArray {
                        observer.onNext(trams)
                    } else {
                        observer.onNext([Tram]())
                    }
                }
            })
            
            return Disposables.create {
            }
        }
    }
    
    func clearTramData(){
        northTramArray = [Tram]()
        southTramArray = [Tram]()
    }
}
