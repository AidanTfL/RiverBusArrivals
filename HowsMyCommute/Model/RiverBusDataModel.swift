//
//  RiverBoatDataModel.swift
//  HowsMyCommute
//
//  Created by Aidan Bunce-Waters on 09/08/2019.
//  Copyright © 2019 Aidan Bunce-Waters. All rights reserved.
//

import Foundation

class riverBusDataModel {

    var id : String
    var vehicleId : String
    var naptanId : String
    var stationName : String
    var lineId: String
    var lineName : String
    var direction : String
    var bearing : String
    var destinationName : String
    var timeStamp : String
    var countdownToStationInSecs : Int
    var towards : String
    var expectedArrivalTime : String
    var timeToLive: String
    var modeName: String
    
    var countdownToStationInMins : Int
    
    init() {
        
        self.id                  = String.init()
        self.vehicleId           = String.init()
        self.naptanId            = String.init()
        self.stationName         = String.init()
        self.lineId              = String.init()
        self.lineName            = String.init()
        self.direction           = String.init()
        self.bearing             = String.init()
        self.destinationName     = String.init()
        self.timeStamp           = String.init()
        self.countdownToStationInSecs = Int.init()
        self.towards             = String.init()
        self.expectedArrivalTime = String.init()
        self.timeToLive          = String.init()
        self.modeName            = String.init()
        self.countdownToStationInMins = self.countdownToStationInSecs / 60
    }
    
    init(id : String, vehicleId : String, naptanId : String, stationName : String, lineId : String, lineName : String, direction : String, bearing : String, destinationName : String, timeStamp : String, countdownToStationInSecs : Int, towards : String, expectedArrivalTime : String, timeToLive : String, modeName: String) {
    
            self.id                  = id
            self.vehicleId           = vehicleId
            self.naptanId            = naptanId
            self.stationName         = stationName
            self.lineId              = lineId
            self.lineName            = lineName
            self.direction           = direction
            self.bearing             = bearing
            self.destinationName     = destinationName
            self.timeStamp           = timeStamp
            self.countdownToStationInSecs = countdownToStationInSecs
            self.towards             = towards
            self.expectedArrivalTime = expectedArrivalTime
            self.timeToLive          = timeToLive
            self.modeName            = modeName
            self.countdownToStationInMins = countdownToStationInSecs / 60
    }
    
}
