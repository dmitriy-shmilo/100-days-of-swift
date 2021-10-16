//
//  ViewController.swift
//  Project10
//
//  Created by Dmitriy Shmilo on 05.09.2021.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	private var people = [Person]()
	private var isAuthenticated = false

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(authenticate))
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(hideData),
			name: UIApplication.willResignActiveNotification,
			object: nil
		)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		isAuthenticated ? people.count : 0
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonViewCell else {
			fatalError("Unable to dequeue person cell")
		}
		
		let person = people[indexPath.item]
		cell.nameLabel.text = person.name
		
		let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(person.image)
		cell.imageView.image = UIImage(contentsOfFile: path.path)
		cell.imageView.layer.borderWidth = 2
		cell.imageView.layer.borderColor = UIColor.lightGray.cgColor
		cell.imageView.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let person = people[indexPath.item]
		let alert = UIAlertController(title: "Modify", message: nil, preferredStyle: .alert)
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak alert] _ in
			guard let text = alert?.textFields?[0].text else {
				return
			}
			
			person.name = text
			collectionView.reloadItems(at: [indexPath])
		}))
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
			self?.people.remove(at: indexPath.item)
			collectionView.deleteItems(at: [indexPath])
		}))
		
		alert.textFields?[0].text = person.name
		present(alert, animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else {
			return
		}
		
		let imageName = UUID().uuidString
		let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(imageName)
		
		if let jpegData = image.jpegData(compressionQuality: 0.8) {
			try? jpegData.write(to: path)
		}
		
		let person = Person(name: "No name", image: imageName)
		people.append(person)
		collectionView.reloadData()
		
		dismiss(animated: true)
	}
	
	@objc private func addPerson() {
		guard isAuthenticated else {
			return
		}

		let picker = UIImagePickerController()
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		} else {
			picker.sourceType = .photoLibrary
		}
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}

	@objc private func hideData() {
		isAuthenticated = false
		collectionView.reloadData()
	}

	@objc private func authenticate() {
		guard !isAuthenticated else {
			return
		}

		let context = LAContext()
		var error: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Identify yourself"
			context.evaluatePolicy(
				.deviceOwnerAuthenticationWithBiometrics,
				localizedReason: reason) { [weak self] success, error in

					DispatchQueue.main.async {
						if success {
							self?.isAuthenticated = true
							self?.collectionView.reloadData()
						} else {
							print(error.debugDescription)
							let ac = UIAlertController(
								title: "Authentication failed",
								message: "You could not be verified; please try again.",
								preferredStyle: .alert
							)
							ac.addAction(UIAlertAction(title: "OK", style: .cancel))
							self?.present(ac, animated: true)
						}
					}
			}
		} else {
			let ac = UIAlertController(
				title: "Biometry unavailable",
				message: "Your device is not configured for biometric authentication.",
				preferredStyle: .alert
			)
			ac.addAction(UIAlertAction(title: "OK", style: .cancel))
			self.present(ac, animated: true)
		}
	}
}

