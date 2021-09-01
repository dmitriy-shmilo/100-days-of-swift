//
//  DetailsViewController.swift
//  Project1
//
//  Created by Dmitriy Shmilo on 01.09.2021.
//

import UIKit

class DetailsViewController: UIViewController {
	
	var selectedImage: String?
	@IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let selectedImage = selectedImage {
			imageView.image = UIImage(named: selectedImage)
		}
		
		title = NSLocalizedString("View Picture", comment: "")
		navigationItem.largeTitleDisplayMode = .never
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.hidesBarsOnTap = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.hidesBarsOnTap = false
	}

}
