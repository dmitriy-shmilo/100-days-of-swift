//
//  DetailsViewController.swift
//  Project3.1
//
//  Created by Dmitriy Shmilo on 02.09.2021.
//

import UIKit

class DetailsViewController: UIViewController {
	
	var selectedCountry: String!
	
	@IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
		imageView.image = UIImage(named: selectedCountry)
		title = selectedCountry.uppercased()
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
    }
	
	@objc private func shareImage() {
		guard let selectedCountry = selectedCountry, let image = imageView.image else {
			return
		}

		let viewController = UIActivityViewController(activityItems: [selectedCountry, image], applicationActivities: [])
		viewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(viewController, animated: true)
	}
}
