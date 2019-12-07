HomeTime
========

This repository contains a simple sample app using the Tram Tracker API to be used as a coding assignment for REA mobile developer candidates.

This project was built using **Xcode 11.1** and **Cocoapods 1.8.4**.

---
# Installation

To install the dependencies
* Open a terminal and cd to the directory containing the Podfile
* Run the `pod install` command

(For further details regarding cocoapod installation see https://cocoapods.org/)


---
# Existing Functionality

The app is hard coded to show the next upcoming trams going *north* and *south* outside the REA office on Church St. There is a single table view with two sections, one for north and one for south.

* When the app loads, the table shows the empty state, ie no timetable information has been loaded
* When you tap 'Refresh', the app retrieves the upcoming trams from the API of both north and south, and places the dates in the list
* If no upcoming trams are returned, a placeholder is displayed in the table
* There isn't any proper error handling, if an error occurs, we just log it and move on


---
# Tram Tracker API

This app uses the same API as the Tram Tracker app, but it's not an officially public API so there is a chance it'll just stop working at some stage. It's more fun to use a real API though. To use the tram tracker API, you need to first connect with an endpoint that gives you an API token. That token can then be used for future calls.

To retrieve an API token, you hit this endpoint `http://ws3.tramtracker.com.au/TramTracker/RestService/GetDeviceToken/?aid=TTIOSJSON&devInfo=HomeTimeiOS` and retrieve the token from the response. The app id and dev info parameters have been coded in for you, as these should not need to change.

```
{
  errorMessage: null,
  hasError: false,
  hasResponse: true,
  responseObject: [
    {
      DeviceToken: "some-valid-device-token"
    }
  ]
}
```

We can then use this device token to retrieve the upcoming trams. The route ID and stop IDs that we pass to the API have been hard coded for you to represent the tram stops on either side of the road. The endpoint that retrieves the tram (with stop ID and token replaced with valid values) will be of the form `http://ws3.tramtracker.com.au/TramTracker/RestService/GetNextPredictedRoutesCollection/{STOP_ID}/78/false/?aid=TTIOSJSON&cid=2&tkn={TOKEN}`, returns the upcoming trams in the form:

```
{
  errorMessage: null,
  hasError: false,
  hasResponse: true,
  responseObject: [
    {
      Destination: "North Richmond",
      PredictedArrivalDateTime: "/Date(1425407340000+1100)/",
      RouteNo: "78"
    },
    {
      Destination: "North Richmond",
      PredictedArrivalDateTime: "/Date(1425408480000+1100)/",
      RouteNo: "78"
    },
    {
      Destination: "North Richmond",
      PredictedArrivalDateTime: "/Date(1425409740000+1100)/",
      RouteNo: "78"
    }
  ]
}
```

The dates returned look like they're in a strange .NET format, rather than something friendly and widely used like ISO8601. There is some code in `DotNetDateConverter.swift` to convert these strings into `NSDate` objects that we can use in the app.

You'll notice it's one of those APIs that sometimes gives you error messages inside a valid JSON response. We ignore this for now and assume that a `200` response means that the data will be on the `responseObject` field.


---
# Existing iOS Code

This application is not meant to be an example of how code should be written, but rather an opportunity to think about better ways of breaking down and structuring code in a simple context.

The view controller keeps the retrieved tram data in two array properties, `northTrams` and `southTrams`, which are initially `nil` representing the absence of data. While the request is loading, this is tracked in two separate lifecycle properties `loadingNorth` and `loadingSouth`.

Initially, there is no token, but once we have retrieved the token once, it is stored in the `token` property and used from then on. All network requests use the same `session` property.

The `UITableViewDataSource` uses the tram array and the loading state to determine what to show in the table. There are always 2 sections, one representing the north direction and the other south. If we have not retrieved any tram information, we show this in the table. While the request loads, we show this state in the table. Once we have retrieved tram data, we show this in the data in the table. If the request for tram data succeeds but has an empty list of upcoming trams, this will result in no rows being shown in the table.

The `loadTramData` method checks whether we already have a token to use, or otherwise uses `fetchApiToken:` to call back once the token is retrieved. We then use `loadTramDataUsingToken:` to calculate both the north and south API endpoints via `urlFor(stopId, token)` and passing this to `loadTramApiResponseFrom(url, completion)`.


---
# Coding Task

The functionality is mostly complete (error handling has been largely ignored), but the code isn't very maintainable and as features are added, it isn't going to be maintainable. We would like you to look at some ways of improving the code quality, to make it easier to maintain and easier to test.

Don't feel like you have to fix every issue you see in the code, but tell us some of the things you would like to fix, what you think the major problems are and have a go at restructuring the app to solve this, and add unit tests as appropriate.

With a better code structure in place, try adding a small piece of functionality. For example, instead of just showing the time for the next tram (eg. *9:23 am*), it could also show how far away that is from the current time (eg. *9:23 am (3 min)*)
