//
//  ViewController.swift
//  Project27.1
//
//  Created by Dmitriy Shmilo on 13.10.2021.
//

import UIKit

class ViewController:
	UIViewController,
	UIImagePickerControllerDelegate & UINavigationControllerDelegate {

	@IBOutlet private var imageView: UIImageView!

	private var topText: String?
	private var bottomText: String?
	private var selectedImage: UIImage?

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			guard let image = info[.originalImage] as? UIImage else {
				return
			}

			selectedImage = image
			dismiss(animated: true)
			refreshImage()
		}

	@IBAction private func setTopText(_ sender: Any) {
		let controller = UIAlertController(title: "Enter Top Text", message: nil, preferredStyle: .alert)
		controller.addTextField()
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		controller.addAction(UIAlertAction(title: "OK", style: .default) { [weak controller, weak self] _ in
			let text = controller?.textFields?[0].text
			self?.topText = text
			self?.refreshImage()
		})
		present(controller, animated: true)
	}

	@IBAction private func setBottomText(_ sender: Any) {
		let controller = UIAlertController(title: "Enter Bottom Text", message: nil, preferredStyle: .alert)
		controller.addTextField()
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		controller.addAction(UIAlertAction(title: "OK", style: .default) { [weak controller, weak self] _ in
			let text = controller?.textFields?[0].text
			self?.bottomText = text
			self?.refreshImage()
		})
		present(controller, animated: true)
	}

	@IBAction private func share(_ sender: Any) {
		guard let image = imageView.image?.jpegData(compressionQuality: 0.9) else {
			return
		}
		let controller = UIActivityViewController(activityItems: [image], applicationActivities: [])
		present(controller, animated: true)
	}

	@IBAction private func loadImage(_ sender: Any) {
		let controller = UIImagePickerController()
		controller.delegate = self
		present(controller, animated: true)
	}

	private func refreshImage() {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			guard let self = self else {
				return
			}
			guard let image = self.selectedImage else {
				return
			}

			let size = image.size
			let renderer = UIGraphicsImageRenderer(size: size)
			let result = renderer.image { ctx in
				image.draw(at: CGPoint.zero)

				let pStyle = NSMutableParagraphStyle()
				pStyle.alignment = .center

				let fillAttributes: [NSAttributedString.Key: Any] = [
					.font: UIFont.boldSystemFont(ofSize: size.height / 5),
					.foregroundColor: UIColor.white,
					.paragraphStyle: pStyle
				]
				let strokeAttributes: [NSAttributedString.Key: Any] = [
					.font: UIFont.boldSystemFont(ofSize: size.height / 5),
					.strokeColor: UIColor.black,
					.strokeWidth: 2,
					.paragraphStyle: pStyle
				]

				let topAS = NSMutableAttributedString(string: self.topText ?? "", attributes: strokeAttributes)
				let bottomAS = NSMutableAttributedString(string: self.bottomText ?? "", attributes: strokeAttributes)

				topAS.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height / 5))
				bottomAS.draw(in: CGRect(x: 0, y: image.size.height - size.height / 5, width: image.size.width, height: size.height / 5))

				topAS.setAttributes(fillAttributes, range: NSMakeRange(0, (topAS.string as NSString).length))
				bottomAS.setAttributes(fillAttributes, range: NSMakeRange(0, (bottomAS.string as NSString).length))

				topAS.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height / 5))
				bottomAS.draw(in: CGRect(x: 0, y: image.size.height - size.height / 5, width: image.size.width, height: size.height / 5))
			}

			DispatchQueue.main.async {
				self.imageView.image = result
			}
		}
	}
}

