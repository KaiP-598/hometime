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
    let date = dateFromDotNetFormattedDateString(string)
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date!)
  }
}
