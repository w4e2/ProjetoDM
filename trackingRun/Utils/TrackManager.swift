//
//  TrackManager.swift
//  trackingRun
//
//  Created by William Nabechima on 11/11/16.
//  Copyright © 2016 William Nabechima. All rights reserved.
//

import UIKit

class TrackManager: NSObject {
    class func saveTrack(track: Track) {
        let defaults = NSUserDefaults.standardUserDefaults()

        let arrayOfObjectsUnarchivedData = defaults.dataForKey("trackArray")
        var trackArray: [Track] = []
        if arrayOfObjectsUnarchivedData != nil {
            trackArray = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData!) as! [Track]

        }
        trackArray.append(track)
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(trackArray)
        defaults.setObject(arrayOfObjectsData, forKey: "trackArray")
    }
    class func getTrackArray() -> [Track] {
        let defaults = NSUserDefaults.standardUserDefaults()
        let arrayOfObjectsUnarchivedData = defaults.dataForKey("trackArray")
        var trackArray: [Track] = []
        if arrayOfObjectsUnarchivedData != nil {
            trackArray = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData!) as! [Track]
            for cont in 0...trackArray.count - 1 {
                let track = trackArray[cont]
                if track.creationDate.timeIntervalSinceNow > 2592000 {
                    trackArray.removeAtIndex(cont)
                }else {
                    break
                }
            }
        }
        
        
        
        
        
        
        return trackArray
    }
    class func saveTrackArray(array:[Track]) {
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(array)
        NSUserDefaults.standardUserDefaults().setObject(arrayOfObjectsData, forKey: "trackArray")
        
    }
    class func filterArrayTrack(){
        
    }
}
