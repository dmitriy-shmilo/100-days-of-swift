//
//  ViewController.swift
//  Project6
//
//  Created by Dmitriy Shmilo on 04.09.2021.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		let labels = [("THESE", UIColor.red), ("ARE", UIColor.cyan), ("SOME", UIColor.green), ("AWESOME", UIColor.yellow), ("LABELS", UIColor.orange)].map { (text, color) -> UILabel in
			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.text = text
			label.sizeToFit()
			label.backgroundColor = color
			view.addSubview(label)
			return label
		}
		
		var previous: UILabel?
		
		for label in labels {
			label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
			label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
			label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2, constant: -10).isActive = true
			
			if let previous = previous {
				label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
			} else {
				label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
			}
			
			previous = label
		}
	}
}

