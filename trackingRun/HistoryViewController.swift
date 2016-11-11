//
//  HistoryViewController.swift
//  trackingRun
//
//  Created by William Nabechima on 11/11/16.
//  Copyright © 2016 William Nabechima. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let arrayTrack = TrackManager.getTrackArray()
    weak var firstViewController : ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTrack.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        firstViewController?.trackShowing = arrayTrack[indexPath.row]
        firstViewController?.trackSelected()
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("historyTableViewCell") as! HistoryTableViewCell
        let track = arrayTrack[indexPath.row]
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        
        cell.labelDate.text = dateFormater.stringFromDate(track.creationDate)
        let seconds = Double(track.time)
        var minute = ""

        if seconds >= 60 {
            let minUnit = HKUnit.minuteUnit()
            let time = seconds/60
            let minuteQuantity = HKQuantity(unit: minUnit, doubleValue: Double(Int(time)))
            
            minute = minuteQuantity.description
        }
        let timeUnit = HKUnit.secondUnit()
        
        let secondsQuantity = HKQuantity(unit: timeUnit, doubleValue: Double(Int(seconds%60)))
        cell.labelTime.text = minute + " " + secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: Double(Int(track.distance)))
        cell.labelDistance.text = distanceQuantity.description
        
        return cell
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    @IBAction func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
