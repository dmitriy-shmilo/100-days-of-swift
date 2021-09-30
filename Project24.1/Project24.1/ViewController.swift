//
//  ViewController.swift
//  Project24.1
//
//  Created by Dmitriy Shmilo on 30.09.2021.
//

import UIKit

extension UIView {
	func bounceOut(duration: TimeInterval) {
		UIView.animate(
			withDuration: duration,
			delay: 0,
			options: [],
			animations: { [weak self] in
				self?.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
			}
		)
	}
}

extension Int {
	func times(action: () -> Void) {
		guard self > 0 else {
			return
		}
		for _ in 0..<self {
			action()
		}
	}
}

extension Array where Element: Equatable {
	mutating func remove(item: Element) {
		if let index = firstIndex(of: item) {
			remove(at: index)
		}
	}
}

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
}

