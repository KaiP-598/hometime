import Foundation
import SwiftyJSON
import Alamofire
import ObjectMapper

typealias JSONDictionary = [String: Any]

enum JSONError: Error {
  case serialization
}

enum NetworkError: Error {
    case failure
    case success
}

protocol NetworkServicing {
    func fetchApiToken(completion: @escaping (_ token: String?, _ error: NetworkError) -> Void)
    
    func loadTrams(stopId: String, completion: @escaping (_ trams: [Tram]?, _ error: NetworkError) -> Void)
}

class NetworkService: NetworkServicing{
    
    var token: String?
    
    func fetchApiToken(completion: @escaping (_ token: String?, _ error: NetworkError) -> Void) {
      let tokenUrl = "http://ws3.tramtracker.com.au/TramTracker/RestService/GetDeviceToken/?aid=TTIOSJSON&devInfo=HomeTimeiOS"
        
        Alamofire.request(tokenUrl, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            if let err = response.error{
                debugPrint(err)
                completion(nil, .failure)
                return
            }
            
            guard let data = response.data else {
                completion(nil, .failure)
                return
            }
            
            let json = try? JSON(data: data)
            if let responseObject = json?["responseObject"]{
                
                if let tokenObject = responseObject.arrayValue.first{
                    let token = tokenObject["DeviceToken"]
                    completion(token.stringValue, .success)
                } else {
                    completion(nil, .failure)
                }
                
            } else {
                completion(nil, .failure)
                return
            }

        }
    }
    
    func loadTrams(stopId: String, completion: @escaping (_ trams: [Tram]?, _ error: NetworkError) -> Void){
        
        if let token = self.token{
            let finalEnpoint = urlFor(stopId: stopId, token: token)
            loadTramsFromApi(apiUrl: finalEnpoint) { (trams, error) in
                completion(trams,error)
            }
        } else {
            fetchApiToken { [weak self] (token, error) in
                switch error{
                case .failure:
                    completion(nil,error)
                    break
                case .success:
                    if let tokenString = token, let strongSelf = self {
                        let finalEnpoint = strongSelf.urlFor(stopId: stopId, token: tokenString)
                        strongSelf.loadTramsFromApi(apiUrl: finalEnpoint) { (trams, error) in
                            completion(trams,error)
                        }
                    }
                    break
                }
            }
        }
      
    }
    
    func loadTramsFromApi(apiUrl: String, completion: @escaping (_ trams: [Tram]?, _ error: NetworkError) -> Void){
        Alamofire.request(apiUrl, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            if let err = response.error{
                debugPrint(err)
                completion(nil, .failure)
                return
            }
            
            guard let data = response.data else {
                completion(nil, .failure)
                return
            }
            
            let json = try? JSON(data: data)
            if let responseObject = json?["responseObject"]{
                let tramsData = responseObject
                let trams = Mapper<Tram>().mapArray(JSONObject: tramsData.arrayObject)
                completion(trams, .success)
                return
            } else {
                completion(nil, .failure)
                return
            }

        }
    }

    func urlFor(stopId: String, token: String) -> String {
      let urlTemplate = "http://ws3.tramtracker.com.au/TramTracker/RestService/GetNextPredictedRoutesCollection/{STOP_ID}/78/false/?aid=TTIOSJSON&cid=2&tkn={TOKEN}"
      return urlTemplate.replacingOccurrences(of: "{STOP_ID}", with: stopId).replacingOccurrences(of: "{TOKEN}", with: token)
    }
    
}

