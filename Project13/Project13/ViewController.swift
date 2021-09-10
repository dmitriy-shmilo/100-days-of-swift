//
//  ViewController.swift
//  Project13
//
//  Created by Dmitriy Shmilo on 08.09.2021.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	
	@IBOutlet var intensitySlider: UISlider!
	@IBOutlet var radiusSlider: UISlider!
	@IBOutlet var scaleSlider: UISlider!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var changeFilterButton: UIButton!

	var currentImage: UIImage!
	var context: CIContext!
	var filter: CIFilter!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		context = CIContext()
		filter = CIFilter(name: "CISepiaTone")
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else {
			return
		}
		
		imageView.alpha = 0
		currentImage = image
		let inputImage = CIImage(image: currentImage)
		filter.setValue(inputImage, forKey: kCIInputImageKey)
		applyFilter()
		dismiss(animated: true) {
			UIView.animate(withDuration: 0.33) { [unowned self] in
				imageView.alpha = 1.0
			}
		}
	}
	
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			let alert = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
		} else {
			let alert = UIAlertController(title: "Saved", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
		}
	}
	
	@IBAction func changeFilter(_ sender: Any) {
		let sheet = UIAlertController(title: "Change label", message: nil, preferredStyle: .actionSheet)
		sheet.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(sheet, animated: true)
	}
	
	@IBAction func save(_ sender: Any) {
		if let image = imageView.image {
			UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
		} else {
			let alert = UIAlertController(title: "Error", message: "Pick and alter an image first", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
			present(alert, animated: true)
		}
	}
	
	@IBAction func intensityChanged(_ sender: Any) {
		applyFilter()
	}
	
	@IBAction func importImage(_ sender: Any) {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
	
	private func applyFilter() {
		guard let image = filter.outputImage else {
			return
		}
		
		let keys = filter.inputKeys
		
		if keys.contains(kCIInputIntensityKey) {
			filter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
		}
		
		if keys.contains(kCIInputRadiusKey) {
			filter.setValue(radiusSlider.value, forKey: kCIInputRadiusKey)
		}
		
		if keys.contains(kCIInputScaleKey) {
			filter.setValue(scaleSlider.value, forKey: kCIInputScaleKey)
		}
		
		if keys.contains(kCIInputCenterKey) {
			filter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
		}
		
		if let cgImage = context.createCGImage(image, from: image.extent) {
			imageView.image = UIImage(cgImage: cgImage)
		}
	}
	
	private func setFilter(_ action: UIAlertAction) {
		guard currentImage != nil else {
			return
		}
		
		guard let actionTitle = action.title else {
			return
		}
		
		changeFilterButton.titleLabel?.text = actionTitle
		filter = CIFilter(name: actionTitle)
		let inputImage = CIImage(image: currentImage)
		filter.setValue(inputImage, forKey: kCIInputImageKey)
		applyFilter()
	}
	
}

