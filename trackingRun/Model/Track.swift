//
//  Track.swift
//  trackingRun
//
//  Created by William Nabechima on 11/11/16.
//  Copyright © 2016 William Nabechima. All rights reserved.
//

import UIKit
import MapKit

class Track: NSObject, NSCoding {
    var creationDate: NSDate!
    var arrayLocations: [CLLocation]!
    var time: NSNumber!
    var distance: NSNumber!
    
    init(creationDate: NSDate,arrayLocations: [CLLocation], time: NSNumber, distance: NSNumber) {
        self.creationDate = creationDate
        self.arrayLocations = arrayLocations
        self.time = time
        self.distance = distance
    }
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()

        self.creationDate = decoder.decodeObjectForKey("creationDate") as! NSDate
        self.arrayLocations = decoder.decodeObjectForKey("arrayLocations") as! [CLLocation]
        self.time = decoder.decodeObjectForKey("time") as! NSNumber
        self.distance = decoder.decodeObjectForKey("distance") as! NSNumber
        
    }
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.creationDate, forKey: "creationDate")
        coder.encodeObject(self.arrayLocations, forKey: "arrayLocations")
        coder.encodeObject(self.time, forKey: "time")
        coder.encodeObject(self.distance, forKey: "distance")

        
    }
    
}
