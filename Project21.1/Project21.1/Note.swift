//
//  Note.swift
//  Project21.1
//
//  Created by Dmitriy Shmilo on 14.09.2021.
//

import Foundation

struct Note: Codable {
	var id: UUID
	var body: String
	
	var title: String {
		let title = body.components(separatedBy: .newlines).first
		return title?.count ?? 0 > 0 ? title! : "Untitled"
	}
	var subtitle: String {
		body.components(separatedBy: .newlines).dropFirst().first ?? ""
	}
}
