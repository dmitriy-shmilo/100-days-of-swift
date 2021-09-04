//
//  Petition.swift
//  Project7
//
//  Created by Dmitriy Shmilo on 04.09.2021.
//

import Foundation

struct Petition: Codable {
	var title: String
	var body: String
	var signatureCount: Int
}

struct Petitions: Codable {
	var results: [Petition]
}
