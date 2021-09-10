//
//  Capital.swift
//  Project16
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
	var title: String?
	var coordinate: CLLocationCoordinate2D
	var info: String
	
	init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
		self.title = title
		self.coordinate = coordinate
		self.info = info
	}
 
}
