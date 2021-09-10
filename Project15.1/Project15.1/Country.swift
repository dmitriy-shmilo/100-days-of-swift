//
//  Country.swift
//  Project15.1
//
//  Created by Dmitriy Shmilo on 10.09.2021.
//

import Foundation

struct Country: Codable, Identifiable {
	let id: Int
	let name: String
	let flag: String
	let status: String
	let recognition: String
	let capital: String
	let population: Int
	let area: Int
}
