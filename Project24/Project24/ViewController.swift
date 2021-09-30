//
//  ViewController.swift
//  Project24
//
//  Created by Dmitriy Shmilo on 30.09.2021.
//

import UIKit

extension String {
	subscript(i: Int) -> String {
		return String(self[index(startIndex, offsetBy: i)])
	}

	func withPrefix(prefix: String) -> String {
		guard hasPrefix(prefix) else {
			return self
		}
		return prefix + self
	}
	
	func deletingPrefix(prefix: String) -> String {
		guard hasPrefix(prefix) else {
			return self
		}
		return String(dropFirst(prefix.count))
	}
	
	func deletingSuffix(suffix: String) -> String {
		guard hasSuffix(suffix) else {
			return self
		}
		return String(dropLast(suffix.count))
	}
	
	var capitalizedFirst: String {
		guard let firstLetter = first else {
			return ""
		}
		
		return firstLetter.uppercased() + dropFirst()
	}
	
	var isNumeric: Bool {
		guard let _ = Double(self) else {
			return false
		}
		return true
	}
	
	var lines: [String] {
		components(separatedBy: .newlines)
	}
}

class ViewController: UIViewController {

	@IBOutlet var label1: UILabel!
	@IBOutlet var label2: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let string = "This is a test string"
		let attributes: [NSAttributedString.Key : Any] = [
			.foregroundColor: UIColor.white,
			.backgroundColor: UIColor.black,
			.font: UIFont.boldSystemFont(ofSize: 36)
		]
		label1.attributedText = NSAttributedString(string: string, attributes: attributes)
		
		let attributedString = NSMutableAttributedString(string: string)
		attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
		attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
		attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
		attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
		attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))
		label2.attributedText = attributedString
	}


}

