//
//  Person.swift
//  Project12.2
//
//  Created by Dmitriy Shmilo on 05.09.2021.
//

import UIKit

class Person: NSObject, Codable {

	var name: String
	var image: String
	
	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
