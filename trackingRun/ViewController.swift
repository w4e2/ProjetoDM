//
//  ViewController.swift
//  trackingRun
//
//  Created by William Nabechima on 11/11/16.
//  Copyright © 2016 William Nabechima. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var buttonStartStop: UIButton!
    @IBOutlet weak var buttonTrackHistory: UIButton!
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var trackShowing: Track?
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
//        _locationManager.distanceFilter = 10.0
        
        
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.'
        buttonStartStop.setTitle("Start", forState: .Normal)
        buttonStartStop.addTarget(self, action: #selector(ViewController.startPressed(_:)), forControlEvents: .TouchUpInside)
        buttonStartStop.backgroundColor = UIColor.greenColor()
        buttonStartStop.layer.cornerRadius = buttonStartStop.frame.size.height/2
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        buttonStartStop.layer.cornerRadius = buttonStartStop.frame.size.height/2
        buttonTrackHistory.layer.borderWidth = 1.0
        buttonTrackHistory.layer.borderColor = UIColor.whiteColor().CGColor
        buttonTrackHistory.layer.cornerRadius = 2
        

    }
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        timer.invalidate()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func eachSecond(timer: NSTimer?) {
        seconds += 1
        var minute = ""
        if seconds >= 60 {
            let minUnit = HKUnit.minuteUnit()
            let time = seconds/60
            let minuteQuantity = HKQuantity(unit: minUnit, doubleValue: Double(Int(time)))

            minute = minuteQuantity.description
        }
        var timeUnit = HKUnit.secondUnit()

        let secondsQuantity = HKQuantity(unit: timeUnit, doubleValue: Double(Int(seconds%60)))
        labelTime.text = minute + " " + secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: Double(Int(distance)))
        labelDistance.text = distanceQuantity.description
        
        let paceUnit = HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: distance / seconds)
        labelSpeed.text = paceQuantity.description
    }
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    func startPressed(sender: UIButton) {
        buttonTrackHistory.enabled = false
        // Here, the location manager will be lazily instantiated
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        seconds = 0.0
        distance = 0.0
        labelTime.text = "0 s"
        labelSpeed.text = "0 m"
        labelDistance.text = "0 m/s"
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                       target: self,
                                                       selector: #selector(ViewController.eachSecond(_:)),
                                                       userInfo: nil,
                                                       repeats: true)
        startLocationUpdates()
        sender.backgroundColor = UIColor.redColor()

        sender.setTitle("Stop", forState: .Normal)
        sender.removeTarget(nil, action: nil, forControlEvents: .AllEvents)

        sender.addTarget(self, action: #selector(ViewController.stopPressed(_:)), forControlEvents: .TouchUpInside)
    }
    func stopPressed(sender: UIButton) {

        stopLocationUpdates()
        timer.invalidate()
        if distance > 1 {
            let track = Track(creationDate: NSDate(), arrayLocations: locations, time: seconds, distance: distance)
            TrackManager.saveTrack(track)
        }
        
        
        
        sender.backgroundColor = UIColor.greenColor()
        sender.setTitle("Start", forState: .Normal)
        sender.removeTarget(nil, action: nil,
                            forControlEvents: .AllEvents)
        
        sender.addTarget(self, action: #selector(ViewController.startPressed(_:)), forControlEvents: .TouchUpInside)
        buttonTrackHistory.enabled = true

    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10  {
                //update distance
                
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = self.locations
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude))
        }
        
        return MKPolyline(coordinates: &coords, count: self.locations.count)
    }
    func loadMap() {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        self.locations.removeAll(keepCapacity: false)
        self.locations = (trackShowing?.arrayLocations)!
        seconds = Double((trackShowing?.time)!)
 
        distance = Double((trackShowing?.distance)!)
        eachSecond(nil)
        if self.locations.count > 0 {
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            mapView.addOverlay(polyline())
        } else {
            
        }
    }
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = self.locations[0] 
        
        var minLat = initialLoc.coordinate.latitude
        var minLng = initialLoc.coordinate.longitude
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = self.locations 
        
        for location in locations {
            print("\(minLat) - \(minLng)")
            minLat = min(minLat, location.coordinate.latitude)
            minLng = min(minLng, location.coordinate.longitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            maxLng = max(maxLng, location.coordinate.longitude)
        }
        print("\(minLat) - \(minLng)")
        print("\(maxLat) - \(maxLng)")

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func trackSelected() {
        if trackShowing != nil {
            loadMap()
        }
        
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let secondViewController = segue.destinationViewController as! HistoryViewController
        secondViewController.firstViewController = self
    }
}

extension ViewController: CLLocationManagerDelegate {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}