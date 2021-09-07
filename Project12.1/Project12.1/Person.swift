//
//  Person.swift
//  Project12.1
//
//  Created by Dmitriy Shmilo on 05.09.2021.
//

import UIKit

class Person: NSObject, NSCoding {

	var name: String
	var image: String
	
	required init?(coder: NSCoder) {
		name = coder.decodeObject(forKey: "name") as? String ?? ""
		image = coder.decodeObject(forKey: "image") as? String ?? ""
	}
	
	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
	
	func encode(with coder: NSCoder) {
		coder.encode(name, forKey: "name")
		coder.encode(image, forKey: "image")
	}
}
