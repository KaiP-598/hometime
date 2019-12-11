HomeTime
========
# Candidate Notes

Problem: Majority of the functions are in the ViewController including networking requests, as the application grows, it would be hard to understand the codes and expand features because they are highly coupled.

My approach: Use MVVM design pattern to let the ViewController take care of only UI-related parts and ViewModel handles networking requests and massaging data back to ViewController for usage. Also unit tests are created to make sure features are fit for use.

---

# About

This repository contains a simple sample app using the Tram Tracker API to be used as a coding assignment for REA mobile developer candidates.

This project was built using **Xcode 11.1** and **Cocoapods 1.8.4**.

---

# Installation

To install the dependencies
* Open a terminal and cd to the directory containing the Podfile
* Run the `pod install` command

(For further details regarding cocoapod installation see https://cocoapods.org/)


---

