//
//  Person.swift
//  Project10
//
//  Created by Dmitriy Shmilo on 05.09.2021.
//

import UIKit

class Person: NSObject {
	var name: String
	var image: String
	
	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
