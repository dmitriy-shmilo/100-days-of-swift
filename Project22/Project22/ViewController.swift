//
//  ViewController.swift
//  Project22
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
	
	private var manager: CLLocationManager?
	@IBOutlet var distanceLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		manager = CLLocationManager()
		manager?.delegate = self
		manager?.requestAlwaysAuthorization()
		
		view.backgroundColor = .gray
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways {
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
				if CLLocationManager.isRangingAvailable() {
					startScanning()
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		if let beacon = beacons.first {
			update(distance: beacon.proximity)
		} else {
			update(distance: .unknown)
		}
	}
	
	private func startScanning() {
		let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
		let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")

		manager?.startMonitoring(for: beaconRegion)
		manager?.startRangingBeacons(in: beaconRegion)
	}
	
	private func update(distance: CLProximity) {
		UIView.animate(withDuration: 1) {
			switch distance {
			case .far:
				self.view.backgroundColor = UIColor.blue
				self.distanceLabel.text = "FAR"

			case .near:
				self.view.backgroundColor = UIColor.orange
				self.distanceLabel.text = "NEAR"

			case .immediate:
				self.view.backgroundColor = UIColor.red
				self.distanceLabel.text = "RIGHT HERE"
			default:
				self.view.backgroundColor = UIColor.gray
				self.distanceLabel.text = "UNKNOWN"
			}
		}
	}


}

