//
//  ViewController.swift
//  HowsMyCommute
//
//  Created by Aidan Bunce-Waters on 09/08/2019.
//  Copyright © 2019 Aidan Bunce-Waters. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let appId = "71739dcb"
    let appKey = "75fefee511fd98a306253b7831aedde4"
    let NEARESTPLACE_URL = "https://api.tfl.gov.uk/Place"
    let ARRIVALS_URL = "https://api.tfl.gov.uk/StopPoint/{id}/Arrivals"
    
    let locationManager = CLLocationManager()
    var nearestPier : NaptanFerryPortDataModel?
    var nearestPierArrivals : [riverBusDataModel?] = []
    
    var firstTimeFetchingArrivalsData : Bool = true
    var refreshArrivalsDataPeriod : TimeInterval = 60   //refresh arrivals (make a new call to TfL Api every 1 min
    var updateArrivalResultLblPeriod : TimeInterval = 0 // update UI label initially 0 secs, then updated to every 1 min after 1st execution
    
    var refreshCount : Int = 0
    var previousCountdownToStation : Int = 0
    
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblNearestPier: UILabel!
    @IBOutlet weak var lblNearestPierResult: UILabel!
    @IBOutlet weak var lblNextArrival: UILabel!
    @IBOutlet weak var lblNextArrivalResult: UILabel!
    
    @IBOutlet weak var boatTimesContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeArrivalsHidden()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func manualRefreshButtonPressed(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        keepUpdatingBoatTimesContainerBackgroundColor()
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    
    func makeArrivalsVisible() {
        lblNextArrival.isHidden = false
        lblNextArrivalResult.isHidden = false
    }
    
    func makeArrivalsHidden() {
        lblNextArrival.isHidden = true
        lblNextArrivalResult.isHidden = true
    }
    
    func keepUpdatingArrivalDueTimes() {
        
        //Find earliest departure
        if let nextOutbound = self.nearestPierArrivals.first(where: {$0?.direction == "outbound"}) {
            //Star timer and execute code on repeat
            Timer.scheduledTimer(withTimeInterval: updateArrivalResultLblPeriod, repeats: false) {
                (_:Timer)->Void in
                
                var due = "" //initialise
                
                if (nextOutbound!.countdownToStationInSecs <= 60) {
                    
                    self.lblNextArrivalResult.textColor = UIColor.red
                    
                    let newCountdownToStation = (self.previousCountdownToStation == nextOutbound!.countdownToStationInSecs) ? self.previousCountdownToStation-1 : nextOutbound!.countdownToStationInSecs
                
                    self.previousCountdownToStation = newCountdownToStation // updates for next iteration
                    due = String(newCountdownToStation) + " s"
                    
                    //Update Values for next iteration timer
                    self.updateArrivalResultLblPeriod = 1 //refresh label every 1 sec
                    self.refreshArrivalsDataPeriod = 3  // refresh data from TfL every 3 secs
                    
                    //Refresh data
                    self.refreshCount+=1
                    if(self.refreshCount % Int(self.refreshArrivalsDataPeriod) == 0) {
                        self.refreshRiverBusArrivals() // refresh data
                    }
                }
                else {
                    
                    self.lblNextArrivalResult.textColor = UIColor.black
                    due = String(nextOutbound!.countdownToStationInMins) + " min"
                    
                    //Update values for next iteration timer
                    self.updateArrivalResultLblPeriod = 20
                    self.refreshCount = 0
                    
                    // Refresh data
                    self.refreshRiverBusArrivals()
                }
                
                //Updates UI
                self.makeArrivalsVisible()
                self.lblNextArrivalResult.text = "\(nextOutbound!.lineName): to \(nextOutbound!.destinationName). Departs in: \(due)."
                
                //Calls itself - infinite loop
                self.keepUpdatingArrivalDueTimes()
            }
        }
    }
        
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
        }
        
        let lat = String(location.coordinate.latitude)
        let lon = String(location.coordinate.longitude)
        print("Location: latitude = \(lat), longitude = \(lon)")
        
        getNearestPierAndUpdateUI(latitude: lat, longitude: lon)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lblNearestPierResult.text = "Unable to find your location"
        print("\(error) Unable to find location.")
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    func getNearestPierAndUpdateUI(latitude: String, longitude: String) {
        let url = NEARESTPLACE_URL
        let params : [String : String] = ["type" : "NaptanFerryPort", "modes" : "river-bus", "lat" : latitude, "lon": longitude, "radius" : "1000", "app_id" : appId, "app_key" : appKey]
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON {
                response in
                if response.result.isSuccess {
                    
                    let nearestPlacesJSON : JSON = JSON(response.result.value!)
                    let riverBusNaptanFerryPorts = JsonDeserialise.riverBusNaptanFerryPorts(json: nearestPlacesJSON)
                    
                    if riverBusNaptanFerryPorts.isEmpty {
                        self.lblNearestPierResult.text = "Unable to find a pier within 1km of you."
                        print("Info: Unable to find a pier within 1km of users location.")
                    }
                    else {
                        //Iterate through riverBusNaptanFerryPorts, and set nearestPier to the NaptanFerryPort with the smallest distance.
                        self.nearestPier = riverBusNaptanFerryPorts.min(by: {$0.distance < $1.distance})
                        
                        self.lblNearestPierResult.text = self.nearestPier?.commonName
                        print("Success: \(String(describing: self.nearestPier?.commonName)) is nearest pier.")
                
                        //Retrieve arrivals data
                        self.refreshRiverBusArrivals()
                    }
                }
                else {
                    self.lblNearestPierResult.text = "Connection Issues: Retrieving nearest pier to your location: (\(latitude), \(longitude)"
                    print("Error: Unable to retrieve nearest pier from TfL: \(String(describing: response.result.error))")
                }
            }
    }
    
    func refreshRiverBusArrivals() {
        if nearestPier != nil {
            
            let url = ARRIVALS_URL.replacingOccurrences(of: "{id}", with: String(nearestPier!.id).replacingOccurrences(of: "GEMB", with: "GGLP"))
            let params : [String : String] = ["app_id" : appId, "app_key" : appKey]
            
            Alamofire.request(url, method: .get, parameters: params).responseJSON {
                response in
                if response.result.isSuccess {
                    
                    let arrivalsJSON : JSON = JSON(response.result.value!)
                    let arrivalsUnsorted = JsonDeserialise.riverBusArrivals(json: arrivalsJSON)
                    
                    //Sort arrivals in ascending order with soonest arrival first
                    self.nearestPierArrivals = arrivalsUnsorted.sorted(by: {$0.countdownToStationInSecs < $1.countdownToStationInSecs})
                    
                    //Update UI
                    let currentDateTime = self.getTimeNow()
                    
                    if self.nearestPierArrivals.isEmpty {
                        
                        self.makeArrivalsVisible()
                        self.lblNextArrivalResult.text = "No River Bus arrivals are scheduled. Updated: \(currentDateTime)."
                        print("No River Bus arrivals are scheduled. Last updated: \(currentDateTime).")
                    }
                    else {
                        print("Retrieved arrivals...")
                        }
                    
                    if self.firstTimeFetchingArrivalsData {
                        
                        self.firstTimeFetchingArrivalsData = false; //no longer first time fetching data
                        self.keepUpdatingArrivalDueTimes() // infinite timer
                    }
                }
                else {
                      self.lblNearestPierResult.text = "Connection Issues: Retrieving arrivals"
                    print("Error: Unable to retrieve arrivals for \(self.nearestPier!.commonName) from TfL: \(String(describing: response.result.error))")
                  }
            }
        }
        else
        {
            print("Error: Could not fetch arrivals data as nearestPier is nil")
        }
    }
    
    //MARK: - Helper Functions
    /***************************************************************/
    
    func getTimeNow() -> String {
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium

        return formatter.string(from: currentDateTime)
    }
    
    //MARK: - for novelty. To test that timer doesn't sleep thread and allows execution of other tasks
    
    func keepUpdatingBoatTimesContainerBackgroundColor(){
        
        let colours = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
        
        var count = colours.count-1
        
        //Start timer and execute code on repeat
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            (_:Timer)->Void in
            
            self.boatTimesContainer.backgroundColor = colours[colours.count-1 - count]
            
            count-=1
            if count < 0 {
                count = colours.count-1
            }
        }
    }
}
