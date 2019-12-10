import Foundation
import ObjectMapper

class Tram: Mappable {
    var destination: String?
    var predictedArrivalDateTime: String?
    var routeNo: String?

    
    
    
    init (){
        
    }
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        destination <- map["Destination"]
        predictedArrivalDateTime <- map["PredictedArrivalDateTime"]
        routeNo <- map["RouteNo"]

    }
}
