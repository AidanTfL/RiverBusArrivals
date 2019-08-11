//
//  NaptanFerryPortDataModel.swift
//  HowsMyCommute
//
//  Created by Aidan Bunce-Waters on 11/08/2019.
//  Copyright © 2019 Aidan Bunce-Waters. All rights reserved.
//

import Foundation

class NaptanFerryPortDataModel {
    
    var naptanId : String
    var modes : [String]
    var icsCode: String
    var stopType : String
    var stationNaptan: String
    var id : String
    var commonName : String
    var distance : Float
    var placeType : String
    var latitude : Float
    var longitude : Float
    var lines : [String]
    
    init() {
        self.naptanId      = String.init()
        self.modes         = [String].init()
        self.icsCode       = String.init()
        self.stopType      = String.init()
        self.stationNaptan = String.init()
        self.id            = String.init()
        self.commonName    = String.init()
        self.distance      = Float.init()
        self.placeType     = String.init()
        self.latitude      = Float.init()
        self.longitude     = Float.init()
        self.lines         = [String].init()
    }
    
    init(naptanId : String, modes : [String], icsCode : String, stopType : String, stationNaptan : String, id : String, commonName : String, distance : Float, placeType : String, latitude : Float, longitude : Float, lines: [String]) {
        
        self.naptanId = naptanId
        self.modes = modes
        self.icsCode = icsCode
        self.stopType = stopType
        self.stationNaptan = stationNaptan
        self.id = id
        self.commonName = commonName
        self.distance = distance
        self.placeType = placeType
        self.latitude = latitude
        self.longitude = longitude
        self.lines = lines
    }
    
}
