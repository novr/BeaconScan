//
//  BitLinker.swift
//  BeaconScan
//
//  Created by 古宮 伸久 on 2024/08/23.
//

import Foundation
import CoreLocation

@Observable
class BitLinker: NSObject, CLLocationManagerDelegate {
    let bitLink = CLBeaconRegion(uuid: .init(uuidString: "41462998-6CEB-4511-9D46-1F7E27AA6572")!, major: 18, minor: 5, identifier: "bitLink")

    let locationManager = CLLocationManager()

    var txPower: Int = -59
    var beacon: CLBeacon?
    var location: CLLocationCoordinate2D?
    var isMonitoring = false
    var isRanging = false
    var isInside = false
    var logs: [String] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2.0
    }
    
    func request() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            log("startMonitoring: \(bitLink)")
            manager.startMonitoring(for: bitLink)
            
        case .notDetermined, .denied, .restricted:
            break
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log("didStartMonitoringFor: \(region)")
        manager.requestState(for: bitLink)
        isMonitoring = true
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        log("didDetermineState: \(state),\(region)")
        switch (state) {
        case .inside:
            manager.startRangingBeacons(satisfying: bitLink.beaconIdentityConstraint)
            isRanging = true
            isInside = true
            
        default:
            isInside = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log("didEnterRegion: \(region)")
        manager.startRangingBeacons(satisfying: bitLink.beaconIdentityConstraint)
        isRanging = true
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log("didExitRegion: \(region)")
        manager.stopRangingBeacons(satisfying: bitLink.beaconIdentityConstraint)
        isRanging = false
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        log("didRangeBeacons: \(beacons)")
        self.beacon = beacons.first
    }
    
    func log(_ message: String) {
        print(message)
        logs.append("\(Date.now.formatted(.dateTime)): \(message)")
    }
}

extension CLProximity: CustomStringConvertible {
    public var description: String {
        switch self {
        case .immediate:
            return "immediate"
            
        case .near:
            return "near"
            
        case .far:
            return "far"
            
        case .unknown:
            return "unknown"

        @unknown default:
            return "unknown"
        }
    }
}
