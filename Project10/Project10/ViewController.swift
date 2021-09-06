//
//  ViewController.swift
//  Project10
//
//  Created by Dmitriy Shmilo on 05.09.2021.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	var people = [Person]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPerson))
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		people.count
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


}

