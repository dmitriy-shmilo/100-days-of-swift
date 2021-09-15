//
//  ViewController.swift
//  Project22
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
	
	private var beaconFound = false
	private var manager: CLLocationManager?
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var circle: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		manager = CLLocationManager()
		manager?.delegate = self
		manager?.requestAlwaysAuthorization()
		
		circle.layer.cornerRadius = 128
		circle.layer.borderWidth = 1.0
		circle.layer.borderColor = UIColor.black.cgColor
		circle.backgroundColor = .clear

		view.backgroundColor = .gray
	}
	
	@objc func tap(_ sender: UITapGestureRecognizer) {
		update(distance: [CLProximity.near, CLProximity.far].randomElement()!)
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
			if !beaconFound {
				beaconFound = true
				let alert = UIAlertController(title: "Beacon found", message: nil, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .cancel))
				present(alert, animated: true)
			}
			
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
				self.distanceLabel.text = "FAR"
				UIView.animate(
					withDuration: 0.25,
					animations: {
						self.view.backgroundColor = UIColor.blue
						self.circle.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
					}
				)
			case .near:
				self.distanceLabel.text = "NEAR"
				UIView.animate(
					withDuration: 0.25,
					animations: {
						self.view.backgroundColor = UIColor.orange
						self.circle.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
					}
				)
			case .immediate:
				self.distanceLabel.text = "RIGHT HERE"
				UIView.animate(
					withDuration: 0.25,
					animations: {
						self.view.backgroundColor = UIColor.red
						self.circle.transform = CGAffineTransform.init(scaleX: 0.25, y: 0.25)
					}
				)
			default:
				self.distanceLabel.text = "UNKNOWN"
				UIView.animate(
					withDuration: 0.25,
					animations: {
						self.view.backgroundColor = UIColor.gray
						self.circle.transform = CGAffineTransform.init(scaleX: 1, y: 1)
					}
				)
			}
		}
	}
}

