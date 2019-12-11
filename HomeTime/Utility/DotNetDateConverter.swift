//
//  Copyright (c) 2015 REA. All rights reserved.
//

import Foundation

class DotNetDateConverter {
  func dateFromDotNetFormattedDateString(_ string: String) -> Date! {
    guard let startRange = string.range(of: "("),
      let endRange = string.range(of: "+") else { return nil }

    let lowBound = string.index(startRange.lowerBound, offsetBy: 1)
    let range = lowBound..<endRange.lowerBound

    let dateAsString = string[range]
    guard let time = Double(dateAsString) else { return nil }
    let unixTimeInterval = time / 1000
    return Date(timeIntervalSince1970: unixTimeInterval)
  }

  func formattedDateFromString(_ string: String) -> String {
    if let date = dateFromDotNetFormattedDateString(string){
        let currentDate = Date()
        let timeDifference = date.timeIntervalSince(currentDate)
        let minutes = floor(timeDifference / 60)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date) + " (" + (minutes.clean) + "min)"
    } else {
        return ""
    }
  }
}

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
