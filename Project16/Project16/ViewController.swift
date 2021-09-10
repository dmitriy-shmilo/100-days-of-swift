//
//  ViewController.swift
//  Project16
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
	
	@IBOutlet var mapView: MKMapView!

	override func viewDidLoad() {
		super.viewDidLoad()
		let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
		let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
		let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
		let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
		let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
		
		mapView.addAnnotations([london, oslo, paris, rome, washington])
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is Capital else {
			return nil
		}
		
		let identifier = "CapitalAnnotation"
		
		
		if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
			annotationView.annotation = annotation
			return annotationView
		} else {
			let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			annotationView.canShowCallout = true
			annotationView.pinTintColor = .purple
			
			let btn = UIButton(type: .detailDisclosure)
			annotationView.rightCalloutAccessoryView = btn
			return annotationView
		}
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let capital = view.annotation as? Capital else {
			return
		}
		
		if let details = storyboard?.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController {
			details.city = capital.title
			navigationController?.pushViewController(details, animated: true)
		}
	}
	
	@IBAction func selectMapType(_ sender: Any) {
		let alert = UIAlertController(title: "Select map type", message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Standard", style: .default, handler: { [weak self] _ in
			self?.mapView.mapType = .standard
		}))
		alert.addAction(UIAlertAction(title: "Satelite", style: .default, handler: { [weak self] _ in
			self?.mapView.mapType = .satellite
		}))
		alert.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: { [weak self] _ in
			self?.mapView.mapType = .hybrid
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(alert, animated: true)
	}
}

