//
//  DetailsViewController.swift
//  Project12.3
//
//  Created by Dmitriy Shmilo on 07.09.2021.
//

import UIKit

class DetailsViewController: UIViewController {
	
	var photo: Photo!
	@IBOutlet var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(photo.name, isDirectory: false)
		if let data = try? Data(contentsOf: url) {
			imageView.image = UIImage(data: data)
		}
    }
}
