//
//  JsonDeserialise.swift
//  HowsMyCommute
//
//  Created by Aidan Bunce-Waters on 11/08/2019.
//  Copyright © 2019 Aidan Bunce-Waters. All rights reserved.
//

import Foundation
import SwiftyJSON

class JsonDeserialise {
    
    static func riverBusNaptanFerryPorts(json : JSON) -> [NaptanFerryPortDataModel] {
        if json["places"].isEmpty {
            return [NaptanFerryPortDataModel].init()
        }
        else {
            //Filter Places: StopType == NaptanFerryPorts, and a mode == "river-bus", and deserialise in to a [NaptanFerryPortDataModel]
            var riverBusNaptanFerryPorts : [NaptanFerryPortDataModel] = [NaptanFerryPortDataModel].init()
            
            for (_, place) in json["places"] {
                if place["stopType"].stringValue == "NaptanFerryPort" {
                    for(_, mode) in place["modes"] {
                        if mode.stringValue == "river-bus" {
                            
                            //Create a list of lines
                            var riverBusNaptanFerryPortLines : [String] = [String].init()
                            for (_, line) in json["places"]["lines"] {
                                riverBusNaptanFerryPortLines.append(line["name"].stringValue)
                            }

                            //Create a list of modes
                            let riverBusNaptanFerryPortModes : [String] = place["modes"].arrayValue.map { $0["mode"].stringValue }
                            
                            //Create NaptanFerryPortDataModel and populate
                            let riverBusNaptanFerryPort = NaptanFerryPortDataModel(naptanId: place["naptanId"].stringValue, modes: riverBusNaptanFerryPortModes, icsCode: place["icsCode"].stringValue, stopType: place["stopType"].stringValue, stationNaptan: place["stationNaptan"].stringValue, id: place["id"].stringValue, commonName: place["commonName"].stringValue, distance: place["distance"].floatValue, placeType: place["placeType"].stringValue, latitude: place["lat"].floatValue, longitude: place["lon"].floatValue, lines: riverBusNaptanFerryPortLines)
                            
                            riverBusNaptanFerryPorts.append(riverBusNaptanFerryPort)
                            break; //EXITS mode loop, so that only executes once
                        }
                    }
                }
            }
            return riverBusNaptanFerryPorts
        }
    }
    
    static func riverBusArrivals(json : JSON) -> [riverBusDataModel] {
        if json[].isEmpty {
            return [riverBusDataModel].init()
        }
        else {
            var arrivals : [riverBusDataModel] = [riverBusDataModel].init()

            for (_, arrival) in json[] {

                let arrivalDeserialised = riverBusDataModel(id: arrival["id"].stringValue, vehicleId: arrival["vehicleId"].stringValue, naptanId: arrival["naptanId"].stringValue, stationName: arrival["stationName"].stringValue, lineId: arrival["lineId"].stringValue, lineName: arrival["lineName"].stringValue, direction: arrival["direction"].stringValue, bearing: arrival["bearing"].stringValue, destinationName: arrival["destinationName"].stringValue, timeStamp: arrival["timeStamp"].stringValue, countdownToStationInSecs: arrival["timeToStation"].intValue, towards: arrival["towards"].stringValue, expectedArrivalTime: arrival["expectedArrivalTime"].stringValue, timeToLive: arrival["timeToLive"].stringValue, modeName: arrival["modeName"].stringValue)
                
                arrivals.append(arrivalDeserialised)
            }

            return arrivals
        }
    }
}
