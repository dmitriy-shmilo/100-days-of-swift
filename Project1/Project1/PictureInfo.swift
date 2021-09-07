//
//  PictureInfo.swift
//  Project1
//
//  Created by Dmitriy Shmilo on 07.09.2021.
//

import Foundation

struct PictureInfo: Codable {
	var name: String
	var viewCount: Int
	
	init(name: String, viewCount: Int) {
		self.name = name
		self.viewCount = viewCount
	}
}
