//
//  DetailsViewController.swift
//  Project3
//
//  Created by Dmitriy Shmilo on 01.09.2021.
//

import UIKit

class DetailsViewController: UIViewController {
	
	var imageIndex: Int?
	var imageCount: Int?
	var selectedImage: String?

	@IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let selectedImage = selectedImage {
			imageView.image = UIImage(named: selectedImage)
		}
		
		if let imageIndex = imageIndex, let imageCount = imageCount {
			title = String(format: NSLocalizedString("Image %d/%d", comment: ""), imageIndex + 1, imageCount)
		} else {
			title = NSLocalizedString("View Picture", comment: "")
		}
		
		navigationItem.largeTitleDisplayMode = .never
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.hidesBarsOnTap = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.hidesBarsOnTap = false
	}

	private func markImage(image: UIImage) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: image.size)
		return renderer.image { ctx in
			let labelRect = CGRect(
				x: 0,
				y: image.size.height - 64,
				width: image.size.width,
				height: 64
			)
			image.draw(at: CGPoint(x: 0, y: 0))
			ctx.cgContext.setFillColor(CGColor(gray: 0, alpha: 0.2))
			ctx.cgContext.fill(labelRect)
			let string = "From Storm Viewer"
			let paragraph = NSMutableParagraphStyle()
			paragraph.alignment = .center
			NSAttributedString(
				string: string,
				attributes: [
					.font: UIFont.systemFont(ofSize: 32),
					.paragraphStyle: paragraph,
					.foregroundColor: UIColor.white
				]
			).draw(in: labelRect)
		}
	}
	@objc private func shareTapped() {
		guard let image = imageView.image,
			  let image = markImage(image: image)
				.jpegData(compressionQuality: 0.8) else {
			print("No image found.")
			return
		}
		
		let viewController = UIActivityViewController(activityItems: [selectedImage ?? "", image], applicationActivities: [])
		viewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(viewController, animated: true)
	}

}
